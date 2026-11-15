#!/usr/bin/env bash
# Run one heavy command on this laptop inside Elhaam's caps (15 Nov 2026):
# the whole machine stays at or under 50% CPU and 70% RAM.
#
# Order: queue on a flock, wait while RAM use is above 60%, sample the current
# load, compute the caps, run the command in a systemd user scope (MemoryMax,
# no swap), pinned with taskset to the least-busy CPUs, at nice 19 / ionice idle,
# while a governor shrinks or regrows the CPU set as the machine's load moves.
# Caps and governor changes go to stderr. Exits with the command's exit code (137: killed at the cap).
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
usage: capped.sh [--cpus N] [--mem SIZE] [--lock NAME] -- <cmd...>
  --cpus N     at most N CPUs (default: the budget, floor(nproc/2) minus CPUs busy now)
  --mem SIZE   at most SIZE, IEC suffix K/M/G/T, e.g. 512M, 12G (default: the budget,
               70% of RAM minus RAM used now)
  --lock NAME  queue name (default: heavy, shared by every agent)
The command sees CAPPED_CPUS, CAPPED_MEM (bytes) and OMP/MKL/OPENBLAS_NUM_THREADS.
EOF
  exit "${1:-0}"
}
log() { echo "capped: $*" >&2; }
die() { log "$*"; exit 2; }

want_cpus='' want_mem='' lock=heavy
while [ $# -gt 0 ]; do
  case $1 in
    --cpus|--mem|--lock) [ $# -ge 2 ] || die "$1 needs a value" ;;&
    --cpus) want_cpus=$2; shift 2 ;;
    --mem)  want_mem=$2;  shift 2 ;;
    --lock) lock=$2;      shift 2 ;;
    -h|--help) usage 0 ;;
    --) shift; break ;;
    *) die "unknown option '$1'; put the command after --" ;;
  esac
done
[ $# -gt 0 ] || usage 2
if [ -n "$want_cpus" ]; then
  [[ $want_cpus =~ ^[1-9][0-9]*$ ]] || die "--cpus wants a positive integer, got '$want_cpus'"
fi
if [ -n "$want_mem" ]; then
  want_mem_b=$(numfmt --from=iec "${want_mem^^}" 2>/dev/null) || die "--mem wants a size like 512M or 12G, got '$want_mem'"
  want_mem_b=${want_mem_b%.*}
fi
[[ $lock =~ ^[A-Za-z0-9._-]+$ ]] || die "--lock wants a plain name, got '$lock'"

# 1. One capped job at a time per queue. The lock lives in this shell, not the command.
lock_dir=${XDG_CACHE_HOME:-$HOME/.cache}/capped
mkdir -p "$lock_dir"
exec 9>"$lock_dir/$lock.lock"
if ! flock -n 9; then
  log "waiting for the '$lock' queue"
  flock 9
fi

# 2. Wait while the machine's RAM use (total - available) is above 60%.
mem_used_pct() { awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2} END{printf "%d", (t-a)*100/t}' /proc/meminfo; }
while [ "$(mem_used_pct)" -gt 60 ]; do
  log "RAM $(mem_used_pct)% used, above 60%; waiting"
  sleep 30
done

# 3. Sample CPU load for 1.5 s. Busy = everything but idle and iowait; guest time
#    is already inside user/nice, so only fields 2..9 (user..steal) count.
a=$(grep '^cpu' /proc/stat); sleep 1.5; b=$(grep '^cpu' /proc/stat)
sample=$(paste -d' ' <(echo "$a") <(echo "$b") | awk '{
  h = NF / 2; dt = 0
  for (i = 2; i <= 9; i++) dt += $(i + h) - $i
  di = ($(5 + h) + $(6 + h)) - ($5 + $6)
  busy = dt > 0 ? (dt - di) / dt : 0
  if ($1 == "cpu") printf "all %.4f\n", busy; else printf "%s %.4f\n", substr($1, 4), busy
}')
ncpu=$(grep -c '^cpu[0-9]' /proc/stat)
busy=$(awk '$1 == "all" {print $2}' <<<"$sample")
busy_cpus=$(awk -v b="$busy" -v n="$ncpu" 'BEGIN {x = b * n; c = int(x); if (x > c) c++; print c}')
cpu_budget=$(( ncpu / 2 - busy_cpus ))
[ "$cpu_budget" -ge 1 ] || cpu_budget=1
cpus=$cpu_budget
if [ -n "$want_cpus" ] && [ "$want_cpus" -lt "$cpus" ]; then cpus=$want_cpus; fi
order=$(awk '$1 != "all"' <<<"$sample" | sort -k2,2g -k1,1n | cut -d' ' -f1 | paste -sd' ')   # idlest first
pick() { tr ' ' '\n' <<<"$order" | awk -v n="$1" 'NR <= n' | sort -n | paste -sd,; }
cpulist=$(pick "$cpus")

read -r total avail < <(awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2} END{printf "%.0f %.0f\n", t*1024, a*1024}' /proc/meminfo)
used=$(( total - avail ))
mem_budget=$(( total * 7 / 10 - used ))
[ "$mem_budget" -gt 0 ] || die "RAM is already above 70% used; nothing left to give"
mem=$mem_budget
if [ -n "$want_mem" ] && [ "$want_mem_b" -lt "$mem" ]; then mem=$want_mem_b; fi

iec() { numfmt --to=iec --format=%.1f "$1"; }
asked=''
[ -n "$want_cpus" ] && asked+=" asked $want_cpus CPUs,"
[ -n "$want_mem" ] && asked+=" asked $want_mem RAM,"
log "machine now: CPU $(awk -v b="$busy" 'BEGIN{printf "%.0f", b*100}')% ($busy_cpus of $ncpu CPUs busy), RAM $(( used * 100 / total ))% of $(iec "$total") used"
log "job gets: $cpus CPUs [$cpulist], $(iec "$mem") RAM, no swap, nice 19, ionice idle;$asked budget $cpu_budget CPUs / $(iec "$mem_budget"), queue '$lock', CPU governor every 5 s"

# 4. Live CPU governor. Every 5 s it measures the whole machine. Above 50% it
#    shrinks the job by 1 CPU per CPU-share over (5 points on 20 CPUs), rounded
#    up, to at least 1; below 40% it grows the job by 1 CPU, up to the start
#    allocation. It re-pins only the processes in the job's own scope cgroup and
#    exits when the scope is gone or this script is.
unit="capped-$lock-$$"
machine_ticks() { awk '/^cpu /{t = 0; for (i = 2; i <= 9; i++) t += $i; print t, $5 + $6}' /proc/stat; }
govern() {
  set +e
  local cg='' k=$cpus new list pm drop p t0 i0 t1 i1 nap=''
  trap 'kill "$nap" 2>/dev/null; exit 0' TERM
  for _ in $(seq 50); do
    cg=$(systemctl --user show -p ControlGroup --value "$unit.scope" 2>/dev/null)
    [ -n "$cg" ] && [ -e "/sys/fs/cgroup$cg/cgroup.procs" ] && break
    cg=''; sleep 0.2
  done
  [ -n "$cg" ] || return 0
  cg=/sys/fs/cgroup$cg
  read -r t0 i0 < <(machine_ticks)
  while kill -0 $$ 2>/dev/null && [ -e "$cg/cgroup.procs" ]; do
    sleep 5 & nap=$!; wait "$nap"
    read -r t1 i1 < <(machine_ticks)
    [ "$t1" -gt "$t0" ] || continue
    pm=$(( (t1 - t0 - (i1 - i0)) * 1000 / (t1 - t0) )); t0=$t1 i0=$i1   # machine busy, per mille
    new=$k
    if [ "$pm" -gt 500 ]; then
      drop=$(( ((pm - 500) * ncpu + 999) / 1000 ))
      new=$(( k - drop )); [ "$new" -ge 1 ] || new=1
    elif [ "$pm" -lt 400 ] && [ "$k" -lt "$cpus" ]; then
      new=$(( k + 1 ))
    fi
    [ "$new" -ne "$k" ] || continue
    list=$(pick "$new")
    while read -r p; do taskset -acp "$list" "$p" >/dev/null 2>&1; done < "$cg/cgroup.procs" 2>/dev/null
    log "$(date +%T) machine $(( pm / 10 )).$(( pm % 10 ))%: job $k -> $new CPUs [$list]"
    k=$new
  done
}

# 5. Run. Refuse to run uncapped if the scope can't be made.
systemd-run --user --scope --quiet --collect -p MemoryMax=64M true 2>/dev/null \
  || die "cannot create a systemd user scope (no user bus?); refusing to run without a memory cap"
export CAPPED_CPUS=$cpus CAPPED_MEM=$mem
export OMP_NUM_THREADS=$cpus MKL_NUM_THREADS=$cpus OPENBLAS_NUM_THREADS=$cpus
govern 9>&- </dev/null >&2 &
gov=$!
trap 'kill "$gov" 2>/dev/null || true' EXIT
rc=0
systemd-run --user --scope --quiet --collect --unit="$unit" -p MemoryMax="$mem" -p MemorySwapMax=0 -- \
  taskset -c "$cpulist" nice -n 19 ionice -c3 "$@" 9>&- || rc=$?
kill "$gov" 2>/dev/null; wait "$gov" 2>/dev/null || true
if [ "$rc" -eq 137 ]; then
  log "exit 137: killed (SIGKILL), most likely at the $(iec "$mem") memory cap"
else
  log "exit $rc"
fi
exit "$rc"
