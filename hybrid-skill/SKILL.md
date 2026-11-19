---
name: hybrid-skill
description: Improve a skill by turning it into a hybrid. A script owns the repeatable process and the skill keeps only the judgment, then a benchmark compares old and new. Use when improving a skill, when a skill is slow, expensive or inconsistent, or when moving a skill's steps into software.
---

# Hybrid skill

A skill hands a manual process to an agent, and the agent runs every step of it with a model, paying tokens for work that software would do faster, cheaper and the same way every time. A **hybrid** skill splits the work. A script owns the **process** and the model owns the **judgment**. Kent C. Dodds made this change to a triage skill. Gathering, paginating, sorting, applying and verifying moved into a script, and the model kept the per-issue call. The hybrid was faster at every effort level, cost the same or less, and was more accurate, probably because the model read fewer tokens.

## 1. Map the process

Read the target skill and list every step it asks the agent to take. Label each one:

- **Process** if the same inputs always give the same correct output: fetching, paginating, sorting, filtering, formatting, applying a decided change, verifying a result, waiting on CI or a reviewer, retrying.
- **Judgment** if it needs a model to read meaning: classifying, deciding, writing, choosing a fix.

Some judgment steps are small calls with a fixed set of answers, like "is this comment a request or a thanks?". Mark them **cheap call**, since step 4 can hand them to a smaller model.

Done when every step has a label, and each judgment step names the facts it needs to decide.

## 2. Measure the baseline

Copy the original skill to the scratchpad as `baseline/` before you edit anything.

Write 2 to 5 tasks in the shape `scripts/bench.py --help` describes. Each task needs a fixture the skill acts on and a `check` command that exits 0 only when the outcome is right. Pick fixtures where the skill has to make its judgment calls, and include one where the right answer is easy to get wrong. When the skill acts on GitHub or another live service, the fixture is a sandbox repo or account that the setup command seeds, never the user's real one.

Run the baseline alone with `--runs 1` to prove that the tasks and checks work:

```bash
python3 ~/.agents/skills/hybrid-skill/scripts/bench.py \
  --variant baseline=<scratch>/baseline --tasks <scratch>/tasks.json --out <scratch>/bench --runs 1
```

Done when every run is valid and every check failure traces to the skill, not to the task. A broken check gets fixed here, before it can score the hybrid.

## 3. Write the script

Put the process steps in a script under the target skill's `scripts/`. Rules for the script:

- **It prints only what the next judgment needs**, as a short, structured block (JSON or labelled lines). Leave raw API pages, full logs and step-by-step narration out of the output. The model's context holds the decision's inputs and nothing else.
- **It resolves its own paths** and prints what it changed, with absolute paths. An agent that runs it from another directory still gets the right result and can see it.
- **It applies and verifies.** The model returns its decision as data, such as a JSON file or flags, and the script applies it and checks the result. The skill ends on the script's verification, not on the model's word.
- **It handles credentials itself.** It reads tokens from the CLI's login or the environment, and never prints them.
- **It is idempotent.** Running it twice leaves the same state as running it once.

When the process has phases or waits, use the **tick** form. The skill becomes "run this command, act on what it prints, run it again, stop when it prints `done`." Each tick works out where things stand and prints the one next action with only that action's context: a failing CI check with its log excerpt, or a single review finding. Waiting is a state the tick reports ("CI still running, sleep 120s and tick again"), so the agent never writes its own polling loop. The model gets context just in time instead of reading a long procedure up front and losing the middle of it.

Done when the script runs every process step on the step 2 fixtures without a model, and its output alone is enough to make each judgment call.

## 4. Route cheap calls (optional)

For steps marked cheap call, the script can ask a small, fast model and cache the answer keyed on the input, so the same question is never paid for twice. Kent's ship-pr tick does this to decide whether a review comment needs the implementer at all. A "thanks!" never wakes the expensive agent. Skip this step when there are no cheap calls or the script can decide them with plain rules.

Done when every cheap call is answered by a rule, a cached small-model call, or the main model, and each cheap call's route is written down.

## 5. Rewrite the skill

Cut the target `SKILL.md` down to three things: when to run the script and how, the judgment rules for what it prints, and the stop condition. Delete the process prose the script now owns, since the script is now the source of truth for it. Refer to scripts by a path relative to the skill directory or by the installed path, but use the same form in every place. Follow `writing-for-agents` for the rewrite.

Done when every step labelled process in step 1 lives in the script and is gone from the prose, and every judgment step has its rule in the prose.

## 6. Benchmark and decide

Run both versions on the same tasks:

```bash
python3 ~/.agents/skills/hybrid-skill/scripts/bench.py \
  --variant baseline=<scratch>/baseline --variant hybrid=<target-skill-dir> \
  --tasks <scratch>/tasks.json --out <scratch>/bench --runs 3
```

Each run gets a fresh workdir with only that variant's copy of the skill, and the installed copies stay unloaded. If the script warns that a variant points at the installed copy's path, the variant would run the installed scripts. Fix that before you trust the numbers. Several runs across several tasks are heavy work, so put the benchmark on a devbox under `laptop-compute-caps` and `boxes-dev`, or run it on the laptop through `capped.sh`.

Keep the hybrid only when its pass rate is at least the baseline's and it is faster or cheaper. When accuracy drops, read the failing runs' transcripts (`<out>/runs/*.jsonl`) and fix the script output or the judgment rules, then run the benchmark again. Report the summary table the script prints, with the baseline and hybrid rows side by side.

Done when the hybrid wins on that bar and its table is in the report, or the original skill is restored and the report says why the hybrid lost.
