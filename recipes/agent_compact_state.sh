#!/bin/sh
set -eu

mkdir -p out/agent

# 1) state.json: only capture decisions and counters in a stable structure
# We do this with jq for the demo (Mac usually has it; if not, we can rework).
# - decisions => state.decisions[key] = value
# - counters  => state.counters[key] += delta
cat fixtures/agent/run_0002_drift.jsonl | jq -s '
  reduce .[] as $o (
    {decisions:{}, counters:{}};
    if $o.type == "decision" then
      .decisions[$o.key] = $o.value
    elif $o.type == "counter" then
      .counters[$o.key] = ((.counters[$o.key] // 0) + ($o.delta // 0))
    else
      .
    end
  )
' > out/agent/state.json

# 2) MEMORY.md: 3-bullet “diff note” style from this run
# Very simple: list drift events detected vs baseline if available
{
  echo "# MEMORY (agent demo)"
  echo
  echo "## Run 0002 notes"
  echo "- Captured decisions + counters into state.json"
  if [ -f baseline/agent/run_0001.fields.jsonl ]; then
    echo "- Drift summary:"
    # capture drift events (ignore summary line)
    set +e
    cat fixtures/agent/run_0002_drift.jsonl | jd drift --baseline baseline/agent/run_0001.fields.jsonl | jq -r '
      select(.type != "summary") |
      "- " + (.type + " " + (.field // "") + (if .from then " from=" + .from + " to=" + .to else "" end) + (if .line then " line=" + (.line|tostring) else "" end))
    '
    set -e
  else
    echo "- No baseline available to compute drift."
  fi
} > out/agent/MEMORY.md

echo "wrote out/agent/state.json and out/agent/MEMORY.md"
