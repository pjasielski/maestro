# Skill trigger eval

Checks whether a Maestro skill's `description` triggers on the prompts it should and stays quiet on near-misses. Method from agentskills.io "Optimizing skill descriptions": about 20 labelled queries, 3 runs each, pass threshold 0.5.

## Run

```bash
docs/07-test/skill-trigger-eval/trigger-eval.sh docs/07-test/skill-trigger-eval/mae-explore.queries.json
```

Requires `claude` and `jq`. Runs from the repo root so the project skills are discoverable. Prints one JSON object per query with its trigger rate.

## Add a skill

Create `{skill}.queries.json` next to this file: 8–10 `should_trigger: true` prompts (vary phrasing, explicitness, length) and 8–10 `should_trigger: false` near-misses that share keywords but need an adjacent skill or a direct answer. Do not fix a failing query by pasting its words into the description; fix the category it represents.

## Reading results

- A should-trigger query below 0.5: the description is too narrow, or the intent is covered by another skill's description. Broaden the intent list.
- A should-not query above 0.5: the description is too broad. Add the near-miss to the "Do NOT use" clause and name the skill that should take it.
