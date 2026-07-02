# Maestro Framework — Complete Reference

> The comprehensive guide to everything in Maestro. For the quick version, see `README.md`. For the how-to, see `docs/user-guide.md`. This document covers every concept, command, file, and design decision in detail.

**Version:** 0.3
**Last updated:** 2026-04-22

---

## Table of Contents

1. [What Is Maestro](#1-what-is-maestro)
2. [Philosophy & Principles](#2-philosophy--principles)
3. [Installation & Setup](#3-installation--setup)
4. [Project Structure](#4-project-structure)
5. [Delivery Commands](#5-delivery-commands)
6. [Utility Commands](#6-utility-commands)
7. [The Explore Phase](#7-the-explore-phase)
8. [The PRD Phase](#8-the-prd-phase)
9. [The Design Phase](#9-the-design-phase)
10. [The Plan Phase](#10-the-plan-phase)
11. [Execution & Review](#11-execution--review)
12. [Sessions & Artifacts](#12-sessions--artifacts)
13. [Decision Management](#13-decision-management)
14. [Templates](#14-templates)
15. [Configuration](#15-configuration)
16. [User & Team Profiles](#16-user--team-profiles)
17. [Delivery Pathways](#17-delivery-pathways)
18. [Output Standard](#18-output-standard)
19. [Agent Behavior Rules](#19-agent-behavior-rules)
20. [Maintenance & Issue Tracking](#20-maintenance--issue-tracking)
21. [Customization & Extension](#21-customization--extension)
22. [Design Decisions & Rationale](#22-design-decisions--rationale)
23. [Glossary](#23-glossary)

---

## 1. What Is Maestro

Maestro is an AI-assisted delivery framework. It turns an AI coding assistant (currently Claude Code) into a structured delivery partner that helps with the full project lifecycle: exploration, requirements, design, planning, implementation, and review.

**What Maestro IS:**
- A set of markdown command files that instruct the AI agent
- A folder structure for organizing delivery artifacts
- A decision tracking pipeline
- A session-based working model
- A set of templates for common deliverables

**What Maestro is NOT:**
- A standalone application (yet — see Symphony)
- A replacement for coding tools (it works alongside them)
- A rigid methodology (pathways are flexible)
- An AI model or service (it works with any AI that can read markdown)

**Core idea:** Every project needs more than code. Maestro handles the 80% of delivery that isn't typing code — understanding the problem, formalizing requirements, designing the solution, planning the work, tracking decisions, and reviewing results.

---

## 2. Philosophy & Principles

### Files Over Features

Everything is a markdown file in your repo. No database, no SaaS, no proprietary format. If you stop using Maestro tomorrow, all your artifacts remain readable.

### Sessions First

All work happens in sessions (your workbench). You promote artifacts to delivery (the showcase) when they're ready. This prevents half-baked work from becoming canonical.

### Decisions Are First-Class

Ideas become questions. Questions become decisions. Decisions flow into canonical artifacts. Nothing gets lost. Every decision has an audit trail.

### Flexible, Not Rigid

Maestro provides tools, not gates. You choose which phases to use and in what order. Want to build a PoC before writing requirements? Go for it. Want to skip the PRD for a personal project? That's fine. The framework adapts.

### The Agent Asks, Doesn't Assume

The AI never invents business requirements. When it doesn't know, it asks. When it's unsure, it flags (`GAP:`, `UNCLEAR:`). Questions are a first-class output.

### Concise by Default

No filler. Lead with the answer. Tables for comparisons, bullets for lists. The framework respects your time and context window.

---

## 3. Installation & Setup

### What "Installed" Means

Maestro is "installed" when these files exist in your project:
- `MAESTRO.md` — the framework instructions (the agent reads this)
- `.claude/commands/mae-*.md` — delivery command files (8 commands)
- `.claude/commands/{status,decide,sync,md}.md` — utility commands (4 commands)
- `.maestro/templates/*.md` — document templates (6 templates)

That's it. Maestro is a set of files. The AI agent reads `MAESTRO.md` on startup and follows its instructions. The commands are Claude Code slash commands that trigger specific behaviors.

### Installation Methods

#### Method 1: Shell Script (for developers)

```bash
# Clone the framework repo and run the installer
git clone https://github.com/pjasielski/maestro.git /tmp/maestro
/tmp/maestro/install.sh /path/to/your-project
```

What install.sh does:
1. Creates the folder structure (docs/, sessions/, notes/, templates/)
2. Copies MAESTRO.md, command files, and templates into your project
3. Creates tracking files (HANDOFF.md, DECISIONS.md, etc.) — only if they don't exist
4. Creates CLAUDE.md with a reference to MAESTRO.md — only if it doesn't exist
5. Creates maestro.toml with basic config

The installer is idempotent — running it again won't overwrite existing files.

#### Method 2: Manual Copy

Copy the framework files from the Maestro repo into your project manually. You need:
- `MAESTRO.md` → project root
- `.claude/commands/*.md` → `.claude/commands/` in your project
- `.maestro/templates/*.md` → `.maestro/templates/` in your project

Then create the tracking files and folder structure yourself, or run `/mae-init` in your first conversation.

#### Method 3: Python Package (future)

```bash
pip install maestro-delivery
# or
uv add maestro-delivery

maestro init my-project
```

This is planned but not yet implemented.

### First Conversation

After installation, start a Claude Code conversation in your project. The agent:
1. Reads `CLAUDE.md` → `MAESTRO.md`
2. Checks for existing sessions
3. Greets you with project status
4. If maestro.toml has no mode set, asks setup questions (mode, profile)

### The /mae-init Command

`/mae-init` is for projects where the framework is already in place (MAESTRO.md exists) but the project structure hasn't been set up. It creates folders, tracking files, and maestro.toml. It also offers optional profile setup.

**install.sh vs mae-init:** install.sh copies the framework INTO a project (from an external source). mae-init configures a project that already HAS the framework. For most users, install.sh is the entry point. mae-init is for edge cases or reconfiguration.

---

## 4. Project Structure

```
your-project/
├── MAESTRO.md                   ← Framework instructions (don't edit)
├── CLAUDE.md                    ← Your project config (edit this)
├── maestro.toml                 ← Framework settings
├── HANDOFF.md                   ← Project status & key decisions
├── DECISIONS.md                 ← Decision audit trail
├── OPEN_QUESTIONS.md            ← Questions needing answers
├── WORKLOG.md                   ← Activity log
│
├── docs/                    ← Confirmed, canonical artifacts
│   ├── 01-explore/              ← Explore report + confirmed analysis
│   ├── 02-requirements/                  ← REQUIREMENTS.md
│   ├── 03-design/               ← DESIGN.md
│   ├── 04-plan/                 ← PLAN.md + tasks/
│   │   └── tasks/               ← Task files (individual tickets)
│   ├── 05-implementation/       ← Implementation reports
│   ├── 06-review/               ← Review reports (on demand)
│   ├── 07-test/                 ← Test plans (on demand)
│   ├── 08-deploy/               ← Deployment config (on demand)
│   └── 09-maintenance/          ← Bugs & maintenance (on demand)
│       └── issues/              ← Issue files (bug-001.md, debt-001.md)
│
├── sessions/                    ← Working material (per-session folders)
│   ├── 001-project-start/
│   │   ├── _summary.md          ← Session summary (auto-updated)
│   │   └── 01_initial-scope.md  ← Numbered working artifacts
│   └── 002-api-design/
│       ├── _summary.md
│       └── ...
│
├── notes/                       ← Raw ideas, parking lot
│   └── ideas.md
│
├── .maestro/templates/          ← Document templates (customizable)
│   ├── task.md
│   ├── summary.md
│   ├── report.md
│   ├── prd.md
│   ├── sdd.md
│   └── explore.md
│
├── .claude/commands/            ← Framework commands
│   ├── mae-explore.md           ← Delivery commands (8)
│   ├── mae-req.md
│   ├── mae-design.md
│   ├── mae-plan.md
│   ├── mae-do.md
│   ├── mae-review.md
│   ├── mae-init.md
│   ├── mae-checkpoint (removed — use sync).md
│   ├── status.md                ← Utility commands (4)
│   ├── decide.md
│   ├── sync.md
│   └── md.md
│
└── src/                         ← Source code (project-specific)
```

### File Purposes

| File | Purpose | Updated By |
|------|---------|-----------|
| `MAESTRO.md` | Framework behavior — the agent reads this | Don't edit (shipped with framework) |
| `CLAUDE.md` | Project-specific config — project name, stack, phase | User edits |
| `maestro.toml` | Framework settings — mode, name, profile | `/mae-init` or user |
| `HANDOFF.md` | Single source of truth for project status | `/sync` (with review) |
| `DECISIONS.md` | Complete decision history | `/decide` |
| `OPEN_QUESTIONS.md` | Questions needing answers | Agent auto-manages |
| `WORKLOG.md` | Activity log | Auto-updated at session boundaries |

### Zones

| Zone | Editing | Purpose |
|------|---------|---------|
| **docs/** | Review required | Canonical, confirmed artifacts |
| **sessions/** | Free | Working material, drafts, analysis |
| **notes/** | Free | Ideas, parking lot |
| **.maestro/templates/** | User customizable | Document structure templates |

---

## 5. Delivery Commands

### /mae-init — Initialize

Sets up project structure and configuration. Run once at project start.

- Creates folder structure if missing
- Creates tracking files if missing
- Configures mode (solo/team) and optional user profile
- Detects if framework is already initialized

### /mae-explore — Build Understanding

The most sophisticated command. Adapts to project state and produces the most useful artifact.

**Modes:**
- No arguments → smart default (detects state, produces most useful artifact)
- `{topic}` → targeted analysis
- `{file path}` → analyze/summarize a document
- `ask` → generate questions for the user or external audiences
- `ask {audience}` → questions for: user, client, team, technical
- `doc` → synthesize final explore report from all artifacts

**Key behaviors:**
- On first explore: scans for existing resources (docs/, data/, src/), asks before reading
- Every artifact includes questions to deepen understanding
- Tracks readiness signals (scope, coverage, gaps) and updates `_summary.md`
- Final report uses `.maestro/templates/explore.md`

### /mae-req — Formalize Requirements

Generates PRD from explore artifacts using `.maestro/templates/requirements.md`.

**Key behaviors:**
- Prioritizes reading the final explore report over individual artifacts
- Warns if explore report has unresolved gaps
- Populates user stories (Section 6) with concrete stories and acceptance criteria
- Saves draft to session, offers promotion to `docs/02-requirements/REQUIREMENTS.md`

### /mae-design — Technical Architecture

Creates SDD from PRD + explore report using `.maestro/templates/design.md`.

**Modes:**
- No arguments → full solution design
- `{component}` → detailed component spec
- `{file path}` → file-level implementation spec

**Key behaviors:**
- Reads both PRD and explore report (technical sections)
- Presents technical questionnaire before generating SDD (for decisions it can't make)
- Cross-phase awareness: suggests running `/mae-explore` when information is missing
- Saves draft to session, offers promotion to `docs/03-design/DESIGN.md`

### /mae-plan — Break Into Tasks

Reads SDD and creates task files in `docs/04-plan/tasks/`.

**Exception:** Tasks go directly to docs/ (not sessions-first) because they're immediately actionable.

### /mae-do — Execute Work

Universal task executor. Handles code, docs, config, PoCs.

**Modes:**
- No arguments → smart suggestion (what to work on next)
- `task-{NNN}` → execute a specific planned task
- `"{description}"` → ad-hoc task

**PoC support:** Can be used at any point to build prototypes, even before requirements are defined. Encouraged for validating direction early.

### /mae-review — Review Work

Reviews code or delivery artifacts against the SDD and PRD.

### /mae-checkpoint (removed — use sync) — Save Snapshot

Creates named snapshots of project state for progress tracking.

**Modes:**
- `{name}` → save a checkpoint
- `list` → show all checkpoints
- `compare {a} {b}` → compare two checkpoints

---

## 6. Utility Commands

### /decide — Record Decision

Records a decision in `DECISIONS.md` and updates `_summary.md`. Creates an audit trail entry with date, session, and decision text. Can resolve open questions.

### /sync — Push to Canonical Files

Batch-updates canonical files (HANDOFF.md, docs/ artifacts) based on accumulated decisions. Every edit requires user review and approval.

### /status — Project Overview

Shows current project state.

**Sub-commands:**
- `/status` → overview (phase, task counts, blockers, recent activity)
- `/status tasks` → full task board by status
- `/status decisions` → decision summary with unsynced items
- `/status questions` → open questions by priority

### /md — Save Response

Saves the current response to a numbered markdown file in the session folder.

---

## 7. The Explore Phase

### Purpose

Build mutual understanding between the user and the AI agent. Understand the problem, the business context, the technical landscape, the stakeholders, and the risks.

### How It Works

1. **First explore:** Agent scans the project for existing resources. Reports what it finds. Asks which resources to include. Produces initial scope analysis with questions.

2. **Iterative exploration:** Each subsequent explore reads existing artifacts, assesses readiness (what's covered, what's missing), and produces the most useful next artifact. This could be a deeper analysis, a gap analysis, a risk assessment, or more questions.

3. **Ask mode:** Explicit question generation. Produces structured question documents with space for async responses. The user or client fills in answers in the file. Next explore reads the answers and incorporates them.

4. **Final report:** `explore doc` synthesizes all exploration artifacts into a structured report using `.maestro/templates/explore.md`. This report becomes the input for the PRD phase.

### Readiness Signals

The agent evaluates exploration readiness based on:
- Is the scope defined (business + technical overview)?
- Are key questions resolved?
- Do artifacts cover business, technical, AND stakeholder angles?
- Are blocking gaps unresolved?
- Has the user indicated readiness?

After each explore artifact, the agent updates a readiness assessment in `_summary.md`.

### Artifacts

Explore artifacts are free-form — no template required for working artifacts. Only the final report (`doc`) uses the template. Artifacts are numbered files in the session folder.

---

## 8. The PRD Phase

### Purpose

Formalize what you're building. Transform the understanding from exploration into structured product requirements.

### Input Priority

1. Final explore report (primary — the synthesis)
2. Individual explore artifacts (fallback if no report)
3. DECISIONS.md, OPEN_QUESTIONS.md
4. maestro.toml (project context)
5. .maestro/templates/requirements.md (structure)

The PRD does NOT read raw sources (docs/, data/). That's explore's job. The explore report should contain everything the PRD needs.

### Template Structure

7 core sections: Problem Statement, Users & Personas, Goals & Success Criteria, Requirements, Scope, Epics & User Stories, Risks.

3 optional sections: Constraints, Release Strategy, Glossary.

User stories follow the standard format: "As a {persona}, I want {action}, so that {benefit}" with acceptance criteria.

---

## 9. The Design Phase

### Purpose

Define how to build it. Translate product requirements into technical architecture.

### Input Priority

1. PRD (requirements — what to build)
2. Explore report (technical context — current state, constraints, integrations)
3. DECISIONS.md (confirmed technical decisions)
4. maestro.toml (user profile for adaptation)
5. .maestro/templates/design.md (structure)

### Technical Questionnaire

Before generating the SDD, the agent identifies technical decisions it can't make from available information. These are categorized:

- **Must Answer:** Blocks the architecture. User must decide.
- **Recommend:** Agent has a suggestion. User confirms or overrides.
- **Your Call:** Multiple valid approaches. Agent presents trade-offs.

### Cross-Phase Awareness

If the design reveals missing information, the agent suggests returning to explore: "This design decision requires information we don't have. Consider running `/mae-explore {topic}`."

### Three Levels

1. **Full solution** (no args) — system architecture, components, tech stack, data model
2. **Component** (`{name}`) — detailed spec for one component
3. **File-level** (`{path}`) — implementation spec for a specific file

---

## 10. The Plan Phase

Creates task files from the SDD. Each task is a markdown file in `docs/04-plan/tasks/` — your Jira replacement.

Tasks have: description, acceptance criteria, referenced files, effort estimate, dependencies, status (todo → in-progress → done).

---

## 11. Execution & Review

### /mae-do

Executes tasks. Can work from planned tasks or ad-hoc descriptions. Loads minimal context — only the files needed for the current task.

PoC/prototype tasks can be run at any point in the delivery process, even before requirements are defined.

### /mae-review

Reviews code or artifacts. Can review against the SDD, PRD, or general quality standards.

---

## 12. Sessions & Artifacts

### What Is a Session?

A session is a folder in `sessions/` representing a stretch of related work. It contains:
- `_summary.md` — living summary (auto-updated by the agent)
- Numbered artifacts (`01_description.md`, `02_description.md`, etc.)

### Session vs Delivery

| | Sessions | Delivery |
|---|---------|---------|
| **Purpose** | Workbench — drafts, analysis, working material | Showcase — confirmed, canonical artifacts |
| **Editing** | Free zone (no permission needed) | Review required |
| **Naming** | `{NNN}-{descriptive-name}/` | Phase-based folders |
| **Promotion** | User promotes to delivery when ready | Target of promotion |

### Artifact Numbering

Files in sessions use `NN_kebab-case-description.md` format. Sequential numbering within each session.

---

## 13. Decision Management

### The Pipeline

```
notes/ideas.md  →  OPEN_QUESTIONS.md  →  DECISIONS.md  →  Canonical files
"what if?"         "should we?"           "we decided"     (via /sync)
```

### Decision Markers

Used in `_summary.md`:
- `✓` Confirmed — locked in, ready to sync
- `~` Proposed — direction agreed, details TBD
- `?` Tentative — floated but not discussed
- `⏸` Parked — deliberately deferred

### Auto-Update

The agent auto-updates `_summary.md` when decisions are confirmed, proposed, parked, or when questions are identified/resolved.

---

## 14. Templates

All templates use the **core + optional** pattern:
- Core sections are always included
- Optional sections (marked with HTML comments) are included when relevant
- Empty optional sections are omitted, not left as placeholders

| Template | Purpose | Core | Optional |
|----------|---------|------|----------|
| `prd.md` | Product Requirements | 7 sections | 3 (constraints, release, glossary) |
| `sdd.md` | Solution Design | 6 sections | 5 (AI/ML, integrations, infra, security, performance) |
| `explore.md` | Explore Report | 6 sections | 4 (stakeholders, change readiness, data, AI feasibility) |
| `task.md` | Task File | 4 fields | — |
| `summary.md` | Session Summary | 4 sections | — |
| `report.md` | Command Report | 5 sections | — |
| `issue.md` | Bug/Maintenance Issue | 5 fields | Steps to Reproduce |

Templates are customizable — edit them in `.maestro/templates/` to match your domain.

---

## 15. Configuration

### maestro.toml

```toml
[project]
name = "my-project"
mode = "solo"         # "solo" or "team"

# Optional — user profile (solo mode)
[user]
description = "Senior Python architect, new to frontend"
strengths = ["backend", "python", "system-design"]
needs_help = ["frontend", "ux"]

# Optional — team profiles (team mode)
[[team.members]]
name = "Piotr"
role = "architect"
strengths = ["backend", "python"]
needs_help = ["frontend"]
```

### CLAUDE.md

Project-specific configuration. References MAESTRO.md for framework behavior. Contains:
- Project name, description, stack
- Current phase
- Active session pointer
- Any project-specific notes or overrides

---

## 16. User & Team Profiles

Optional. Helps the agent adapt its assistance.

### How Adaptation Works

- **Explanation depth:** More detail in areas outside the user's strengths
- **Recommendation strength:** Stronger recommendations where help is needed
- **Question targeting:** Fewer questions in strength areas, more in weakness areas
- **Artifact detail:** More scaffolding in sections the user relies on

### Solo vs Team

- Solo: `[user]` section in maestro.toml
- Team: `[[team.members]]` array — agent asks "Who am I working with?" at session start

If no profile is configured, the agent behaves generically.

---

## 17. Delivery Pathways

Maestro does not enforce a rigid sequence. Phases are tools, not gates.

### Standard
```
explore → prd → design → plan → do → review
```
Full process. Best for client projects, regulated industries, complex systems.

### PoC-First
```
explore (light) → do (PoC) → [feedback] → explore (refined) → prd → design → do
```
Validate direction early. Best for uncertain requirements, stakeholder buy-in needed.

### Fast-Track
```
explore → design → do → review
```
Skip formal PRD. Best for personal projects, clear requirements.

### Iterative
```
explore → prd → do (MVP) → [feedback] → explore → prd (revised) → do
```
Continuous refinement. Best for startups, evolving products.

The agent suggests next steps based on what exists but never blocks the user from choosing a different path.

---

## 18. Output Standard

Every response follows these rules:
- Lead with the answer, not the reasoning
- Tables for comparisons, bullets for lists
- Balance: explanation (30%), structure/data (50%), questions/considerations (20%)
- No filler, no hedging
- Every substantive response saved as a numbered session file
- Chat output = brief summary, not a duplicate of the file

### Flags

| Flag | When |
|------|------|
| `CONSISTENCY:` | Contradiction between artifacts |
| `GAP:` | Missing information |
| `UNCLEAR:` | Ambiguous requirement |
| `STALE:` | Outdated reference |
| `DRIFT:` | Code diverges from SDD |

---

## 19. Agent Behavior Rules

### File Permissions
- **Free zone:** Create new files anywhere. Edit sessions/, notes/. Append to WORKLOG.md, DECISIONS.md.
- **Review required:** Edit HANDOFF.md, docs/ files, source code, maestro.toml, OPEN_QUESTIONS.md.

### Context Budget
- Target: 4,000-8,000 words of reference material per task
- Load only what's needed. When in doubt, load less and ask.

### Proactive Questions
Ask without a command only when:
1. Ambiguity blocks the current task
2. A contradiction is detected
3. A component isn't in the SDD
4. A security concern is spotted

### File Size Limits
| File | Target | Max |
|------|--------|-----|
| HANDOFF.md | 200-300 lines | 400 |
| REQUIREMENTS.md | 1,500-3,000 words | 5,000 |
| DESIGN.md | 2,000-4,000 words | 6,000 |
| Task file | 200-500 words | 800 |

---

## 20. Maintenance & Issue Tracking

For post-delivery maintenance, bugs, and tech debt:

```
docs/09-maintenance/
└── issues/
    ├── bug-001-login-timeout.md
    ├── bug-002-csv-export-encoding.md
    └── debt-001-refactor-auth-module.md
```

Issues use `.maestro/templates/issue.md` with types: bug, tech-debt, improvement, maintenance.
Statuses: open → investigating → in-progress → resolved → closed (or wont-fix).

**Assignment:** Each issue has an `Assigned:` field. In team mode, `/status` shows issues grouped by assignee.

**Integration with /mae-do:** Issues appear in the smart task suggestion flow. `/mae-do issue-001` executes a specific fix. The agent updates the issue file with resolution details.

---

## 21. Customization & Extension

### Custom Commands

Create a `.md` file in `.claude/commands/`:
- `mae-{name}.md` for delivery commands
- `{name}.md` for utility commands

### Custom Templates

Edit files in `.maestro/templates/` to match your domain. Add industry-specific sections, compliance requirements, etc.

### Extending Delivery Structure

Add folders for project-specific needs:
- `docs/05-implementation/` — implementation reports from /mae-do
- `docs/06-review/` — formal reviews
- `docs/07-test/` — test plans
- `docs/08-deploy/` — deployment config
- `docs/09-maintenance/issues/` — bugs, tech debt

---

## 22. Design Decisions & Rationale

Key decisions made during framework development:

| # | Decision | Choice | Why |
|---|----------|--------|-----|
| 1 | Framework split | MAESTRO.md + CLAUDE.md | MAESTRO is framework-generic (shipped); CLAUDE is project-specific (user owns) |
| 2 | Command format | Markdown files | No build step, human-readable, version-controlled |
| 3 | Command naming | Dashes (`/mae-explore`) | Flat files, easier typing than colons |
| 4 | Artifact flow | Sessions-first | Structural safety — prevents accidental canonical edits |
| 5 | Explore design | Adaptive smart default | Works for simple (one explore) and complex (many explores) projects |
| 6 | Template pattern | Core + optional sections | Flexible without being overwhelming |
| 7 | MVP scope | 8 delivery + 4 utility commands | Minimal overhead, covers full lifecycle |
| 8 | Config format | TOML | Python native, no indent bugs |
| 9 | Task management | Files in docs/04-plan/ | Lightweight Jira replacement in your repo |
| 10 | Pathways | Flexible, not sequential | AI-assisted delivery is inherently iterative |
| 11 | User profiles | Optional [user]/[[team.members]] | Adapts without requiring configuration |
| 12 | Question handling | explore ask + natural conversation | Questions are first-class, not an afterthought |

For full rationale on each decision, see `sessions/001-framework-bootstrap/11_design_decisions_reference.md`.

---

## 23. Glossary

| Term | Definition |
|------|-----------|
| **Artifact** | A document or file produced during delivery (analysis, PRD, SDD, task, etc.) |
| **Canonical** | The confirmed, authoritative version of an artifact (lives in docs/) |
| **Delivery** | The full project lifecycle managed by Maestro. Canonical artifacts live in `docs/` organized by phase |
| **Explore** | The initial phase of building project understanding |
| **Flag** | An inline marker (GAP:, UNCLEAR:, etc.) highlighting issues |
| **Pathway** | A chosen sequence through delivery phases (standard, PoC, iterative, etc.) |
| **Phase** | A stage in the delivery lifecycle (explore, prd, design, plan, do, review) |
| **Promote** | Moving an artifact from sessions/ to docs/ after review |
| **PRD** | Product Requirements Document |
| **SDD** | Solution Design Document (also called technical architecture) |
| **Session** | A working folder in sessions/ representing a stretch of related work |
| **Sync** | Pushing confirmed decisions from _summary.md to canonical files |
| **Working material** | Artifacts in sessions/ — drafts, analysis, exploration. Not canonical. |
