---
name: laptop-compute-caps
description: Laptop compute caps - keep Elhaam's workstation at or under 50% CPU and 70% RAM. Use before running anything CPU- or RAM-heavy on this machine (model runs, transcription, ffmpeg encodes, renders, big builds or test suites), or when choosing between this laptop and boxes.dev.
---

# Laptop compute caps

Elhaam, 15 Nov 2026: "use boxes.dev compute as much as you want but for this laptop's compute stay at 50% CPU and 70% RAM (wanna keep it usable)".

## Where heavy work runs

1. **boxes.dev first.** Model runs, transcription, ffmpeg encodes, renders, big builds and test suites go to devboxes. Use them freely; [boxes-dev](../boxes-dev/SKILL.md) covers how.
2. **This laptop only when a box can't take the job**: all 12 awake devboxes the Pro plan allows are busy, or the job needs something only the laptop has. Then the job runs through [`scripts/capped.sh`](scripts/capped.sh).
3. **Light steps run directly**: ffprobe, a stream copy, a few stills, git, small scripts.

## The caps

The **whole machine** stays at or under 50% CPU and 70% RAM while agent work runs: the job plus everything already running (other agents' jobs, his browser and apps). Budget against the machine's current load, never the job alone. One capped heavy job at a time.

## Run a job capped

```bash
~/.agents/skills/laptop-compute-caps/scripts/capped.sh [--cpus N] [--mem SIZE] [--lock NAME] -- <cmd...>
```

In order, it:

1. Queues on `~/.cache/capped/<NAME>.lock` (default `heavy`, shared by every agent), so one capped job runs at a time.
2. Waits while machine RAM use (total minus available) is above 60%.
3. Samples `/proc/stat` for 1.5 s and sets the caps. CPUs: floor(nproc / 2) minus the CPUs busy now (rounded up), at least 1. Memory: 70% of RAM minus RAM used now. `--cpus` and `--mem` (IEC: `512M`, `12G`) only lower them.
4. Runs the command in a systemd user scope (`capped-<NAME>-<pid>.scope`) with `MemoryMax` and `MemorySwapMax=0`, pinned with `taskset` to the least-busy CPUs, under `nice -n 19` and `ionice -c3`.
5. Governs the CPUs while the command runs. Every 5 s it measures the whole machine. Above 50%, it shrinks the job by 1 CPU per 5 points over, rounded up, to at least 1. Below 40%, it grows the job by 1 CPU, up to the start allocation. It re-pins with `taskset -acp` only the processes listed in the job scope's `cgroup.procs`, so it covers the job's children and every thread and never touches another process. Each change is logged with a timestamp. The governor exits with the command.

It prints the machine load, the chosen caps and each governor change to stderr and exits with the command's code. Exit 137 means the job was killed at the memory cap. The queue and the RAM wait can block for minutes, so run long jobs in the background and poll their log.

**Match the program's threads to the pinned CPUs.** The command sees `CAPPED_CPUS`, `CAPPED_MEM` (bytes), `OMP_NUM_THREADS`, `MKL_NUM_THREADS` and `OPENBLAS_NUM_THREADS`. Pass `CAPPED_CPUS` to the program's own flag inside `bash -c`, so it expands after the caps are chosen:

```bash
capped.sh -- bash -c 'ffmpeg -threads "$CAPPED_CPUS" -i in.mov ... out.mp4'
capped.sh --mem 12G -- bash -c 'python -I transcribe.py --threads "$CAPPED_CPUS" ...'   # faster-whisper cpu_threads
```

## Why these mechanisms

Proven on this machine, 15 Nov 2026: i7-1370P, 20 logical CPUs (6 P-cores with HT are CPUs 0-11, 8 E-cores are 12-19), 62 GiB RAM, 19 GiB swap, cgroup v2.

- The user systemd instance delegates only the `memory` and `pids` controllers (`cat /sys/fs/cgroup/user.slice/user-1000.slice/user@1000.service/cgroup.controllers`). `systemd-run --user -p CPUQuota=` therefore has no effect. CPU is capped by pinning (`taskset`) and priority (`nice`), RAM by the scope's `MemoryMax`.
- `MemorySwapMax=0` makes a job die at its cap instead of pushing the laptop into swap.
- `ionice -c3` acts only under the BFQ I/O scheduler. `nvme0n1` runs kyber, so today it is a placeholder.
- A cap set once at start doesn't hold: in a test on 15 Nov 2026, other load rose mid-run and the machine reached 57.7%, hence the governor. The memory cap stays fixed at its start value.
- The governor can only shrink the job. When other load alone is above 50%, the machine stays above 50% even with the job at 1 CPU.

## Check a running job

Sample the whole machine, not the job:

```bash
a=$(head -1 /proc/stat); sleep 1; b=$(head -1 /proc/stat)
paste -d' ' <(echo "$a") <(echo "$b") | awk '{h=NF/2; for(i=2;i<=9;i++) t+=$(i+h)-$i; d=$(5+h)+$(6+h)-$5-$6; printf "machine CPU %.0f%%\n", 100*(t-d)/t}'
top -bn2 -d1 | grep '%Cpu' | tail -1    # the second frame is a clean 1 s sample
free -g                                  # (total - available) / total stays at or under 0.70
```

If the machine stays above 50% with the job governed down to 1 CPU, or RAM goes above 70%, stop the job and rerun it later through `capped.sh`.
