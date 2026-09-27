---
name: mae-specs
description: >-
  Write the project's specs in docs/02-specs/: REQUIREMENTS.md (what and why), DESIGN.md
  (visual system, when there is a UI) and ARCHITECTURE.md (how it's built), building only
  the parts that are missing. Use when the user wants to formalize requirements, define
  the look and feel, design the architecture, or turn exploration into a spec, even if
  they never say "specs". Also handles /mae-specs, msp, /mae-requirements, mrq,
  /mae-design, mds, /mae-architecture, mar. Do NOT use to explore an unclear idea
  (mae-explore), change specs that are already signed (mae-scope), write a one-file PoC
  spec (mae-poc), or plan tasks (mae-plan). Propose first; produce only after the user confirms.
license: MIT
compatibility: >-
  Requires a project initialized with Maestro (.maestro/, HANDOFF.md, .sessions/).
  Any Agent Skills client (Claude Code, Cursor, Codex CLI).
metadata:
  maestro-tier: suggest
  maestro-command: /mae-specs
  maestro-aliases: msp
  maestro-version: "0.5.0"
---

# mae-specs — Build the Specs

Routing only: decides which spec parts to run and runs them as one chain. Each part's protocol lives once, in `references/{part}.md`, loaded only when that part runs; `/mae-requirements`, `/mae-design` and `/mae-architecture` are entry points to the same files.

$ARGUMENTS — optional: a part (`requirements`/`req`, `design`, `architecture`/`arch`) plus its arguments

## Gate (auto-invocation only)

When you chose this skill yourself, write nothing and say one line: "This looks like spec work. Want me to run `/mae-specs`? (yes / not now)". Proceed only when the user typed the command or confirmed.

## Usage

```
/mae-specs                              missing + relevant parts, one question round, one review
/mae-specs requirements   (or req)      → references/requirements.md   (= /mae-requirements)
/mae-specs design                       → references/design.md         (= /mae-design, visual system)
/mae-specs architecture   (or arch)     → references/architecture.md   (= /mae-architecture)
/mae-specs architecture {component}     → references/architecture.md, component mode
```

## Behavior

### With a part
Follow `references/{part}.md` with the remaining arguments. Regenerating an existing part is allowed here: it's deliberate.

### Bare
1. **Select parts**, in this order, from the state probe (`.maestro/commands/mae-help.md`):

   | Part | Included when |
   |---|---|
   | requirements | REQUIREMENTS.md missing |
   | design | DESIGN.md missing **and** the project has a UI (EXPLORE.md, REQUIREMENTS.md or `mock/`) |
   | architecture | ARCHITECTURE.md missing. Only if the profile or conversation suggests the user isn't a developer, ask in the question round: "Architecture too, or leave it for a developer?" |

2. **Nothing selected** → "All specs exist. Changes: `/mae-scope`. Regenerate one part: `/mae-specs {part}`." Stop. Bare never regenerates an existing part.
3. **One part** → follow its reference file.
4. **Several parts** → chain them under the `mae-run.md` rules: one question round first (each part's question step in collect mode), each part reads the previous part's session draft, one review before promotion, one report.
5. Architecture skipped → end with: "Hand-off: a developer runs `/mae-specs architecture`."

## Skip When
- PoC track (one milestone, speed over reviewability) → `/mae-poc`
