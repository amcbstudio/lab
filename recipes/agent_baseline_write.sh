#!/bin/sh
set -eu

mkdir -p baseline/agent
cat fixtures/agent/run_0001.jsonl | jd fields > baseline/agent/current.fields.jsonl
echo "wrote baseline/agent/current.fields.jsonl"
