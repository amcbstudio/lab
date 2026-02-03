#!/bin/sh
set -eu
cat fixtures/kv/headers.txt | kv parse --delim colon --trim | jsonl pretty