#!/usr/bin/env python3
"""Benchmark skill variants head to head with headless Claude Code.

Each run gets a fresh git workdir holding only that variant's copy of the
skill (in .claude/skills/<name>), and Claude starts with
--setting-sources project, so the installed copies under ~/.claude and
~/.agents are not loaded. A run counts as valid only if the init event lists
the skill.

Usage:
  bench.py --variant baseline=/path/to/old-skill --variant hybrid=/path/to/new-skill \\
           --tasks tasks.json --out /scratch/bench [--runs 3] [--model sonnet] \\
           [--max-budget-usd 2] [--timeout 900]

tasks.json is a list of tasks:
  [
    {
      "id": "triage-mixed-issues",
      "prompt": "Use the triage skill on this repo's open issues.",
      "fixture": "fixtures/mixed-issues",   # optional dir copied into the workdir
      "setup": "./seed.sh",                  # optional, runs in the workdir before Claude
      "check": "./check.sh"                  # required, runs in the workdir after; exit 0 = pass
    }
  ]
Relative fixture paths resolve against the tasks file's directory. setup and
check run with WORKDIR, VARIANT, TASK_ID and RUN set in their environment.

Writes <out>/results.jsonl (one row per run) and prints a summary table of
pass rate and medians per variant. Runs are interleaved across variants, so
drift over time (API latency, cache warmth) lands evenly on all of them.
"""

import argparse
import json
import os
import re
import shutil
import statistics
import subprocess
import sys
import time
from pathlib import Path


def skill_name(skill_dir: Path) -> str:
    text = (skill_dir / "SKILL.md").read_text()
    match = re.search(r"^name:\s*(\S+)\s*$", text, re.MULTILINE)
    if not match:
        sys.exit(f"{skill_dir}/SKILL.md has no name: in its frontmatter")
    return match.group(1)


def warn_installed_paths(label: str, skill_dir: Path, name: str) -> None:
    """A variant that calls its scripts by an absolute installed path would run the installed copy."""
    pattern = re.compile(rf"(~|{re.escape(str(Path.home()))})/\.(agents|claude)/skills/{re.escape(name)}/")
    for path in skill_dir.rglob("*"):
        if path.is_file():
            try:
                if pattern.search(path.read_text()):
                    print(f"warning: {label}: {path} points at the installed copy of {name}; "
                          "that run would use the installed scripts, not this variant's", file=sys.stderr)
            except UnicodeDecodeError:
                pass


def run_shell(cmd: str, cwd: Path, env: dict, timeout: int) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, shell=True, cwd=cwd, env=env, timeout=timeout,
                          capture_output=True, text=True)


def one_run(args, task, tasks_dir: Path, label: str, skill_dir: Path, name: str, run: int) -> dict:
    workdir = args.out / "runs" / f"{task['id']}--{label}--{run}"
    if workdir.exists():
        shutil.rmtree(workdir)
    if task.get("fixture"):
        shutil.copytree(tasks_dir / task["fixture"], workdir)
    else:
        workdir.mkdir(parents=True)
    shutil.copytree(skill_dir, workdir / ".claude" / "skills" / name)
    subprocess.run(["git", "init", "-q"], cwd=workdir, check=True)

    env = {**os.environ, "WORKDIR": str(workdir), "VARIANT": label, "TASK_ID": task["id"], "RUN": str(run)}
    row = {"task": task["id"], "variant": label, "run": run, "workdir": str(workdir)}

    if task.get("setup"):
        setup = run_shell(task["setup"], workdir, env, args.timeout)
        if setup.returncode != 0:
            return {**row, "valid": False, "error": f"setup exited {setup.returncode}: {setup.stderr[-500:]}"}

    cmd = ["claude", "-p", task["prompt"], "--setting-sources", "project",
           "--output-format", "stream-json", "--verbose", "--no-session-persistence",
           "--dangerously-skip-permissions", "--max-budget-usd", str(args.max_budget_usd)]
    if args.model:
        cmd += ["--model", args.model]
    started = time.monotonic()
    try:
        proc = subprocess.run(cmd, cwd=workdir, env=env, stdin=subprocess.DEVNULL,
                              capture_output=True, text=True, timeout=args.timeout)
        stream = proc.stdout
    except subprocess.TimeoutExpired as exc:
        stream = exc.stdout.decode() if isinstance(exc.stdout, bytes) else (exc.stdout or "")
        row["error"] = f"timed out after {args.timeout}s"
    (workdir.parent / f"{workdir.name}.jsonl").write_text(stream)
    row["wall_s"] = round(time.monotonic() - started, 1)

    loaded, invoked, result = False, False, None
    for line in stream.splitlines():
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        if event.get("type") == "system" and event.get("subtype") == "init":
            loaded = name in (event.get("skills") or [])
        elif event.get("type") == "assistant":
            for block in event.get("message", {}).get("content", []):
                if block.get("type") == "tool_use" and block.get("name") == "Skill":
                    invoked = invoked or name in json.dumps(block.get("input", {}))
        elif event.get("type") == "result":
            result = event

    row["skill_loaded"], row["skill_invoked"] = loaded, invoked
    if result:
        usage = result.get("usage") or {}
        row.update({
            "duration_s": round(result.get("duration_ms", 0) / 1000, 1),
            "cost_usd": result.get("total_cost_usd"),
            "turns": result.get("num_turns"),
            "tokens": sum(usage.get(k, 0) or 0 for k in
                          ("input_tokens", "output_tokens", "cache_read_input_tokens", "cache_creation_input_tokens")),
            "claude_error": result.get("is_error"),
        })
    check = run_shell(task["check"], workdir, env, args.timeout)
    row["pass"] = check.returncode == 0
    row["check_output"] = (check.stdout + check.stderr)[-500:]
    row["valid"] = loaded and result is not None and "error" not in row
    return row


def summarize(rows: list, labels: list) -> str:
    def med(values):
        values = [v for v in values if v is not None]
        return statistics.median(values) if values else None

    def fmt(value, spec):
        return "-" if value is None else format(value, spec)

    lines = ["| variant | valid runs | pass rate | median duration s | median cost $ | median turns | median tokens | skill invoked |",
             "|---|---|---|---|---|---|---|---|"]
    for label in labels:
        mine = [r for r in rows if r["variant"] == label]
        valid = [r for r in mine if r["valid"]]
        passed = sum(r["pass"] for r in valid)
        invoked = sum(r["skill_invoked"] for r in valid)
        lines.append(
            f"| {label} | {len(valid)}/{len(mine)} | {passed}/{len(valid)} | "
            f"{fmt(med([r.get('duration_s') for r in valid]), '.1f')} | "
            f"{fmt(med([r.get('cost_usd') for r in valid]), '.4f')} | "
            f"{fmt(med([r.get('turns') for r in valid]), '.0f')} | "
            f"{fmt(med([r.get('tokens') for r in valid]), '.0f')} | {invoked}/{len(valid)} |")
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--variant", action="append", required=True, metavar="LABEL=SKILL_DIR")
    parser.add_argument("--tasks", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--runs", type=int, default=3)
    parser.add_argument("--model")
    parser.add_argument("--max-budget-usd", type=float, default=2.0, help="per run")
    parser.add_argument("--timeout", type=int, default=900, help="seconds per run, and per setup or check")
    args = parser.parse_args()

    variants = []
    for spec in args.variant:
        label, _, path = spec.partition("=")
        skill_dir = Path(path).expanduser().resolve()
        if not label or not (skill_dir / "SKILL.md").is_file():
            sys.exit(f"--variant {spec}: expected LABEL=DIR where DIR holds a SKILL.md")
        name = skill_name(skill_dir)
        warn_installed_paths(label, skill_dir, name)
        variants.append((label, skill_dir, name))

    tasks = json.loads(args.tasks.read_text())
    tasks_dir = args.tasks.resolve().parent
    args.out = args.out.expanduser().resolve()
    args.out.mkdir(parents=True, exist_ok=True)

    rows = []
    with (args.out / "results.jsonl").open("a") as results:
        for task in tasks:
            for run in range(1, args.runs + 1):
                for label, skill_dir, name in variants:
                    row = one_run(args, task, tasks_dir, label, skill_dir, name, run)
                    rows.append(row)
                    results.write(json.dumps(row) + "\n")
                    results.flush()
                    status = "PASS" if row.get("pass") else "FAIL"
                    if not row["valid"]:
                        status = f"INVALID ({row.get('error') or 'skill not loaded or no result'})"
                    print(f"{task['id']} {label} run {run}: {status} "
                          f"{row.get('duration_s', '-')}s ${row.get('cost_usd', '-')}", file=sys.stderr)

    print(summarize(rows, [label for label, _, _ in variants]))


if __name__ == "__main__":
    main()
