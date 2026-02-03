#!/bin/sh
set -eu

mkdir -p baseline/agent
cat fixtures/agent/run_0001.jsonl | jd fields > baseline/agent/run_0001.fields.jsonl
echo "wrote baseline/agent/run_0001.fields.jsonl"
