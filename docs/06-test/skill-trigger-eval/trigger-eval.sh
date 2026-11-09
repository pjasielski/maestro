#!/bin/bash
# Trigger-rate eval for one skill. Usage: trigger-eval.sh <queries.json> [skill-name] [runs]
# Adapted from https://agentskills.io/skill-creation/optimizing-descriptions
set -u
QUERIES_FILE="${1:?Usage: $0 <queries.json> [skill-name] [runs]}"
SKILL_NAME="${2:-$(basename "$QUERIES_FILE" .queries.json)}"
RUNS="${3:-3}"

check_triggered() {
  local query="$1"
  claude -p "$query" --output-format json 2>/dev/null \
    | jq -e --arg skill "$SKILL_NAME" \
      'any(.messages[]?.content[]?; .type == "tool_use" and .name == "Skill" and .input.skill == $skill)' \
      > /dev/null 2>&1
}

count=$(jq length "$QUERIES_FILE")
for i in $(seq 0 $((count - 1))); do
  query=$(jq -r ".[$i].query" "$QUERIES_FILE")
  should_trigger=$(jq -r ".[$i].should_trigger" "$QUERIES_FILE")
  triggers=0
  for run in $(seq 1 "$RUNS"); do
    check_triggered "$query" && triggers=$((triggers + 1))
  done
  jq -n --arg query "$query" --argjson should_trigger "$should_trigger" \
    --argjson triggers "$triggers" --argjson runs "$RUNS" \
    '{query: $query, should_trigger: $should_trigger, triggers: $triggers, runs: $runs, trigger_rate: ($triggers / $runs), pass: (if $should_trigger then ($triggers / $runs) > 0.5 else ($triggers / $runs) < 0.5 end)}'
done | jq -s '.'
