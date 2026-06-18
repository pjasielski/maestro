# HANDOFF.md — Maestro Framework

## Current Status
- **Phase:** bootstrap → packaging (v0.2.0)
- **Last worked on:** 2026-06-18 — v0.2 implementation (command renames, aliases, Cursor support, ROADMAP restructure)
- **Active branch:** `dev`
- **Version:** v0.2.0
- **Next priorities:** Installer simplification (item 1.1), remaining Milestone 1 items
- **Blockers:** None

## Recent Changes (2026-06-18) — v0.2.0

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
- `delivery/02-prd/` → `delivery/02-requirements/` (REQUIREMENTS.md)
- `delivery/03-design/` → `delivery/03-design/` (DESIGN.md, was SDD.md)
- `ROADMAP.md` moved from root → `delivery/04-plan/ROADMAP.md`
- ROADMAP now has Status column: ☐ todo | 🔄 in progress | ⏳ blocked | ✅ done | ⊘ dropped
- PLAN.md eliminated — execution notes go into ROADMAP milestone sections
- Templates renamed: `prd.md` → `requirements.md`, `sdd.md` → `design.md`

### Multi-Tool Support
- Added `.cursor/rules/maestro-core.mdc` + `maestro-dispatch.mdc`
- Updated `install.sh` — creates Cursor adapters, alias files, simplified setup flow
- Updated `.github/copilot-instructions.md` for Codex

## Previous Changes (2026-06-10)
- Created ROADMAP.md (5 milestones + future items)
- Reconciled PRD.md and SDD.md — promoted to delivery/
- Implemented Milestone 1 items (sessions standardization, version tagging)

## Previous Changes (2026-05-20)
- Added output tiers (-v/-c) to MAESTRO.md
- Rewrote install.sh: interactive prompts, Cursor + Codex support
- Created setup wizard (setup/index.html + setup/server.py)

## Project Overview
- **Name:** Maestro
- **Description:** AI-assisted delivery framework. 7 delivery commands + 4 utility commands + 6 aliases. Sessions-first workflow, decision tracking, task management via markdown files.
- **Stack:** Markdown-first (commands as `.md` files), TOML config (`maestro.toml`), future CLI in Python
- **Multi-tool:** Claude Code (`.claude/commands/`), Cursor (`.cursor/rules/`), Codex (`.github/copilot-instructions.md`)

## Architecture Decisions
| Decision | Choice | Rationale |
|----------|--------|-----------|
| Framework name | Maestro (`mae-`) | Music theme, fits Symphony platform |
| Config format | TOML | Python native, no indent bugs |
| Command naming | Activity-based (`mae-req`, `mae-design`) | Universal, not tied to doc format names |
| Artifact naming | Universal terms (`REQUIREMENTS.md`, `DESIGN.md`) | Works across companies regardless of internal naming |
| Artifact flow | Sessions-first | All output to .sessions/, promote to delivery/ when ready |
| ROADMAP location | `delivery/04-plan/ROADMAP.md` | Consistent with delivery folder convention |
| PLAN.md | Eliminated — merged into ROADMAP | One file for strategic + tactical view |
| Checkpoint | Absorbed into `/sync` | Sync is the natural end-of-session save point |
| Aliases | 3-letter shortcuts (mex, mrq, mds, mpl, mdo, mrv) | Faster typing; canonical names for docs |
| Skip guidance | Soft — agent suggests, user decides | Framework guides but never blocks |

## Commands
### Delivery (7)
| Command | Alias | Purpose |
|---------|-------|---------|
| `/mae-init` | — | Profile setup after installation |
| `/mae-explore` | `mex` | Build understanding — smart default, targeted, ask, doc |
| `/mae-req` | `mrq` | Formalize requirements from explore report |
| `/mae-design` | `mds` | Technical architecture from requirements |
| `/mae-plan` | `mpl` | Create/update ROADMAP, generate task files |
| `/mae-do` | `mdo` | Execute tasks (planned or ad-hoc) |
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
| Explore artifacts | `delivery/01-explore/` |
| Requirements | `delivery/02-requirements/REQUIREMENTS.md` |
| Design/Architecture | `delivery/03-design/DESIGN.md` |
| Roadmap | `delivery/04-plan/ROADMAP.md` |
| Tasks | `delivery/04-plan/tasks/` |
| Templates | `templates/` (requirements, design, explore, task, summary, report, roadmap) |
| Framework commands | `.maestro/commands/` |
| Claude Code adapters | `.claude/commands/` (wrappers + aliases) |
| Cursor adapters | `.cursor/rules/` (core + dispatch) |
