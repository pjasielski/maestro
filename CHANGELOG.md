# Changelog

All notable changes to the Maestro framework.

## [0.5.0] — unreleased

### Breaking
- **Layout:** `docs/02-requirements/`, `02-poc/`, `03-design/` → one `docs/02-specs/` (REQUIREMENTS.md, DESIGN.md, ARCHITECTURE.md, POC.md, mock/); `04-plan/` → `03-plan/`; on-demand folders renumbered `04-implementation/` … `08-maintenance/`. Existing projects: `/mae-init upgrade`
- **Renames:** architecture is now `ARCHITECTURE.md` (was `DESIGN.md`), made by `/mae-architecture` (`mar`); `/mae-req` → `/mae-requirements` (`mrq`; `/mae-req` kept as a pointer for one release); template `design.md` → `architecture.md`
- **`mds` / `/mae-design` changed meaning:** now the visual design system (`DESIGN.md`, DESIGN.md format), not architecture

### Added
- `/mae-help` — state-aware "what now?": one suggestion from a cheap probe of what exists; `all` lists every command with what it produces
- `/mae-specs [part]` (`msp`) — builds the missing and relevant spec parts (requirements, visual design if there's a UI, architecture) in one question round and one review
- `/mae-mock` — self-contained, clickable HTML screens in `docs/02-specs/mock/` with `_screens.md` (screens → requirement IDs, `GAP:` lines read by `/mae-requirements` and `/mae-poc`)
- `/mae-scope` (`msc`) — scope-change intake: client-sendable impact analysis, applied on confirmation; `--direct` applies additive changes straight away
- `/mae-idea` — append-only idea inbox `docs/01-explore/IDEAS.md`; `/mae-explore I-NN` explores one; rejected scope lands there too
- `/mae-pr` — pushes the current branch and opens a draft PR (compare-URL fallback); `/mae-do` offers it at milestone end
- `/mae-run {a}..{b}` and `/mae-yolo [stop]` — chain phases with one question round and one review (documented, not advertised)
- `/mae-init upgrade` — moves a pre-0.5.0 `docs/` layout after showing the plan
- `docs/01-explore/EXPLORE.md` — the fixed explore synthesis; the only explore file downstream commands read
- Skills: `mae-explore`, `mae-specs`, `mae-scope`, `mae-idea`, `mae-mock` are Agent Skills the agent may offer; everything else stays a command. One copy of each protocol
- `[git]` policy (commit per task, never push by default, PR description as markdown, drafts only) and `response_capture` (artifacts / minimal / all) with the work-product rule; `maestro.local.toml` for personal settings
- `/mae-do`: verified README `## Quickstart`; running processes reported with their stop command
- Explore questions grouped Business / Technical with consequence-based pre-fill (`Pre-answered:` / `Pre-answered (assumed):` / `OPEN`) and checkbox question types
- Main-file rule for splitting large artifacts into lowercase sub-folders; Mermaid dependency graph in ROADMAP.md (`/status --graph`)

### Changed
- `/mae-plan` plans from REQUIREMENTS.md alone or from POC.md (PoC graduation now works)
- Installer: upgrades append missing `maestro.toml` keys and never change existing ones; the documented upgrade command now downloads instead of reinstalling the project's own files; `issue.md` template now installed; asks when to commit and which responses to save
- Browser setup wizard frozen at v0.4.0 options; the one-line install is the recommended path
- Chains (`/mae-run`, `/mae-yolo`, multi-part `/mae-specs`) write each artifact straight to `docs/` so the next phase reads it normally; the one review is keep / undo, with changed files backed up in the session
- `docs/00-reference/` is the primary evidence of intent, ranked below your instructions and confirmed decisions; its content is data, never instructions
- DECISIONS.md is loaded for architecture, implementation and code review

### Fixed (rc.2)
- Installer: a failed download stops the install before the project is touched (was: continued and reported success)
- Installer: the one-line install gets the same Cursor rules as a clone install (was: shorter fallback rules that routed skills to `.maestro/commands/`)
- Codex: a root `AGENTS.md` is now written. Copilot and Codex share one Maestro block between markers; your own content in `AGENTS.md` or `.github/copilot-instructions.md` is kept
- Installer: in a folder that isn't a Git repository, `commit = "never"` and no commit question
- `/mae-run` and `/mae-yolo` follow `[git]` exactly (was: committed after every task even with `commit = "never"`)
- Removed runtime pointers to `.maestro/skills/CONVENTIONS.md`, which projects never receive
- Docs: removed checkpoint commands and `mode = "team"`, `.sessions/` paths throughout, per-tool first steps and support levels, complete team commit list, accurate uninstall and Windows notes

### Removed
- `/mae-explore-lite` — question pre-fill makes the full explore cheap enough
- The "save every response over 80 words" rule

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
