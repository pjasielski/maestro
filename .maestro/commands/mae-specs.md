# /mae-specs — Build the Specs

Routing only: decides which spec parts to run and runs their commands as one chain. Never restates a part's protocol — each lives in its own command file.

$ARGUMENTS — optional: a part (`requirements`/`req`, `design`, `architecture`/`arch`) plus its arguments

## Usage

```
/mae-specs                              missing + relevant parts, one question round, one review
/mae-specs requirements   (or req)      → /mae-requirements
/mae-specs design                       → /mae-design (visual system)
/mae-specs architecture   (or arch)     → /mae-architecture
/mae-specs architecture {component}     → /mae-architecture {component}
```

## Behavior

### With a part
Run that command with the remaining arguments. Regenerating an existing part is allowed here: it's deliberate.

### Bare
1. **Select parts**, in this order, from the state probe (`.maestro/commands/mae-help.md`):

   | Part | Included when |
   |---|---|
   | requirements | REQUIREMENTS.md missing |
   | design | DESIGN.md missing **and** the project has a UI (EXPLORE.md, REQUIREMENTS.md or `mock/`) |
   | architecture | ARCHITECTURE.md missing. Only if the profile or conversation suggests the user isn't a developer, ask in the question round: "Architecture too, or leave it for a developer?" |

2. **Nothing selected** → "All specs exist. Changes: `/mae-scope`. Regenerate one part: `/mae-specs {part}`." Stop. Bare never regenerates an existing part.
3. **One part** → run its command.
4. **Several parts** → chain them under the `mae-run.md` rules: one question round first (each part's question step in collect mode), each part reads the previous part's session draft, one review before promotion, one report.
5. Architecture skipped → end with: "Hand-off: a developer runs `/mae-specs architecture`."

## Skip When
- PoC track (one milestone, speed over reviewability) → `/mae-poc`
