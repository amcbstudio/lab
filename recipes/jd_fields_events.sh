#!/bin/sh
set -eu

# Runs jd fields against the canonical events fixture.
# Observational output; no assertions here (golden lives in expected/ if you choose).
exec ./bin/jd fields < fixtures/jsonl/events.jsonl
