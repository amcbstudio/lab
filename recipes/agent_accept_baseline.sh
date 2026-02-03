#!/bin/sh
set -eu

in="${1:-fixtures/agent/run_0002_drift.jsonl}"

mkdir -p baseline/agent
cat "$in" | jd fields > baseline/agent/current.fields.jsonl
echo "baseline updated: baseline/agent/current.fields.jsonl"
