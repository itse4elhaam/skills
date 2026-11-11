#!/usr/bin/env bash
# Pull a file from a boxes.dev devbox to the workstation and check its md5.
# There is no box-to-workstation `dvb cp`, scp through `dvb ssh proxy` can't forward port 22,
# and `dvb exec` keeps at most 4 MiB of stdout. So: base64 3 MB pieces through exec, 6 at a time.
# Usage: pull.sh <instanceId> <remote-path> <local-path> [project-fingerprint, else $FP]
set -euo pipefail
B=$1; R=$2; L=$3; FP=${4:-${FP:?pass the project fingerprint as arg 4 or in FP}}
T=$(mktemp -d); trap 'rm -r -- "$T"' EXIT
info=$(dvb exec --project "$FP" --target "$B" --cwd project --json -- bash -lc "stat -c %s '$R' && md5sum '$R'" | jq -r .data.stdout)
size=$(sed -n 1p <<<"$info"); rmd5=$(sed -n 2p <<<"$info" | cut -d' ' -f1)
[ -n "$rmd5" ] || { echo "cannot read $R on $B" >&2; exit 1; }
n=$(( (size + 2999999) / 3000000 ))
get() {
  dvb exec --project "$FP" --target "$B" --cwd project --timeout 5m --max-output-bytes 4194304 --json -- \
    bash -lc "dd if='$R' bs=3000000 skip=$1 count=1 status=none | base64 -w0" |
    jq -er 'if .data.stdoutTruncated then error("truncated") else .data.stdout end' | base64 -d > "$T/$(printf %05d "$1")"
}
export -f get; export FP B R T
seq 0 $((n - 1)) | xargs -P 6 -I{} bash -c 'get {}'
cat "$T"/* > "$L.part"
lmd5=$(md5sum "$L.part" | cut -d' ' -f1)
[ "$lmd5" = "$rmd5" ] || { echo "md5 mismatch: remote $rmd5, local $lmd5" >&2; rm -f -- "$L.part"; exit 1; }
mv -- "$L.part" "$L"; echo "pulled $L ($size bytes, md5 $rmd5)"
