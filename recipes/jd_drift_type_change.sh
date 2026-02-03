#!/bin/sh
set -eu

if ./bin/jd drift < fixtures/jsonl/events_drift.type_change.jsonl >/dev/null 2>&1; then
  echo "ERROR: expected jd drift to exit non-zero when drift is detected" >&2
  exit 1
fi

./bin/jd drift < fixtures/jsonl/events_drift.type_change.jsonl || true
echo "OK: jd drift detected drift (non-zero exit)"
