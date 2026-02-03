#!/bin/sh
set -eu
cat fixtures/jsonl/events.jsonl | jd scan >/dev/null
cat fixtures/jsonl/events.jsonl | jsonl get user