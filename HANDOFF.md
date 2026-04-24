# HANDOFF.md — Maestro Framework

## Current Status
- **Phase:** bootstrap → packaging (v0.3)
- **Last worked on:** 2026-04-22 — command review, explore overhaul, user/team profiles, utility command consolidation
- **Next priorities:** Test on a real project, create public repo, build Symphony app (lightweight version)
- **Blockers:** None

## Recent Changes (2026-04-22)
- Rewrote explore command: readiness signals (replace artifact count), context scanning, `ask` sub-command, questions as first-class output
- Created explore-lite variant for A/B testing (questions encouraged vs mandatory)
- Updated PRD command: prioritize final explore report, gap checking, user stories emphasis
- Updated design command: reads explore report for tech context, technical questionnaire before SDD, cross-phase awareness
- Added user/team profile support: `[user]` (solo) / `[[team.members]]` (team) in `maestro.toml`
- Dropped 5 utility commands (probe, question, recap, update-worklog, update-session) — now 4 utility commands
- Updated MAESTRO.md, README.md, user guide, init command

### Previous Changes (2026-04-20)
- Renamed all commands: colons → dashes (`/mae:explore` → `/mae-explore`), flat files
- Implemented sessions-first artifact flow
- Created templates: prd.md, sdd.md, explore.md (core + optional pattern)
- Created install.sh, README.md, docs/user-guide.md
- Created /mae-checkpoint command

## Project Overview
- **Name:** Maestro
- **Description:** AI-assisted delivery framework. 8 delivery commands + 4 utility commands. Sessions-first workflow, decision tracking, task management via markdown files. Designed for architects, developers, PMs, and founders.
- **Stack:** Markdown-first (commands as `.md` files), TOML config (`maestro.toml`), future CLI in Python
- **Platform vision:** Standalone framework → Symphony app (lightweight web/desktop app with editor, AI agent, file management)

## Architecture Decisions
| Decision | Choice | Rationale |
|----------|--------|-----------|
| Framework name | Maestro (`mae-`) | Music theme, fits Symphony platform |
| Config format | TOML | Python native, no indent bugs |
| Command naming | Dashes (`/mae-explore`) | Flat files, easier typing than colons |
| Artifact flow | Sessions-first | All output to sessions/, promote to delivery/ when ready |
| Explore behavior | Adaptive + readiness signals | Smart default, targeted, ask, doc modes |
| Templates | Core + optional pattern | HTML comments mark optional sections |
| User profile | `[user]` / `[[team.members]]` in maestro.toml | Optional, adapts agent behavior to expertise |
| Utility commands | 4 commands (decide, sync, status, md) | Reduced from 9; dropped commands absorbed by explore ask, status, and auto-triggers |

## Commands
### Delivery (8)
| Command | Purpose |
|---------|---------|
| `/mae-init` | Scaffold framework, configure mode and user profile |
| `/mae-explore` | Build understanding — smart default, targeted, ask, doc |
| `/mae-prd` | Formalize requirements from explore report |
| `/mae-design` | Technical architecture with questionnaire |
| `/mae-plan` | Break design into task files |
| `/mae-do` | Execute tasks (planned or ad-hoc) |
| `/mae-review` | Review code or artifacts |
| `/mae-checkpoint` | Save named project snapshots |

### Utility (4)
| Command | Purpose |
|---------|---------|
| `/decide` | Record decision in audit trail |
| `/sync` | Push decisions to canonical files |
| `/status` | Project overview + sub-commands (tasks, decisions, questions) |
| `/md` | Save response to session file |

## Key Files
| File | Location |
|------|----------|
| Framework instructions | `MAESTRO.md` |
| Project config | `CLAUDE.md` |
| Framework settings | `maestro.toml` |
| Explore artifacts | `delivery/01-explore/` |
| Requirements | `delivery/02-prd/PRD.md` |
| Architecture | `delivery/03-design/SDD.md` |
| Tasks | `delivery/04-plan/tasks/` |
| Templates | `templates/` (task, summary, report, prd, sdd, explore) |
| Session history | `sessions/001-framework-bootstrap/` |
| Design decisions | `sessions/001-framework-bootstrap/11_design_decisions_reference.md` |
| Latest report | `sessions/001-framework-bootstrap/15_implementation_report.md` |

## Open Considerations
- **PoC pathway:** Framework may feel too sequential; document alternative pathways (PoC-first, fast-track, iterative)
- **Init vs Install overlap:** Reconcile install.sh and mae-init so either entry point works for any user
- **Symphony app:** Lightweight web/desktop app built on Maestro — see `sessions/001-framework-bootstrap/symphony_app_brief.md`
- **Naming:** "AI-Assisted Delivery Framework" as identity; use "SDLC" in marketing context
