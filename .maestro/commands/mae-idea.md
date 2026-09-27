# /mae-idea — Park an Idea

Capture a "maybe later" in one line without interrupting the work. **Scope** is a change to what was agreed and needs a decision (`/mae-scope`); an **idea** is maybe-later and needs none.

$ARGUMENTS — required: the idea, in quotes

## Behavior

1. Open `docs/01-explore/IDEAS.md`; create it from `.maestro/templates/ideas.md` if missing
2. Append `| I-NN | {YYYY-MM-DD} | {idea, one line} | {current session NNN-name} | new |` (NN = highest existing + 1, zero-padded)
3. Reply exactly: "Parked as I-NN. `/mae-explore I-NN` to explore it now."

## Rules

- Never asks, never explores, writes nothing else (no session file, no report). No argument → reply with the usage line
- Append-only: never edit other rows. Status changes: `exploring` by `/mae-explore I-NN`, `promoted → {id}` by `/mae-scope` or `/mae-specs`, `dropped ({why})` by the user
- When a new want comes up mid-task that isn't a client commitment, offer in one line: "Park this as an idea?"

## Skip When
- It changes what was agreed with the client → `/mae-scope`
