#!/bin/sh
set -eu
cat fixtures/kv/logfmt.txt | kv parse --delim equals | jsonl pretty