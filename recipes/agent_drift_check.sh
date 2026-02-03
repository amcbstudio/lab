#!/bin/sh
set -eu

# Ensure baseline exists
if [ ! -f baseline/agent/run_0001.fields.jsonl ]; then
  echo "baseline missing; run: make agent_baseline" >&2
  exit 2
fi

echo "-- drift run_0002 vs baseline (expect drift => exit 1)"
set +e
cat fixtures/agent/run_0002_drift.jsonl | jd drift --baseline baseline/agent/run_0001.fields.jsonl
rc=$?
set -e

if [ "$rc" -ne 1 ]; then
  echo "unexpected: drift rc=$rc (expected 1)" >&2
  exit 1
fi
