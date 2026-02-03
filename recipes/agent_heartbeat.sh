#!/bin/sh
set -eu

in="${1:-fixtures/agent/run_0002_drift.jsonl}"

mkdir -p baseline/agent out/agent

# 1) Validate JSONL syntax
cat "$in" | jd scan > /dev/null

# 2) Ensure baseline exists
if [ ! -f baseline/agent/current.fields.jsonl ]; then
  cat "$in" | jd fields > baseline/agent/current.fields.jsonl
  echo "baseline initialized: baseline/agent/current.fields.jsonl"
fi

# 3) Drift check (capture output)
set +e
cat "$in" | jd drift --baseline baseline/agent/current.fields.jsonl > out/agent/drift.jsonl
rc=$?
set -e
if [ "$rc" -eq 2 ]; then
  echo "jd drift error" >&2
  exit 2
fi

# 4) Compact into state.json (decisions + counters)
cat "$in" | jq -s '
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

# 5) Write MEMORY.md (diff notes)
{
  echo "# MEMORY (agent demo)"
  echo
  echo "## Heartbeat note"
  echo "- input: $in"
  echo "- state.json updated (decisions+counters)"
  if [ "$rc" -eq 0 ]; then
    echo "- drift: none"
  else
    echo "- drift: detected"
    # print drift events as bullets (ignore summary)
    cat out/agent/drift.jsonl | jq -r '
      select(.type != "summary") |
      "- " + (.type + " " + (.field // "") + (if .from then " from=" + .from + " to=" + .to else "" end) + (if .line then " line=" + (.line|tostring) else "" end))
    '
  fi
} > out/agent/MEMORY.md

echo "wrote out/agent/state.json out/agent/MEMORY.md out/agent/drift.jsonl"
exit "$rc"
