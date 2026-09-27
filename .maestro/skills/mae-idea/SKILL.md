---
name: mae-idea
description: >-
  Park a "maybe later" idea as one row in docs/01-explore/IDEAS.md without interrupting
  the current work. Use when the user mentions something they might want later, a nice-to-have
  or a side thought mid-task, or asks to note an idea for later, even if they never say
  "idea". Also handles /mae-idea. Do NOT use for a change to what was agreed with the
  client (mae-scope), to explore an idea now (mae-explore), or to record a decision
  (decide). Propose first; produce only after the user confirms.
license: MIT
compatibility: >-
  Requires a project initialized with Maestro (.maestro/, HANDOFF.md, .sessions/).
  Any Agent Skills client (Claude Code, Cursor, Codex CLI).
metadata:
  maestro-tier: suggest
  maestro-command: /mae-idea
  maestro-version: "0.5.0"
---

# mae-idea — Park an Idea

Capture a "maybe later" in one line without interrupting the work. **Scope** is a change to what was agreed and needs a decision (`/mae-scope`); an **idea** is maybe-later and needs none.

**Artifact** (MAESTRO.md § Artifact Capture): one row in `docs/01-explore/IDEAS.md`; nothing else.

$ARGUMENTS — required: the idea, in quotes

## Gate (auto-invocation only)

When you chose this skill yourself, write nothing and offer in one line: "Park this as an idea?" Append the row only when the user typed the command or said yes.

## Behavior

1. Open `docs/01-explore/IDEAS.md`; create it from `.maestro/templates/ideas.md` if missing
2. Append `| I-NN | {YYYY-MM-DD} | {idea, one line} | {current session NNN-name} | new |` (NN = highest existing + 1, zero-padded)
3. Reply exactly: "Parked as I-NN. `/mae-explore I-NN` to explore it now."

## Rules

- Never asks, never explores, writes nothing else (no session file, no report). No argument → reply with the usage line
- Append-only: never edit other rows. Status changes: `exploring` by `/mae-explore I-NN`, `promoted → {id}` by `/mae-scope` or `/mae-specs`, `dropped ({why})` by the user

## Skip When
- It changes what was agreed with the client → `/mae-scope`
