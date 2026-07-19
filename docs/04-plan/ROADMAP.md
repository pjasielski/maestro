# ROADMAP — Maestro Framework

**Version:** v0.3.0 (current release — tags v0.1.0 / v0.2.0 / v0.3.0 match CHANGELOG)
**Next release:** v0.4.0 (Milestone M03)
**Updated:** 2026-07-18
**Sources:** Sessions 005, 006, 009, 010, 012, 014 (competition), 015 (skills)
**Note:** Renumbered 2026-07-18 to unified IDs (D23): `M{MM}.{NN}`, identical in ROADMAP, task filenames (`M{MM}.{NN}-{slug}.md`), and task titles.

---

## Milestone M01: Foundation & Stability (v0.2.0) — ✅ complete

All 12 items done (installer rework, `.sessions/` standardization, session visibility, tracking files, renames PRD→REQUIREMENTS / SDD→DESIGN, aliases, sync absorption, Cursor adapters). Details in git history and CHANGELOG (was "Milestone 1").

## Milestone M02: Installer & Restructure (v0.3.0) — ✅ complete

All 8 items done (installer questions, conditional adapters, delivery/→docs/, templates→.maestro/, MAESTRO_BRANCH, --force, migration cleanup, toml settings). (Was "Milestone 1.5".)

---

## Milestone M03: Skill-First Architecture (v0.4.0) — ← NEXT · branch `milestone/m03-skill-first`

Commands become skills per the Agent Skills open standard (D17, D22, D23). Includes two installer hotfixes from field reports (Windows) — not skills work, but they ship with v0.4.0.

| # | Item | Priority | Effort | Depends | Status | Task | Source |
|---|------|----------|--------|---------|--------|------|--------|
| M03.01 | **Spike: mae-explore as SKILL.md, test auto-trigger (Claude Code + one non-Claude tool)** | P1 | M | — | ☐ todo | [M03.01](tasks/M03.01-skill-spike.md) | 015 |
| M03.02 | **Frontmatter convention: tiers (auto/suggest/explicit), trigger + anti-trigger phrases** | P1 | S | M03.01 | ☐ todo | [M03.02](tasks/M03.02-frontmatter-convention.md) | 015 |
| M03.03 | **Convert all remaining commands to skills; templates as supporting files** | P1 | L | M03.02 | ☐ todo | [M03.03](tasks/M03.03-convert-commands-to-skills.md) | 015 |
| M03.04 | **`mae-spec` combined quick-spec command (single SPEC.md)** | P1 | M | M03.02 | ☐ todo | [M03.04](tasks/M03.04-mae-spec-command.md) | 015 |
| M03.05 | **`mae-prd` / `mae-sdd` alias skills with synonym descriptions** | P2 | S | M03.03 | ☐ todo | [M03.05](tasks/M03.05-prd-sdd-aliases.md) | 015 |
| M03.06 | **Installer: place skills per tool; retire .cursor dispatch where skills suffice** | P1 | M | M03.03 | ☐ todo | [M03.06](tasks/M03.06-installer-skill-placement.md) | 015 |
| M03.07 | **Layered config: maestro.local.toml (gitignored personal prefs) + response_capture/question_budget settings** | P1 | S | — | ☐ todo | [M03.07](tasks/M03.07-layered-config.md) | 015 |
| M03.08 | **Question-budget rules in req/design/plan (explore exempt)** | P2 | S | M03.03 | ☐ todo | [M03.08](tasks/M03.08-question-budget.md) | 015 |
| M03.09 | **Installer hotfix: Windows story — document Git Bash/WSL requirement, evaluate install.ps1 (interim until M05 CLI)** | P1 | S | — | ☐ todo | [M03.09](tasks/M03.09-installer-windows-support.md) | 015/08 field report |
| M03.10 | **Installer hotfix: graceful non-interactive fallback — detect missing/unreadable /dev/tty, announce defaults loudly, clarify reinstall skips questions** | P1 | S | — | ☐ todo | [M03.10](tasks/M03.10-installer-tty-fallback.md) | 015/08 field report |
| M03.11 | **Installer hotfix: honor gitignored visibility when .gitignore already exists (append, idempotent; warn on committed-but-ignored conflict)** | P1 | S | — | ✅ done | [M03.11](tasks/M03.11-installer-gitignore-visibility.md) | 2026-07-19 field report |

**Done when:** Every command is a standard skill; auto-trigger works for advisory tier; install works on ≥ 3 tools; personal preferences respected; Windows install path documented and non-interactive installs are explicit about defaults. (Artifact-capture rule + task-ID convention already landed 2026-07-14: D22, D23.)

## Milestone M04: Living Docs & Sync (v0.5.0)

Canonical docs stay current transactionally (D19, D20, D21).

| # | Item | Priority | Effort | Depends | Status | Task | Source |
|---|------|----------|--------|---------|--------|------|--------|
| M04.01 | **Delta format for canonical docs (ADDED/MODIFIED/REMOVED)** | P1 | M | — | ☐ todo | — | 014 |
| M04.02 | **/sync merge step — archive behavior for deltas** | P1 | M | M04.01 | ☐ todo | — | 014 |
| M04.03 | **Capability sharding: requirements + design (_overview.md + per-capability files)** | P1 | M | — | ☐ todo | — | 015 |
| M04.04 | **Mechanical drift report in /sync (unmerged deltas)** | P2 | S | M04.02 | ☐ todo | — | 014 |

**Done when:** Shipping a change updates canonical docs as part of /sync; drift is reported, not noticed.

## Milestone M05: CLI (v0.6.0)

Deterministic = CLI, judgment = skills. CLI automates, never gates.

| # | Item | Priority | Effort | Depends | Status | Task | Source |
|---|------|----------|--------|---------|--------|------|--------|
| M05.01 | **`maestro validate` — structure checks (docs, tasks, toml, SKILL frontmatter)** | P1 | L | M03, M04 formats | ☐ todo | — | 014 |
| M05.02 | **`maestro init` / `update` — scaffold, skill placement, migrations (cross-platform: replaces install.sh, closes the Windows gap for good)** | P1 | L | M05.01 | ☐ todo | — | 014 |
| M05.03 | **PyPI package `maestro-delivery` (pip/uvx)** | P1 | M | M05.02 | ☐ todo | — | 009/014 |

**Done when:** `uvx maestro init` works end-to-end on macOS, Linux, and Windows; validate runs in CI. (Absorbs old F.2.)

## Milestone M06: Interop & Distribution (v0.7.0)

| # | Item | Priority | Effort | Depends | Status | Task | Source |
|---|------|----------|--------|---------|--------|------|--------|
| M06.01 | **README rewrite: "idea → shipped", PM persona, works-with-OpenSpec** | P1 | M | — | ☐ todo | — | 014 |
| M06.02 | **mae-plan export to OpenSpec change folder** | P2 | M | M03 | ☐ todo | — | 014 |
| M06.03 | **Publish mae-explore skill on skills.sh** | P2 | S | M03.01 | ☐ todo | — | 015 |

## Milestone M07: PoC Workflow (v0.8.0) — was Milestone 2

| # | Item | Priority | Effort | Depends | Status | Task | Source |
|---|------|----------|--------|---------|--------|------|--------|
| M07.01 | **`poc` flag on delivery commands** | P1 | M | M03 | ☐ todo | — | 005 |
| M07.02 | **`mae-poc` orchestrator: req+design (mae-spec) → plan → do → verdict; artifacts in docs/poc/{name}/; graduation via delta merge** | P1 | M | M07.01, M04 | ☐ todo | — | 015 (pending D12 amendment) |
| M07.03 | **Context loading MUST/SHOULD/MAY tiers per command** | P2 | S | — | ☐ todo | — | 005/009 |
| M07.04 | **Post-do state sync (checklist or required /sync)** | P2 | S | — | ☐ todo | — | 009 |
| M07.05 | **Definition of done: acceptance criteria checked before status → done** | P2 | S | — | ☐ todo | — | 009 |

(Old 2.2 implementation folder: ✅ done in v0.3.0.)

## Milestone M08: Documentation & Onboarding (v0.9.0) — was Milestone 3

| # | Item | Priority | Effort | Depends | Status | Task | Source |
|---|------|----------|--------|---------|--------|------|--------|
| M08.01 | **Rework mae-init: profile-only (conversational), skip folder creation** | P1 | M | — | ☐ todo | — | 005 decision |
| M08.02 | **Create tool capability matrix (`docs/tool-support.md`)** | P1 | S | — | ☐ todo | — | 005/009 review |
| M08.03 | **Update README.md to reflect installer, convention, and workflow changes (partially absorbed by M06.01)** | P1 | M | M06.01 | ☐ todo | — | 005/009 |
| M08.04 | **Add `## Adaptation` section to command files for profile-aware behavior** | P2 | M | M08.01 | ☐ todo | — | 009 review |
| M08.05 | **Write user guide (`docs/user-guide.md`) with full workflow examples** | P2 | L | M08.03 | ☐ todo | — | 009 PRD |
| M08.06 | **Add installer CI tests (fresh install, re-run, upgrade path)** | P2 | M | — | ☐ todo | — | 009 review |

**Done when:** New user can install, set up profile via mae-init, and complete first explore cycle with minimal friction.

## Milestone M09: ai-deck Integration (TBD) — was Milestone 4

Deprioritized per 2026-07-14 direction (skills first).

| # | Item | Priority | Effort | Depends | Status | Task | Source |
|---|------|----------|--------|---------|--------|------|--------|
| M09.01 | **Content scrub for open source (remove BlueLabel refs, swap fonts/logos)** | P1 | M | — | ☐ todo | — | 009/006 |
| M09.02 | **Design /mae-deck command (sub-commands: md, html)** | P1 | M | M09.01 | ☐ todo | — | 009/006 |
| M09.03 | **ai-deck Phase 1: pure agentic MVP (command files + templates + theme)** | P1 | L | M09.01 | ☐ todo | — | 009/006 |
| M09.04 | **Optional ai-deck asset copying in Maestro installer** | P2 | S | M09.03 | ☐ todo | — | 009/006 |
| M09.05 | **ai-deck Phase 2: deterministic Python scripts (stdlib only, auto-detected)** | P2 | L | M09.03 | ☐ todo | — | 009/006 |

**Done when:** `/mae-deck` produces a presentation from delivery artifacts.

## Milestone M10: Task & PM Features (TBD) — was Milestone 5

Feeds the future Hub app (session 015/05, 015/09 handoff).

| # | Item | Priority | Effort | Depends | Status | Task | Source |
|---|------|----------|--------|---------|--------|------|--------|
| M10.01 | **Expand task template with optional fields (Due, Sprint, Component, Labels)** | P2 | S | — | ☐ todo | — | 005/009 review |
| M10.02 | **Add status command filters (`--assignee`, `--priority`, `--blocked`)** | P2 | M | M10.01 | ☐ todo | — | 005/009 review |
| M10.03 | **Integrate issue lifecycle into /status views** | P3 | M | — | ☐ todo | — | 009 review |
| M10.04 | **Add rolling project digest for long-running projects** | P2 | M | — | ☐ todo | — | 009 review |

**Done when:** A PM can create, filter, and track tasks without editing markdown by hand.

---

## Future (post v0.9)

| # | Item | Priority | Effort | Depends | Source |
|---|------|----------|--------|---------|--------|
| F.1 | **Interactive artifacts (JSON → HTML forms for question filling)** | P3 | L | M08.01 | 005 design |
| F.3 | **Maestro app (Hub — see `.sessions/015-skills/05-maestro-symphony.md` + `09-app-handoff.md`; developed in its own repo)** | P3 | XL | M05 | 005/009/015 |
| F.4 | **Plugin ecosystem (third-party command/skill packages)** | P3 | L | M05 | 009 |
| F.5 | **Neutral config alias (PROJECT_AI.md as tool-neutral alternative)** | P3 | M | — | 005/009 review |
| F.6 | **`/mae-iterate` command (change intake → impact analysis → delta plan)** | P3 | M | M07.01 | 009 |
| F.7 | **`/mae-audit` command (cross-artifact consistency checking)** | P3 | M | — | 009 |
| F.8 | **Framework health check (/status sub-command)** | P3 | S | — | 009 |
| F.9 | **`mae-profile` command (lightweight profile editor)** | P3 | S | M08.01 | 005 |
| F.10 | **ai-deck: additional themes (light, corporate, community)** | P3 | M each | M09.03 | 009/006 |
| F.11 | **ai-deck: PDF export via headless Chrome** | P3 | M | M09.03 | 009/006 |
| F.12 | **ai-deck: pip package for standalone use** | P3 | M | M09.05 | 009/006 |
| F.13 | **Version iteration loop protocol (change → classify → delta plan → execute)** | P2 | M | — | 009 |

(F.2 Python CLI absorbed into M05.)

---

## How to Use

This roadmap is maintained by `/mae-plan`. When ready to implement a milestone:

1. Create the milestone branch (`milestone/mNN-{slug}`) from `dev` — work merges milestone → dev → (tested) → main
2. Run `/mae-plan` to enrich the milestone with execution notes and generate task files (`tasks/M{MM}.{NN}-{slug}.md`)
3. Execute with `/mae-do` — status updates automatically
4. Run `/sync` at end of session to reconcile status

Milestones are not strictly sequential — items within a milestone can be picked independently. P0/P1 hotfixes should be addressed before feature work.

---

**Notes:**
- Execution order = milestone order (M03 first per 2026-07-14 decision); items within a milestone can be picked independently.
- Each milestone ships as one release train: M03 → v0.4.0 tag on merge to main, etc.
- ai-deck work (M09) happens primarily in /Users/piotr/Projects/ai-deck; items here track the Maestro integration side. "Presently" may become the ai-deck app name.
- `.sessions/015-skills/02-skill-spec-plan.md` is superseded by M03–M06 (kept as rationale).