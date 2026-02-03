#!/bin/sh
set -eu

echo "-- scan run_0001"
cat fixtures/agent/run_0001.jsonl | jd scan

echo "-- scan run_0002 (drift file is still valid JSONL)"
cat fixtures/agent/run_0002_drift.jsonl | jd scan
