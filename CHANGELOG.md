# Changelog

All notable changes to the Maestro framework.

## [0.3.0] — 2026-07-02

### Changed
- `delivery/` → `docs/` — numbered phase folders (01-explore through 09-maintenance) now live directly under docs/
- `templates/` → `.maestro/templates/` — framework templates now under .maestro/ to avoid collisions with project templates
- Installer asks three questions: session visibility, AI tool selection (multi-select), question style (async/sync)
- Adapter creation is conditional — only selected AI tools get their config files
- `question_style` and `ai_tools` added to maestro.toml config

### Added
- `--force` flag for full framework reinstall (overwrites commands, templates, adapters; preserves project files)
- `MAESTRO_BRANCH` env var for installing from non-main branches
- Migration cleanup: deprecated files (mae-prd, mae-checkpoint, prd.md, sdd.md, templates/) auto-removed on upgrade
- Branch hint when downloads fail without explicit MAESTRO_BRANCH
- Copilot adapter (`.github/copilot-instructions.md`) alongside existing Claude Code and Cursor adapters

### Fixed
- Cross-branch install: script now downloads all files from the correct branch
- Reinstall reads existing `ai_tools` from maestro.toml to update only selected adapters

## [0.2.0] — 2026-06-18

### Changed
- `.sessions/` is now the canonical session folder name (was `sessions/`)
- Session visibility model replaces solo/team mode (`session_visibility` in maestro.toml)
- Team features inferred from `[[team.members]]` presence — no separate mode toggle
- `mae-init` is now profile-only; folder scaffolding handled by installer
- HANDOFF.md: branch reference updated from `dev` to `main`
- Renamed `mae-prd` → `mae-req`, output `PRD.md` → `REQUIREMENTS.md`
- Renamed output `SDD.md` → `DESIGN.md`
- Absorbed `mae-checkpoint` into `sync`
- Added command aliases: mex, mrq, mds, mpl, mdo, mrv

### Added
- DECISIONS.md — decision audit trail
- OPEN_QUESTIONS.md — tracked questions
- WORKLOG.md — activity log
- CHANGELOG.md — this file
- ROADMAP.md — strategic backlog (`docs/04-plan/ROADMAP.md`)
- maestro.toml — framework config for this repo
- `.maestro/templates/roadmap.md` — roadmap template
- `docs/05-implementation/` folder for mae-do output
- Cursor adapter files (`.cursor/rules/`, `.cursor/commands/`)

### Fixed
- Installer: silent download failures (removed `|| true` from loops)
- Installer: templates now use `create_if_missing` (no overwrite on re-install)
- Installer: added `issue.md` to download list
- Installer: simplified to one question (session visibility)

## [0.1.0] — 2026-06-10

Initial alpha release. Tagged on current `main` state.

### Features
- 8 delivery commands: init, explore, prd, design, plan, do, review, checkpoint
- 4 utility commands: decide, sync, status, md
- Sessions-first artifact flow with promotion to docs/
- Multi-tool support: Claude Code, Cursor, Codex adapters
- Setup wizard (HTML + Python server)
- Output tiers: standard, verbose (-v), caveman (-c)
- User/team profiles in maestro.toml
- Templates: prd, sdd, explore, task, summary, report
