#!/bin/sh
set -eu

cat fixtures/jsonl/events_drift.event_colon.jsonl \
  | jd drift --baseline expected/jd/events.fields.jsonl