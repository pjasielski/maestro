# Changelog

All notable changes to the Maestro framework.

## [0.5.0] — unreleased

### Breaking
- **Layout:** `docs/02-requirements/`, `02-poc/`, `03-design/` → one `docs/02-specs/` (REQUIREMENTS.md, DESIGN.md, ARCHITECTURE.md, POC.md, mock/); `04-plan/` → `03-plan/`; on-demand folders renumbered `04-implementation/` … `08-maintenance/`. Existing projects: `/mae-init upgrade`
- **Renames:** architecture is now `ARCHITECTURE.md` (was `DESIGN.md`), made by `/mae-architecture` (`mar`); `/mae-req` → `/mae-requirements` (`mrq`; `/mae-req` kept as a pointer for one release); template `design.md` → `architecture.md`
- **`mds` / `/mae-design` changed meaning:** now the visual design system (`DESIGN.md`, DESIGN.md format), not architecture

### Added
- `/mae-specs [part]` (`msp`) — builds the missing and relevant spec parts in one question round and one review
- `docs/01-explore/EXPLORE.md` — the fixed explore synthesis; the only explore file downstream commands read
- `/mae-pr` — pushes the current branch and opens a draft PR (compare-URL fallback); `/mae-do` offers it at milestone end
- `[git]` policy (commit per task, never push by default, PR description as markdown) and `response_capture` (artifacts / minimal / all); upgrades append missing `maestro.toml` keys
- Main-file rule for splitting large artifacts into lowercase sub-folders
- `/mae-mock` — self-contained, clickable HTML screens in `docs/02-specs/mock/` with `_screens.md` (screens → requirement IDs, `GAP:` lines read by `/mae-requirements` and `/mae-poc`)

## [0.4.0] — 2026-08-03

The PoC track: a time-boxed path from idea to running code, using one spec file instead of three. Built ahead of schedule for a live client engagement and validated there before release.

### Added
- `/mae-poc` (`mpoc`) — collapses requirements, design, and roadmap into a single `docs/02-poc/POC.md`. Asks only blocking questions; records other judgement calls under § Risks & Assumptions. Capped at 4,000 words — past that it recommends the full track
- `docs/00-reference/` — read-only folder for source material you did not write (client briefs, specs, transcripts). Authoritative over inferences drawn from code; read first by `/mae-explore`
- `/mae-do poc` — execute a whole PoC milestone straight from POC.md
- `.maestro/templates/poc.md` — PoC spec template, including § 6 Current State as the rehydration key for a fresh session
- PoC track throughout MAESTRO.md — workflow paths, context-loading tiers, artifact flow, adaptive guidance
- README: logo, positioning, PoC track section
- D24 — git workflow: branch per milestone → dev → main + version tag

### Changed
- `/mae-explore` reads `docs/00-reference/` first, and treats it as authoritative where it conflicts with what the code implies
- Installer creates `docs/00-reference/` and `docs/02-poc/`, seeds a reference README, and registers the `mpoc` alias
- Roadmap renumbered: PoC shipped as M03 (was M07); skills → M04; everything between shifts by one. See ROADMAP § Renumbering 2026-08-03

### Fixed
- Installer honors gitignored session visibility when `.gitignore` already exists — appends idempotently instead of skipping, and warns on a committed-but-ignored conflict

### Notes
- PoC uses standard `M{MM}.{NN}` task IDs — the PoC is milestone M01, so `/mae-plan` continues at M02 when a prototype graduates and the PoC's history stays intact
- `docs/02-poc/` and `docs/02-requirements/` share a number deliberately: the two tracks are mutually exclusive, so they never collide in a real project tree

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
