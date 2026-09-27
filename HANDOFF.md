# HANDOFF.md — Maestro Framework

## Current Status
- **Phase:** bootstrap → packaging (v0.4.0 released; v0.4.2 behavior patch pending; M04 skill-first started)
- **Last worked on:** 2026-09-19 — `/mae-help`, `/mae-run` + `/mae-yolo`, `/mae-scope`, dependency graph (session 019-m04-m05-commands, Fable); adversarial review of the instruction set (session 018-framework-review)
- **Active branch:** `feat/v0.4.2-scope`
- **Version:** v0.4.0 (Milestone M03 complete — PoC workflow)
- **Done this sprint:** M04.02 ✅, **M04.15 ✅, M05.11 ✅, M05.07 ✅, M04.18 ✅** (report: `.sessions/019-m04-m05-commands/01-implementation-report.md`). M04.01 ⏳ blocked — agent work complete; two criteria wait on a keyboard test, procedure in the task Notes, eval kit in `docs/07-test/skill-trigger-eval/`. M04.17 not built — Q7 still "maybe".
- **Next task:** (user) M04.01 keyboard test, answer Q7 and Q8. Then write the M04.13 task file — P42.03 and P42.05 have criteria that point at it. Then the Opus tier per `maestro-hq/.sessions/22-new-scope/05-fable-tiered-scope.md` §4: O1 `P42.02` → P42.03 → P42.01 → P42.04 → P42.05 → P42.06 → clean-install test (now touches four installer loops) → tag v0.4.2. Review findings to fold in on the way: `.sessions/018-framework-review/01-findings.md` § Fix first (D30 read path into the loading table; Synced/Supersedes columns on DECISIONS.md; `mae-plan` prerequisites for PoC graduation — suggest P42.07).
- **Where state is read:** the state probe and state table live in `.maestro/commands/mae-help.md`; `/status`, `/mae-yolo` and CONVENTIONS §3 point at it. Change it there only.
- **Sprint 2026-09-14:** allocation by model tier (Fable → design-heavy new commands; Opus → v0.4.2 + conversion; Sonnet → mechanical) in `maestro-hq/.sessions/22-new-scope/05-fable-tiered-scope.md`, reallocated by `06-fable-reallocation.md` (Fable: Hub requirements, F2/F3, review; everything else Opus).
- **Blockers:** M04.01 keyboard test. Q8 (utility-skill `mae-` prefix) should be answered before M04.03 converts the utility commands. Decision-gated: **M05.12** (design/architecture naming) needs its own session before M05.09 `/mae-mock` can be specced.

## Recent Changes (2026-09-19) — Sessions 018 + 019

### Four commands built (019) — the F1/F4/F5 items from the September sprint, in their original order
- **`/mae-help`** (M04.15): state probe (10 cheap checks) + state table; bare / `all` / `{command}`; suggests 3–4 commands, never all. Installer's closing output now starts with it. `/status` shares the probe
- **`/mae-run {a}..{b}`**, `->` lists, **`/mae-yolo [stop]`** (M05.11): one question round at the front, one review after the last specifying phase, per-task commits inside `do`, never skips explore, stop on first failure. MAESTRO.md § Chaining — documented, not advertised
- **`/mae-scope`** / `msc` (M05.07): intake → classify (additive / modifying / conflicting; size check → `/mae-explore` first) → `NN_scope-delta.md` (client-sendable, analysis only) → apply on confirmation across REQUIREMENTS, DESIGN, ROADMAP, tasks, DECISIONS; unapproved capabilities → HANDOFF § Deferred scope. Template `scope-delta.md`
- **Dependency graph** (M04.18): `/mae-plan` emits `### Dependencies` Mermaid per milestone between `<!-- deps:M{MM} -->` markers and a `## Milestone Map`; `/status --graph` prints it. ROADMAP.md dogfooded for M04
- None of the four has run on a real project yet; the first real chain and the first real scope change are the acceptance tests

### Adversarial review of the instruction set (018)
- `.sessions/018-framework-review/01-findings.md`: 40 findings — 12 contradictions, 11 rules with no operator, 8 token hotspots, 9 decisions (D22–D33) not yet reflected. Four blockers: PoC graduation fails on `mae-plan` prerequisites; "unsynced decisions" has no representation in DECISIONS.md; Decision Protection has no reader in Design/Implementation/Review; D30's read path is unapplied
- Nothing was changed by the review; its § Fix first is queued into the Opus tier above

## Recent Changes (2026-09-17) — Session 017-skill-spike

First SKILL.md in the framework, plus the convention every other conversion follows. Report: `docs/04-implementation/M04.01-skill-spike-report.md`.

### M04.01 spike (⏳ blocked on keyboard test)
- `.maestro/skills/mae-explore/SKILL.md` canonical, `references/question-format.md` as supporting file; passes `uvx --from skills-ref agentskills validate`, also through the symlinks
- Placement: `.claude/skills/` (Claude Code, Cursor legacy) and `.agents/skills/` (Codex, Cursor) as symlinks; installer mechanism is M04.06
- Old command file and wrappers untouched until M04.03; possible `/mae-explore` name clash with `.claude/commands/` is test step 1
- Trigger-eval kit reusable for all conversions: `docs/06-test/skill-trigger-eval/`

### M04.02 convention (✅)
- Tier lives in `metadata.maestro-tier` and is enforced by a body section per tier: fit check (auto), gate (suggest), guard (explicit). Suggest cannot be expressed in frontmatter at all
- `UNCLEAR:` the reference validator rejects `disable-model-invocation` (and every Claude/Cursor-specific field). Working default: keep it on explicit skills, accept one validator line, whitelist in `maestro validate` (M06.01)
- Codex needs `{skill}/agents/openai.yaml` with `allow_implicit_invocation: false` for explicit skills
- Tier table extended to poc/help/scope/mock/run/yolo/approve/md (provisional until each is built)

## Recent Changes (2026-08-21) — Session 22-new-scope (maestro-hq)

Critique from two external developers plus accumulated own observations, scoped into the roadmap. Analysis: `maestro-hq/.sessions/22-new-scope/02-scope-analysis.md` + `03-responses.md`.

### New: v0.4.2 behavior patch (6 items, all S) — sequenced BEFORE the skill conversion
- Rationale: rewriting a command then converting it is one rewrite; converting then rewriting is two. `015-skills/03` flagged this dependency explicitly.
- P42.01 `[git]` config + per-task commits · P42.02 `response_capture` three tiers + work-product rule · P42.03 artifact consolidation + `/md` two-mode · P42.04 append-only state + sync reconciliation · P42.05 README quickstart + running-process reporting · P42.06 explore pre-fill (was M04.14)

### Added to M04
- **M04.15 `/mae-help`** — state-aware next-step guidance. Build first in the milestone
- M04.17 `/mae-approve` (triage-only) · M04.18 Mermaid dependency graph
- M04.14 moved to P42.06; **M04.16 vacant** (aliases redistributed)

### Added to M05
- M05.08 canonical-file consolidation (4 root files → 1 + ADR folder) · M05.09 `/mae-mock` · M05.10 `/mae-approve` stamping · M05.11 `/mae-run` + `/mae-yolo` chaining · **M05.12 decision-gated naming session** · M05.13 parallel-work view (promoted from M10)

### Two corrections to the record
- **`milestone/m03-skill-first` contains nothing** — zero commits ahead of main, zero file diffs. It appears in `git branch --merged` only because its tip is an ancestor of main. Consistent with session 018's forensic finding that no `SKILL.md` was ever written. Do not reuse the branch name; create `milestone/m04-skill-first` fresh.
- **`/mae-poc` produces only `POC.md`** — a condensed single-file spec, not REQUIREMENTS + DESIGN + ROADMAP. An earlier claim that it doubles as a "fast path to the full artifacts" was wrong; chaining (M05.11) is that path.

## Recent Changes (2026-08-03) — Session 018 (maestro-hq), v0.4.0

### PoC track shipped
- `/mae-poc` (`mpoc`) → single-file spec at `docs/02-specs/POC.md`; `/mae-do poc` executes the milestone
- `docs/00-reference/` — read-only source material, authoritative over inferences drawn from code
- Built for a live client engagement (session 017, maestro-hq) and validated there before release

### Roadmap renumbered
- PoC M07/v0.8.0 → **M03/v0.4.0 ✅ shipped**; skills M03 → M04/v0.5.0; living docs → M05; CLI → M06; interop → M07
- `mae-spec` dropped (⊘) — `/mae-poc` supersedes it; M04.04 left vacant
- Task files renamed `M03.NN` → `M04.NN`; shipped installer fix moved M03.11 → M03.06
- Full mapping in ROADMAP § Renumbering 2026-08-03

### Documentation
- README rewritten: logo, "spec-driven delivery" positioning, PoC track section, FAQ
- LICENSE file added (MIT was claimed in three places, the file was missing)

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
- **Description:** AI-assisted delivery framework. 8 delivery commands + 6 utility commands + 2 chaining commands + 8 aliases. Sessions-first workflow, decision tracking, task management via markdown files.
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
### Delivery (8)
| Command | Alias | Purpose |
|---------|-------|---------|
| `/mae-init` | — | Profile setup after installation |
| `/mae-explore` | `mex` | Build understanding — smart default, targeted, ask, doc |
| `/mae-req` | `mrq` | Formalize requirements from explore report |
| `/mae-design` | `mds` | Technical architecture from requirements |
| `/mae-plan` | `mpl` | Create/update ROADMAP, generate task files |
| `/mae-do` | `mdo` | Execute tasks (planned, ad-hoc, or from file) |
| `/mae-review` | `mrv` | Review code or artifacts |
| `/mae-scope` | `msc` | Scope change: classify, impact analysis (scope-delta), apply on confirmation |

### Utility (5) + Chaining (2)
| Command | Purpose |
|---------|---------|
| `/decide` | Record decision in audit trail |
| `/sync` | End-of-session save — update HANDOFF, ROADMAP status, DECISIONS, checkpoint |
| `/status` | Project overview + sub-commands (tasks, decisions, questions) |
| `/md` | Save response to session file |
| `/mae-help` | What to run now — state probe, 3–4 commands; `all`, `{command}` |
| `/mae-run` | Chain phases `{a}..{b}` or `->` list: one question round, one review |
| `/mae-yolo` | `/mae-run {current}..{stop}`; never skips explore; ⚠️ unattended |

## Key Files
| File | Location |
|------|----------|
| Framework instructions | `MAESTRO.md` |
| Project config | `CLAUDE.md` |
| Framework settings | `maestro.toml` |
| Explore artifacts | `docs/01-explore/` |
| Requirements | `docs/02-specs/REQUIREMENTS.md` |
| Architecture | `docs/02-specs/ARCHITECTURE.md` |
| Roadmap | `docs/03-plan/ROADMAP.md` |
| Tasks | `docs/03-plan/tasks/` |
| Implementation reports | `docs/04-implementation/` |
| Templates | `.maestro/templates/` (requirements, design, explore, task, summary, report, roadmap) |
| Framework commands | `.maestro/commands/` |
| Claude Code adapters | `.claude/commands/` (wrappers + aliases) |
| Cursor adapters | `.cursor/rules/` (core + dispatch) + `.cursor/commands/` (slash commands) |
