# Changelog

All notable changes to the Maestro framework.

## [Unreleased] — targeting v0.2.0

### Changed
- `.sessions/` is now the canonical session folder name (was `sessions/`)
- Session visibility model replaces solo/team mode (`session_visibility` in maestro.toml)
- Team features inferred from `[[team.members]]` presence — no separate mode toggle
- `mae-init` is now profile-only; folder scaffolding handled by installer
- HANDOFF.md: branch reference updated from `dev` to `main`

### Added
- DECISIONS.md — decision audit trail
- OPEN_QUESTIONS.md — tracked questions
- WORKLOG.md — activity log
- CHANGELOG.md — this file
- ROADMAP.md — strategic backlog
- maestro.toml — framework config for this repo
- `.maestro/templates/roadmap.md` — roadmap template

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
