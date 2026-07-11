# HANDOFF.md — Maestro Framework

## Current Status
- **Phase:** bootstrap → packaging (v0.3.0 complete; strategy set, skills refactor next)
- **Last worked on:** 2026-07-11 — Competitive analysis (OpenSpec), skill-first architecture decision, roadmap plan draft for handoff
- **Active branch:** `main`
- **Version:** v0.3.0 (Milestone 1.5 complete)
- **Next priorities:** Confirm 5 strategy decisions (D17–D21, proposed) → promote plan via /mae-plan → WS1 skill-first refactor (spike: mae-explore as SKILL.md). M2 (PoC workflow) + M3 (docs) continue in parallel.
- **Blockers:** None

## Recent Changes (2026-07-11) — Sessions 014 + 015

### Competitive Analysis (014-competition)
- OpenSpec comparison: overlap narrower than feared — Maestro uncontested in exploration, decision governance, state continuity, PM persona; OpenSpec wins on living spec + validating CLI + distribution
- Proposed positioning: complement/superset of OpenSpec, interop over competition ("Maestro plans it, OpenSpec executes it")
- Pitch doc: `.sessions/014-competition/03-why-maestro-pitch.md`

### Skills Architecture (015-skills)
- Agent Skills / SKILL.md is an open standard (agentskills.io, Dec 2025; 30+ tools incl. Claude Code, Codex CLI, Cursor, Gemini CLI) — proposed skill-first refactor: canonical logic → `.maestro/skills/*/SKILL.md`, slash commands become thin aliases
- Two-tier invocation preserves "user decides": explore/review/status auto-trigger; req/design/plan/decide suggest-only; do/sync/init slash-only
- Competitive roadmap plan (handoff entry point for next chat): `.sessions/015-skills/02-skill-spec-plan.md` — 5 workstreams: skills refactor, living-doc lifecycle, CLI validate, OpenSpec interop, app

### Proposed Decisions (D17–D21, pending confirmation)
1. Skill-first architecture + two-tier invocation table
2. Complement/superset positioning vs OpenSpec
3. ADDED/MODIFIED/REMOVED delta format for canonical docs
4. `/sync` becomes the archive/merge step (living-doc lifecycle)
5. Capability-sharded requirements files

## Recent Changes (2026-06-19) — Session 010 continued

### Delivery Folder Restructure
- Added `docs/05-implementation/` — mae-do's output folder for implementation reports
- Renumbered: review→06, test→07, deploy→08, maintenance→09
- Updated across 13 files (MAESTRO.md, DESIGN.md, REQUIREMENTS.md, ROADMAP.md, install.sh, README.md, mae-do.md, mae-review.md, cursor rules, 3 docs files)

### Cursor Slash Commands
- Created `.cursor/commands/` with 17 command files (autocomplete-enabled)
- Installer now generates Cursor commands alongside rules
- Users get `/mae-explore` autocomplete in Cursor chat

### Other Changes
- Added `path/to/file.md` argument to mae-do (read task from file)
- Added ROADMAP status definitions to MAESTRO.md (☐/🔄/⏳/✅/⊘)
- Fixed task status icons in MAESTRO.md
- Removed .DS_Store from git tracking
- Installer: fixed silent failures in curl downloads, added MAESTRO.md verification
- ROADMAP: split 1.1 (done/remaining), marked 1.4, 1.5, 2.2 done
- All M1 items now ✅ done (1.1b silent failures fixed by user, 1.7 wizard synced by user)

## Changes (2026-06-18) — v0.2.0 Implementation

### Command Changes
- Renamed `mae-prd` → `mae-req` (output: REQUIREMENTS.md)
- Renamed output: `SDD.md` → `DESIGN.md`
- Absorbed `mae-checkpoint` into `sync` (expanded scope: HANDOFF + ROADMAP status + DECISIONS + delta summary)
- Added `## Skip When` section to all delivery commands (soft guidance)
- Rewrote `mae-plan` — now owns ROADMAP lifecycle (create, enrich milestones, generate tasks)
- Updated `mae-do` — updates ROADMAP Status column after task completion

### Aliases (3-letter shortcuts)
| Canonical | Alias |
|-----------|-------|
| `mae-explore` | `mex` |
| `mae-req` | `mrq` |
| `mae-design` | `mds` |
| `mae-plan` | `mpl` |
| `mae-do` | `mdo` |
| `mae-review` | `mrv` |

### File/Folder Structure
- `docs/02-prd/` → `docs/02-requirements/` (REQUIREMENTS.md)
- `docs/03-design/` → `docs/03-design/` (DESIGN.md, was SDD.md)
- `docs/05-implementation/` added (mae-do output)
- Folders renumbered: review→06, test→07, deploy→08, maintenance→09
- `ROADMAP.md` moved from root → `docs/04-plan/ROADMAP.md`
- ROADMAP now has Status column: ☐ todo | 🔄 in progress | ⏳ blocked | ✅ done | ⊘ dropped
- PLAN.md eliminated — execution notes go into ROADMAP milestone sections
- Templates renamed: `prd.md` → `requirements.md`, `sdd.md` → `design.md`

### Multi-Tool Support
- Added `.cursor/rules/maestro-core.mdc` + `maestro-dispatch.mdc` (always-apply rules)
- Added `.cursor/commands/` — 17 slash command files (autocomplete in Cursor)
- Updated `install.sh` — creates Cursor rules + commands, alias files, simplified setup flow
- Updated `.github/copilot-instructions.md` for Codex

## Project Overview
- **Name:** Maestro
- **Description:** AI-assisted delivery framework. 7 delivery commands + 4 utility commands + 6 aliases. Sessions-first workflow, decision tracking, task management via markdown files.
- **Stack:** Markdown-first (commands as `.md` files), TOML config (`maestro.toml`), future CLI in Python
- **Multi-tool:** Claude Code (`.claude/commands/`), Cursor (`.cursor/rules/` + `.cursor/commands/`), Codex (`.github/copilot-instructions.md`)

## Architecture Decisions
| Decision | Choice | Rationale |
|----------|--------|-----------|
| Framework name | Maestro (`mae-`) | Music theme, fits Symphony platform |
| Config format | TOML | Python native, no indent bugs |
| Command naming | Activity-based (`mae-req`, `mae-design`) | Universal, not tied to doc format names |
| Artifact naming | Universal terms (`REQUIREMENTS.md`, `DESIGN.md`) | Works across companies regardless of internal naming |
| Artifact flow | Sessions-first | All output to .sessions/, promote to docs/ when ready |
| ROADMAP location | `docs/04-plan/ROADMAP.md` | Consistent with docs folder convention |
| PLAN.md | Eliminated — merged into ROADMAP | One file for strategic + tactical view |
| Checkpoint | Absorbed into `/sync` | Sync is the natural end-of-session save point |
| Aliases | 3-letter shortcuts (mex, mrq, mds, mpl, mdo, mrv) | Faster typing; canonical names for docs |
| Skip guidance | Soft — agent suggests, user decides | Framework guides but never blocks |
| Delivery folders | 9 folders (01-explore through 09-maintenance) | 05-implementation gives mae-do its own output space |
| Cursor commands | `.cursor/commands/` for autocomplete | Matches Cursor's native slash command mechanism |

## Commands
### Delivery (7)
| Command | Alias | Purpose |
|---------|-------|---------|
| `/mae-init` | — | Profile setup after installation |
| `/mae-explore` | `mex` | Build understanding — smart default, targeted, ask, doc |
| `/mae-req` | `mrq` | Formalize requirements from explore report |
| `/mae-design` | `mds` | Technical architecture from requirements |
| `/mae-plan` | `mpl` | Create/update ROADMAP, generate task files |
| `/mae-do` | `mdo` | Execute tasks (planned, ad-hoc, or from file) |
| `/mae-review` | `mrv` | Review code or artifacts |

### Utility (4)
| Command | Purpose |
|---------|---------|
| `/decide` | Record decision in audit trail |
| `/sync` | End-of-session save — update HANDOFF, ROADMAP status, DECISIONS, checkpoint |
| `/status` | Project overview + sub-commands (tasks, decisions, questions) |
| `/md` | Save response to session file |

## Key Files
| File | Location |
|------|----------|
| Framework instructions | `MAESTRO.md` |
| Project config | `CLAUDE.md` |
| Framework settings | `maestro.toml` |
| Explore artifacts | `docs/01-explore/` |
| Requirements | `docs/02-requirements/REQUIREMENTS.md` |
| Design/Architecture | `docs/03-design/DESIGN.md` |
| Roadmap | `docs/04-plan/ROADMAP.md` |
| Tasks | `docs/04-plan/tasks/` |
| Implementation reports | `docs/05-implementation/` |
| Templates | `.maestro/templates/` (requirements, design, explore, task, summary, report, roadmap) |
| Framework commands | `.maestro/commands/` |
| Claude Code adapters | `.claude/commands/` (wrappers + aliases) |
| Cursor adapters | `.cursor/rules/` (core + dispatch) + `.cursor/commands/` (slash commands) |
