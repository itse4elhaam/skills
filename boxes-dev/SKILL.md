---
name: boxes-dev
description: boxes.dev / `dvb` - run work on cloud devboxes from the workstation. Use when creating, driving, waking, sleeping or destroying a boxes.dev box, starting a Claude or Codex thread on one, moving files to or from a box, or budgeting box-hours.
---

# boxes.dev

Drive boxes.dev from the workstation with `dvb` (npm `@boxes-dev/cli`). Product docs ship with it: `dvb agent-docs` prints the index, and `dvb agent-docs agent-tools` covers everything below in depth. Check flags with `dvb <cmd> <sub> -h`. On nested subcommands `--help` prints the top-level help instead.

Run `dvb` only on the workstation. Agents on a box get the separate `dvb-onbox` tool; never install or run workstation `dvb` on a box.

## Before the first create

1. `dvb version` shows `login: ok`. If not, the user signs in with `dvb setup`.
2. The project is set up: `dvb agent-init status --json` shows phase `complete`. A new project goes through `dvb agent-init`, which the user approves.
3. The user approved creating boxes and the spend for this task. Approval for one task does not carry over to the next.
4. No STOP flag exists (see [Budget](#budget)).

Resolve the fingerprint at runtime and use it everywhere:

```bash
FP=$(dvb projects list --json | jq -r '.data.projects[] | select(.name=="<project>") | .fingerprint')
key() { node -p 'require("node:crypto").randomUUID()'; }
```

## Run work on a devbox

```bash
k=$(key)   # keep the key with the result until the outcome is known
r=$(dvb devboxes create --project "$FP" --idempotency-key "$k" --wait --json)
jq '.data | {status: .operation.status, id: .target.instanceId, name: .target.name}' <<<"$r"
dvb cp ./input.mp4 <name>:/home/boxes/job/input.mp4
dvb cp -r ./scripts <name>:/home/boxes/job/
dvb exec --project "$FP" --target <instanceId> --cwd project --json -- bash -lc 'cd ~/job && nohup bash run.sh > run.log 2>&1 &'
dvb exec --project "$FP" --target <instanceId> --cwd project --json -- bash -lc 'tail -3 ~/job/run.log'   # poll
```

- The new box's id and name are under `data.target`, not `data`. `create --wait` also reports a failed create with `ok: true`, so read `data.operation.status`. `dvb cp` worked with the `name` (`content-fork-…`); `exec` and `devboxes *` take the `instanceId`.
- A new devbox starts from the latest Template snapshot. Push the branch first or `dvb cp` what the snapshot lacks. After changing the Template box, `dvb checkpoint <template-alias>` so new devboxes get the change. When several boxes need the same heavy inputs or packages, stage them once on the Template box and checkpoint, so each box starts ready instead of re-uploading and reinstalling.
- The snapshot has system `python3` without numpy, OpenCV, onnxruntime or Pillow. `python3 -m venv ~/job/venv && ~/job/venv/bin/pip install …` took under 2 minutes. The default box has 4 vCPUs and about 7 GiB of usable RAM, so size worker pools and thread counts for 4 cores.
- Run anything longer than a few minutes detached with `nohup … &` and poll its log, as above. Then a dropped connection or `exec` timeout can't kill the job. Watch the log from a background loop on the workstation that exits on a done marker or `Traceback`, rather than one blocking `exec`.
- `dvb cp` uploaded at about 1.7 MB/s (173 MB in 104 s, Nov 2026). Stage only what the job reads.
- Any `exec` on a sleeping box wakes it, and it stays awake and burning box-hours until you sleep it again.
- Idempotency keys: one per logical create, start or send. After an uncertain result, retry with the same key and identical arguments. After a confirmed failure with `retryable: true`, use a new key.
- `exec` passes argv literally. Use `bash -lc '...'` for pipes, globs and `cd`. `--cwd` takes `project` or an absolute path, never `project/sub`. A nonzero remote exit is a completed result; read `exitCode`, and check the truncation flags on stdout and stderr.
- Write the `instanceId` and key to a notes file in the task's working folder. A thread that loses them leaves a box burning hours.

## Get files back

`dvb cp` copies workstation to box only. There is no box-to-workstation copy command. Use [`scripts/pull.sh`](scripts/pull.sh) for any file:

```bash
~/.claude/skills/boxes-dev/scripts/pull.sh <instanceId> <remote-path> <local-path> "$FP"
```

It base64s 3 MB pieces through `exec`, six in parallel, and compares md5 before keeping the file. A 38 MB video took 33 s (Nov 2026). Record every other method you prove here, with the date and file size.

**Verified**
- `pull.sh`, above.
- `exec` keeps 1 MiB of stdout by default and at most 4 MiB with `--max-output-bytes 4194304`. Larger values are rejected. Past the limit, output is cut and `data.stdoutTruncated` is `true`.
- Small text: `dvb exec ... --json -- cat <file>`, read `data.stdout`.
- Write parallel loops that `export -f` a function under `bash`; zsh rejects `export -f`.

**Fails**
- `scp` with `dvb ssh proxy <box>` as `ProxyCommand`: "Port 22 on <box> cannot be forwarded" (Nov 2026).

**To verify**
- `dvb mount <box>` (SSHFS). Undo with `dvb unmount <box>`.
- `dvb ports fwd <box> <port>` with a file server started on the box.

## Agent threads on boxes

```bash
dvb threads options --json                                    # models and provider connections
dvb threads start --project "$FP" --target new-devbox --agent claude --model <model> \
  --prompt-file task.md --idempotency-key "$(key)" --muted --json   # -> clientThreadId
dvb threads list --project "$FP" --json                       # activeTurnId per thread
dvb threads wait <clientThreadId> --turn <activeTurnId> --timeout 30m --json
dvb threads read <clientThreadId> --json
dvb threads send --thread <clientThreadId> --prompt-file next.md --idempotency-key "$(key)" --json
```

- `--target` is `template`, `new-devbox` or `devbox:<instanceId>`. The `devbox:` prefix applies here only; `devboxes *` and `exec` take the bare id.
- A turn is done only when `threads wait` returns `data.status == "completed"`. `ok: true` also covers needs-input, failure and timeout.
- `pendingInput` is a question or approval for the owner. Pass the question and its `threadUrl` to the user, never answer it, then wait on the same turn again.
- `operation_indeterminate` on a send means it may have landed. Retry only with the same key.

## Sleep, wake, destroy

```bash
dvb devboxes sleep|wake --project "$FP" --target <instanceId> --json
dvb devboxes destroy --project "$FP" --target <instanceId> --archive-threads --wait --yes --json
dvb sleep <template-alias>    # the Template box uses the alias commands: sleep, wake, checkpoint
```

- Every awake box costs box-hours, idle or not. Sleep a box before any wait longer than about 10 minutes, such as a review or a user reply.
- Destroy once outputs are on the workstation and recorded. Plain `destroy` refuses a box that has threads, so pass `--archive-threads --wait`.
- Before ending a turn, run `dvb devboxes list --project "$FP" --json` and account for every box you created: asleep, destroyed, or handed to the user by name.

## Budget

- One box-hour is one default 4 vCPU / 8 GiB box awake for an hour. Larger sizes cost more per hour: 4/16 GiB about 1.39, 8/16 GiB 2, 8/24 GiB about 2.39, 8/32 GiB about 2.78. The largest is 8 vCPU / 32 GiB. Size is fixed per project and `dvb` has no size option, so a bigger box means the user creates a new project in the desktop app. For one job, a second project rarely beats finishing on the box you have. To go faster, split the work across several default boxes.
- Pro: 300 h per period, the Template box plus 12 awake devboxes. Overage is $0.40 per box-hour. Plans and current usage: `dvb agent-docs billing-and-limits`.
- Read usage through the Template box: `dvb exec --project "$FP" --target <template-alias> --cwd project --json -- bash -lc 'dvb-onbox billing status --json'`. `data.stdout` has `boxHoursUsed` and `awakeDevboxes`.

**Guard pattern.** A long run gets a guard loop that reads usage every 20 minutes and writes two flag files:

- `WARN` at the warn threshold: finish the current round and start nothing new.
- `STOP` at the stop threshold: the guard sleeps every awake box. Threads check for `STOP` before every create, wake or `threads start --target new-devbox`. If it exists, they create and wake nothing, pull back what they have, tell the user and stop.

Example: the content reels run `~/workspace/content/scripts/boxes-budget-guard.sh`, which writes `BOXES_WARN` at 230 h and `BOXES_STOP` at 250 h of 300 in `~/Videos/insta/reels/` and logs to `boxes-budget.log` there.

Each billing `exec` wakes a sleeping Template box. The guard checks the Template's status with `devboxes list` first (that doesn't wake it) and runs `dvb sleep <template-alias>` after reading if it was asleep. `devboxes list` reports awake boxes as `running` and others as `sleeping`.

## Secrets

Boxes get no credentials from the workstation: no rclone config, tokens, `.env` files or SSH keys through `dvb cp`, `exec` or prompts. If a box needs a credential, the user adds it under Project settings → Environment files in the desktop app. Until then, fetch on the workstation, `dvb cp` the inputs up, bring the outputs back and upload them from the workstation.
