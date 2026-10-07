#!/usr/bin/env bash
# Turns the activation records in the log into a CSV.
# initTime is only present when the invoker had to start a new container,
# so its presence marks a cold start and its absence a warm start.

set -euo pipefail
LOG="${1:-/tmp/r5.log}"

echo "run,duration_ms,init_time_ms,start_type"
jq -r -s '
  to_entries[] |
  (.value.annotations | map(select(.key=="initTime")) | .[0].value) as $init |
  [ (.key + 1), .value.duration, ($init // ""), (if $init then "cold" else "warm" end) ] | @csv
' "$LOG"

# quick check: number of cold starts
# grep -o '"initTime"' "$LOG" | wc -l
