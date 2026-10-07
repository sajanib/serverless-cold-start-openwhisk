#!/usr/bin/env bash
# Deploys a uniquely named action on each iteration and invokes it twice.
# The first call is always cold (the action has never run). The second is
# expected to be warm, but see the README for the cases where it was not.
#
# Requires: the OpenWhisk auth key (user:password) in $KEY_FILE.
# In my setup the controller API was reachable on localhost:8080.

set -euo pipefail

KEY_FILE="${KEY_FILE:-/tmp/k.txt}"
API="${API:-http://localhost:8080/api/v1/namespaces/_}"
RUNS="${RUNS:-25}"
LOG="${LOG:-/tmp/r5.log}"

AUTH=$(cat "$KEY_FILE")

for i in $(seq 1 "$RUNS"); do
  # deploy a fresh action, hello1 ... hello25
  curl -sk -u "$AUTH" -X PUT -H "Content-Type: application/json" \
    -d @action.json "$API/actions/hello$i?overwrite=true" > /dev/null

  # first invocation (cold)
  curl -sk -u "$AUTH" -X POST -H "Content-Type: application/json" \
    -d '{"name":"Sajani"}' "$API/actions/hello$i?blocking=true" >> "$LOG"
  echo >> "$LOG"

  # second invocation, immediately after (expected warm)
  curl -sk -u "$AUTH" -X POST -H "Content-Type: application/json" \
    -d '{"name":"Sajani"}' "$API/actions/hello$i?blocking=true" >> "$LOG"
  echo >> "$LOG"
done
