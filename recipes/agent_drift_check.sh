#!/bin/sh
set -eu

mkdir -p out/agent

if [ ! -f baseline/agent/current.fields.jsonl ]; then
  echo "baseline missing; run: make agent_baseline" >&2
  exit 2
fi

echo "-- drift vs baseline (expect drift => exit 1 when drift exists)"
set +e
cat fixtures/agent/run_0002_drift.jsonl | jd drift --baseline baseline/agent/current.fields.jsonl > out/agent/drift.jsonl
rc=$?
set -e

# rc meanings:
# 0 no drift
# 1 drift detected
# 2 error
if [ "$rc" -eq 2 ]; then
  echo "jd drift error" >&2
  exit 2
fi

echo "wrote out/agent/drift.jsonl (rc=$rc)"
exit "$rc"
