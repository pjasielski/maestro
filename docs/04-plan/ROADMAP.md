# ROADMAP — Maestro Framework

**Version:** v0.3.0
**Updated:** 2026-07-02
**Sources:** Session 005 (review + analysis), Session 009 (PRD/SDD/roadmap), Session 006 (ai-deck), Session 010 (consolidation), Session 012 (installer & restructure)

---

## Milestone 1: Foundation & Stability (v0.2.0)

Fix what's broken. Establish versioning. Standardize conventions.

| # | Item | Priority | Effort | Depends | Status | Source |
|---|------|----------|--------|---------|--------|--------|
| 1.1a | **Installer rework: simplify to one question** | P0 | M | — | ✅ done | 005 review |
| 1.1b | **Installer: fix silent failures, protect templates on update** | P1 | S | — | ✅ done | 005 review |
| 1.2 | **Standardize `.sessions/` as canonical folder name across all files** | P1 | S | — | ✅ done | 005 review |
| 1.3 | **Replace solo/team mode with session visibility + team member inference** | P1 | S | 1.1 | ✅ done | 005 analysis |
| 1.4 | **Create missing tracking files for this repo (DECISIONS, OPEN_QUESTIONS, WORKLOG)** | P1 | S | — | ✅ done | 009 gap |
| 1.5 | **Create maestro.toml for this repo with project metadata and user profile** | P1 | S | 1.3 | ✅ done | 009 gap |
| 1.6 | **Fix HANDOFF.md branch reference (dev → main)** | P1 | S | — | ✅ done | 009 drift |
| 1.7 | **Sync setup wizard (index.html, server.py) with new installer behavior** | P1 | S | 1.1 | ✅ done | 005 scope |
| 1.8 | **Create CHANGELOG.md and tag v0.1.0 on current state** | P1 | S | — | ✅ done | 005 decision |
| 1.9 | **Rename PRD→REQUIREMENTS, SDD→DESIGN, restructure delivery folders** | P1 | S | — | ✅ done | 009, 010 |
| 1.10 | **Add command aliases (mex, mrq, mds, mpl, mdo, mrv)** | P1 | S | — | ✅ done | 010 |
| 1.11 | **Absorb checkpoint into sync, expand sync scope** | P1 | S | — | ✅ done | 010 |
| 1.12 | **Add Cursor adapter files (.cursor/rules/)** | P1 | S | — | ✅ done | 010 |

**Done when:** Fresh `curl | bash` install produces complete, correct setup. Re-install preserves user files. `.sessions/` used consistently. Version tags exist.

---

## Milestone 1.5: Installer & Restructure (v0.3.0)

New installer questions, folder restructure, migration support.

| # | Item | Priority | Effort | Depends | Status | Source |
|---|------|----------|--------|---------|--------|--------|
| 1.13 | **Installer questions: AI tool selection (multi-select), question style (async/sync)** | P1 | M | 1.1 | ✅ done | 012 |
| 1.14 | **Conditional adapter creation based on AI tool selection** | P1 | S | 1.13 | ✅ done | 012 |
| 1.15 | **Move delivery/ into docs/ — numbered folders directly under docs** | P1 | M | 1.9 | ✅ done | 012 |
| 1.16 | **Move templates/ into .maestro/templates/** | P1 | S | — | ✅ done | 012 |
| 1.17 | **Add MAESTRO_BRANCH support for cross-branch installation** | P1 | S | 1.1 | ✅ done | 012 |
| 1.18 | **Add --force flag for full framework reinstall** | P1 | S | 1.1 | ✅ done | 012 |
| 1.19 | **Migration cleanup: remove deprecated files (mae-prd, mae-checkpoint, prd.md, sdd.md, templates/)** | P1 | S | 1.15, 1.16 | ✅ done | 012 |
| 1.20 | **Add question_style and ai_tools to maestro.toml config** | P1 | S | 1.13 | ✅ done | 012 |

**Done when:** Installer handles fresh install, reinstall, and upgrade from v0.2.0 cleanly. Framework files live under .maestro/. Deprecated files auto-cleaned.

---

## Milestone 2: PoC Workflow & Command Improvements (v0.4.0)

First-class iterative development support. Strengthen command reliability.

| # | Item | Priority | Effort | Depends | Status | Source |
|---|------|----------|--------|---------|--------|--------|
| 2.1 | **Add `poc` flag to all delivery commands (explore, req, design, plan, do, review)** | P1 | M | 1.2 | ☐ todo | 005 decision |
| 2.2 | **Add implementation folder (`docs/05-implementation/`)** | P1 | S | — | ✅ done | 005 decision |
| 2.3 | **Strengthen context loading with MUST/SHOULD/MAY tiers per command** | P2 | S | — | ☐ todo | 005/009 review |
| 2.4 | **Add post-do state sync (checklist or required /sync after implementation)** | P2 | S | — | ☐ todo | 009 pattern |
| 2.5 | **Enforce definition of done: acceptance criteria checked before status → done** | P2 | S | — | ☐ todo | 009 recommendation |

**Done when:** User can run full PoC cycle with `poc` flag, then re-run for production with PoC artifacts as starting point.

---

## Milestone 3: Documentation & Onboarding (v0.5.0)

Make the framework easy to adopt. Strengthen multi-tool story.

| # | Item | Priority | Effort | Depends | Status | Source |
|---|------|----------|--------|---------|--------|--------|
| 3.1 | **Rework mae-init: profile-only (conversational), skip folder creation** | P1 | M | 1.3 | ☐ todo | 005 decision |
| 3.2 | **Create tool capability matrix (`docs/tool-support.md`)** | P1 | S | — | ☐ todo | 005/009 review |
| 3.3 | **Update README.md to reflect all installer, convention, and workflow changes** | P1 | M | 1.1, 1.2 | ☐ todo | 005/009 |
| 3.4 | **Add `## Adaptation` section to command files for profile-aware behavior** | P2 | M | 3.1 | ☐ todo | 009 review |
| 3.5 | **Write user guide (`docs/user-guide.md`) with full workflow examples** | P2 | L | 3.3 | ☐ todo | 009 PRD |
| 3.6 | **Add installer CI tests (fresh install, re-run, upgrade path)** | P2 | M | 1.1 | ☐ todo | 009 review |

**Done when:** New user can install, set up profile via mae-init, and complete first explore cycle with minimal friction.

---

## Milestone 4: ai-deck Integration (v0.5-0.6)

Presentation generation via the ai-deck framework.

| # | Item | Priority | Effort | Depends | Status | Source |
|---|------|----------|--------|---------|--------|--------|
| 4.1 | **Content scrub for open source (remove BlueLabel refs, swap fonts/logos)** | P1 | M | — | ☐ todo | 009/006 |
| 4.2 | **Design /mae-deck command (sub-commands: md, html)** | P1 | M | 4.1 | ☐ todo | 009/006 |
| 4.3 | **ai-deck Phase 1: pure agentic MVP (command files + templates + theme)** | P1 | L | 4.1 | ☐ todo | 009/006 |
| 4.4 | **Optional ai-deck asset copying in Maestro installer** | P2 | S | 4.3 | ☐ todo | 009/006 |
| 4.5 | **ai-deck Phase 2: deterministic Python scripts (stdlib only, auto-detected)** | P2 | L | 4.3 | ☐ todo | 009/006 |

**Done when:** `/mae-deck` produces a presentation from delivery artifacts.

---

## Milestone 5: Task & PM Features (v0.7.0)

Strengthen "lightweight Jira" capabilities.

| # | Item | Priority | Effort | Depends | Status | Source |
|---|------|----------|--------|---------|--------|--------|
| 5.1 | **Expand task template with optional fields (Due, Sprint, Component, Labels)** | P2 | S | — | ☐ todo | 005/009 review |
| 5.2 | **Add status command filters (`--assignee`, `--priority`, `--blocked`)** | P2 | M | 5.1 | ☐ todo | 005/009 review |
| 5.3 | **Integrate issue lifecycle into /status views** | P3 | M | — | ☐ todo | 009 review |
| 5.4 | **Add rolling project digest for long-running projects** | P2 | M | — | ☐ todo | 009 review |

**Done when:** A PM can create, filter, and track tasks without editing markdown by hand.

---

## Future (post v0.7)

| # | Item | Priority | Effort | Depends | Source |
|---|------|----------|--------|---------|--------|
| F.1 | **Interactive artifacts (JSON → HTML forms for question filling)** | P3 | L | 3.1 | 005 design |
| F.2 | **Python CLI (`uvx maestro init`)** | P3 | XL | 1.1 | 009 PRD |
| F.3 | **Maestro UI app (desktop/web — lightweight IDE + agent + project management)** | P3 | XL | 5.x | 005/009 |
| F.4 | **Plugin ecosystem (third-party command packages)** | P3 | L | F.2 | 009 |
| F.5 | **Neutral config alias (PROJECT_AI.md as tool-neutral alternative)** | P3 | M | — | 005/009 review |
| F.6 | **`/mae-iterate` command (change intake → impact analysis → delta plan)** | P3 | M | 2.1 | 009 |
| F.7 | **`/mae-audit` command (cross-artifact consistency checking)** | P3 | M | — | 009 |
| F.8 | **Framework health check (/status sub-command)** | P3 | S | — | 009 |
| F.9 | **`mae-profile` command (lightweight profile editor)** | P3 | S | 3.1 | 005 |
| F.10 | **ai-deck: additional themes (light, corporate, community)** | P3 | M each | 4.3 | 009/006 |
| F.11 | **ai-deck: PDF export via headless Chrome** | P3 | M | 4.3 | 009/006 |
| F.12 | **ai-deck: pip package for standalone use** | P3 | M | 4.5 | 009/006 |
| F.13 | **Version iteration loop protocol (change → classify → delta plan → execute)** | P2 | M | 1.8 | 009 |

---

## How to Use

This roadmap is maintained by `/mae-plan`. When ready to implement a milestone:

1. Run `/mae-plan` to enrich the milestone with execution notes and generate task files
2. Execute with `/mae-do` — status updates automatically
3. Run `/sync` at end of session to reconcile status

Milestones are not strictly sequential — items within a milestone can be picked independently. P0 items should be addressed before feature work.

---

**Notes:**
- ai-deck work (Milestone 4) happens primarily in /Users/piotr/Projects/ai-deck; items here track the Maestro integration side
- "Presently" may become the ai-deck app name; "ai-deck" is the framework/repo name
