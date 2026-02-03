#!/bin/sh
set -eu

if ./bin/jd scan < fixtures/jsonl/events_broken.syntax.jsonl >/dev/null 2>&1; then
  echo "ERROR: jd scan passed invalid JSON" >&2
  exit 1
fi

echo "OK: jd scan rejected invalid JSON"
