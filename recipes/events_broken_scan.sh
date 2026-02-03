#!/bin/sh
set -eu
if cat fixtures/jsonl/events_broken.syntax.jsonl | jd scan >/dev/null; then
  echo "unexpected: scan passed" >&2
  exit 1
fi