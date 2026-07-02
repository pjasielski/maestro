# DESIGN: Maestro — AI-Assisted Project Delivery Framework

**Date:** 2026-06-18
**Version:** v0.2.0
**Status:** Draft — reconciled
**Requirements:** docs/02-requirements/REQUIREMENTS.md
**Changes from v0.1:** Renamed from SDD.md. DESIGN.md as universal artifact name. ROADMAP.md moved to docs/04-plan/. Checkpoint absorbed into sync. Session 010 consolidation decisions.

---

## 1. Overview

### 1.1 Purpose

Technical architecture for the Maestro delivery framework. Covers the command system, artifact flow, state management, installer, multi-tool adapters, and integration points. Addresses requirements FR-01 through FR-17 from the PRD.

### 1.2 Scope

- Command execution model (markdown-based instructions)
- File system architecture (.sessions/, docs/, tracking files)
- Configuration system (maestro.toml)
- Template system
- Installer and setup (install.sh, setup wizard)
- Multi-tool adapter pattern
- PoC workflow architecture
- ai-deck integration architecture
- Future CLI architecture (Python)

### 1.3 Design Principles

1. **Files over features** — Everything is a plain-text file. No database, no runtime, no server. The filesystem IS the application state.
2. **Instructions over code** — Commands are markdown instructions for AI tools, not executable scripts. The AI tool is the runtime.
3. **Convention over configuration** — Folder structure and naming conventions minimize the need for config. maestro.toml is optional.
4. **Sessions-first, promote later** — All output goes to working space first. Canonical artifacts are explicitly promoted, never silently mutated.
5. **Tool-neutral core, tool-specific adapters** — MAESTRO.md and .maestro/commands/ are tool-agnostic. Tool-specific wiring lives in adapters (.claude/commands/, .cursor/rules/).

---

## 2. Architecture

### 2.1 System Diagram

```
┌─────────────────────────────────────────────────────┐
│                    USER                              │
│                                                      │
│  Runs: /mae-explore, /mae-req poc, /mae-do, etc.   │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│              AI TOOL (Runtime)                        │
│  Claude Code │ Cursor │ Codex │ Copilot             │
│                                                      │
│  Reads: adapter file → .maestro/commands/ → MAESTRO.md│
│  Produces: session artifacts, delivery artifacts     │
└──────────────┬──────────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────────┐
│              FILE SYSTEM (State)                     │
│                                                      │
│  ┌───────────┐  ┌──────────┐  ┌───────────────┐    │
│  │.sessions/ │  │ docs/│  │ tracking files │    │
│  │ (working) │──│ (canon.) │  │ HANDOFF.md     │    │
│  └───────────┘  └──────────┘  │ DECISIONS.md   │    │
│       promote ──────►         │ WORKLOG.md     │    │
│                               └───────────────┘    │
└─────────────────────────────────────────────────────┘
```

### 2.2 Component Overview

| Component | Responsibility | Technology | Notes |
|---|---|---|---|
| **Command files** | Define behavior for each docs/utility command | Markdown (.md) | Source of truth in .maestro/commands/; adapters in .claude/commands/ etc. |
| **MAESTRO.md** | Framework-level instructions: rules, context loading, output standards | Markdown | Read by AI tool at session start; tool-agnostic |
| **CLAUDE.md** | Project-specific config and instructions | Markdown | Claude Code convention; other tools use their equivalents |
| **maestro.toml** | Framework settings: session visibility, profile, project metadata | TOML | Optional; framework works with sensible defaults |
| **Templates** | Structural templates for delivery artifacts | Markdown | .maestro/templates/ directory; core + optional section pattern |
| **Installer** | Sets up framework in a project directory | Shell (bash) | install.sh; supports curl pipe bash and local execution |
| **Setup wizard** | Browser-based configuration UI | HTML + JS | setup/index.html; generates install command |
| **Tracking files** | Project state: HANDOFF.md, DECISIONS.md, OPEN_QUESTIONS.md, WORKLOG.md | Markdown | Root-level files; HANDOFF.md is the primary context source |
| **Session manager** | Organizes working artifacts into numbered sessions | Convention | .sessions/NNN-name/ with _summary.md and numbered files |
| **Delivery folders** | Stores canonical, promoted artifacts | Convention | docs/01-explore/ through docs/09-maintenance/ |

### 2.3 Data Flow

| Step | From | To | Data | Mechanism |
|---|---|---|---|---|
| 1 | User | AI Tool | Command invocation (/mae-explore, /mae-req poc, etc.) | Slash command or prompt |
| 2 | AI Tool | Adapter file | Dispatch | Tool reads .claude/commands/mae-explore.md |
| 3 | Adapter | .maestro/commands/ | Delegation | Adapter says "follow .maestro/commands/mae-explore.md" |
| 4 | Command file | File system | Context loading | Command reads specified inputs (HANDOFF.md, docs/, etc.) |
| 5 | AI Tool | .sessions/ | Output | Numbered artifact saved to current session folder |
| 6 | User | docs/ | Promotion | User confirms; AI copies session artifact to docs/ |
| 7 | AI Tool | Tracking files | State update | HANDOFF.md, DECISIONS.md, WORKLOG.md updated via /sync or /decide |

---

## 3. Tech Stack

| Category | Choice | Alternatives Considered | Rationale |
|---|---|---|---|
| Command format | Markdown (.md) | YAML, JSON, Python scripts | Markdown is readable by humans and AI tools; no parsing needed; editable in any editor |
| Configuration | TOML (maestro.toml) | YAML, JSON, .env | Python-native, no indent foot-guns (unlike YAML), cleaner than JSON for humans |
| Installer | Bash (install.sh) | Python CLI, npm, Homebrew | Zero dependencies; curl pipe bash is universally supported; matches non-technical user needs |
| Setup wizard | Static HTML + vanilla JS | React, Python server | No build step; opens in any browser; server.py is optional convenience |
| Adapter pattern | Per-tool config files | Unified abstraction layer | Each AI tool has its own config convention; thin wrappers are the least-friction approach |
| State management | Plain files + git | SQLite, config database | Aligns with "files over features" principle; git provides versioning and collaboration for free |

### ADRs (Architecture Decision Records)

**ADR-001: Commands as Markdown Instructions, Not Executable Code**
- **Context:** Commands need to work across AI tools with different execution models. Some tools run code (Claude Code), others process instructions (Cursor rules).
- **Decision:** Commands are markdown files containing behavioral instructions. The AI tool reads and follows them — no code execution.
- **Consequences:** Output quality depends on AI model compliance. Commands cannot perform deterministic operations (file validation, API calls). Benefit: universal portability.

**ADR-002: Sessions-First Artifact Flow**
- **Context:** AI output quality varies. Directly writing to canonical docs/ folders risks polluting the audit trail with draft-quality content.
- **Decision:** All command output goes to .sessions/ first. User reviews, then explicitly promotes to docs/.
- **Consequences:** Extra step for the user (promotion). Benefit: docs/ stays clean and trustworthy. Exception: /mae-plan writes tasks directly to docs/04-plan/tasks/ (tasks are immediately actionable).

**ADR-003: TOML Over YAML for Configuration**
- **Context:** Need a human-editable configuration format for project settings, user profiles, and team definitions.
- **Decision:** TOML (maestro.toml) as the single configuration format.
- **Consequences:** Python-native parsing (stdlib tomllib in 3.11+). No indentation sensitivity. Less familiar than YAML to some users. Adequate for the flat/shallow config structure Maestro needs.

**ADR-004: Adapter Pattern for Multi-Tool Support**
- **Context:** Claude Code uses .claude/commands/, Cursor uses .cursor/rules/, Codex has its own conventions. A single format cannot serve all tools.
- **Decision:** Canonical command logic lives in .maestro/commands/. Per-tool adapters are thin wrappers that reference the canonical files.
- **Consequences:** Command logic maintained in one place. Adding a new tool requires only adapter files. Adapters are generated by install.sh. Downside: each tool requires install.sh awareness.

**ADR-005: Session Visibility Over Solo/Team Mode**
- **Context:** The original solo/team mode controlled two concerns: whether sessions are gitignored and whether team features (WORKLOG "who" column, /sync requirement) are active. These concerns are independent.
- **Decision:** Replace `mode = "solo/team"` with `session_visibility = "committed/gitignored"`. Team features are inferred from `[[team.members]]` presence in maestro.toml.
- **Consequences:** Cleaner separation of concerns. Supports the open-source solo project scenario (sessions gitignored, no team). Installer asks one question instead of two.

**ADR-006: PoC as Command Flag, Not Separate Command**
- **Context:** Users need lightweight, prototype-focused artifacts. Two approaches: a dedicated `/mae-poc` command, or a `poc` flag on existing commands.
- **Decision:** PoC is a flag on existing delivery commands (`/mae-req poc`, `/mae-design poc`, etc.). PoC artifacts use separate files (REQUIREMENTS-poc.md) and are archived to `docs/poc/` when production versions replace them.
- **Consequences:** No new command to learn. Same workflow, lighter requirements. Natural upgrade path from PoC to production. Each command file needs a `## PoC Mode` section.

---

## 4. Data Model

### 4.1 Entities

| Entity | Key Fields | Relationships | Notes |
|---|---|---|---|
| **Project** | name, session_visibility, description | Has sessions, delivery artifacts, config | Defined by maestro.toml + directory structure |
| **Session** | number, name, started date | Contains artifacts, summary | Folder: .sessions/NNN-name/ |
| **Session Artifact** | number, description, type | Belongs to session; may be promoted to delivery | File: NN_description.md |
| **Delivery Artifact** | phase, type (PRD/SDD/task/etc.) | Belongs to delivery phase | File in docs/NN-phase/ |
| **PoC Artifact** | phase, type, poc flag | Delivery artifact with -poc suffix | File: REQUIREMENTS-poc.md; archived to docs/poc/ |
| **Task** | ID, title, status, priority, effort | Belongs to plan; references SDD components | File: docs/04-plan/tasks/task-NNN.md |
| **Implementation Report** | date, task reference, findings | Belongs to implementation phase | File: docs/05-implementation/YYYYMMDD_task-name.md |
| **Decision** | date, session, decision text, status | Referenced by HANDOFF.md | Row in DECISIONS.md |
| **Open Question** | priority, question text, blocks | May become a decision | Row in OPEN_QUESTIONS.md |
| **User Profile** | description, strengths, needs_help | Belongs to project config | Section in maestro.toml |
| **Team Member** | name, role, strengths, needs_help | Part of team config; presence triggers team features | Entry in [[team.members]] in maestro.toml |
| **Command** | name, behavior, prerequisites, outputs | References templates, delivery artifacts | File in .maestro/commands/ |
| **Template** | name, sections (core + optional) | Used by commands to generate artifacts | File in .maestro/templates/ |

### 4.2 File System as ER Diagram

```
maestro.toml
  └─── [project] ─── name, session_visibility, description
  └─── [user] ─── description, strengths, needs_help
  └─── [[team.members]] ─── name, role, strengths, needs_help
                             (presence triggers team features)

HANDOFF.md ──references──► DECISIONS.md
    │                          │
    └─── status, phase         └─── date, session, decision, status
    └─── architecture
    └─── priorities

.sessions/
  └─── NNN-name/
        ├─── _summary.md (decisions, open items, files)
        └─── NN_artifact.md ───may promote to──► docs/NN-phase/

docs/
  ├─── 01-explore/  ──► explore reports, transcripts
  ├─── 02-requirements/ ──► REQUIREMENTS.md (and REQUIREMENTS-poc.md during PoC)
  ├─── 03-design/   ──► DESIGN.md (and DESIGN-poc.md during PoC)
  ├─── 04-plan/     ──► ROADMAP.md, tasks/task-NNN.md
  ├─── 05-implementation/ ──► implementation reports (on demand)
  ├─── 06-review/   ──► review reports (on demand)
  ├─── 07-test/     ──► test plans (on demand)
  ├─── 08-deploy/   ──► deployment config (on demand)
  ├─── 09-maintenance/ ──► issues/, tech debt (on demand)
  └─── poc/         ──► archived PoC artifacts (on demand)
```

---

## 5. Source Structure

```
maestro/                          ← Framework repository root
├── MAESTRO.md                    ← Framework instructions (tool-agnostic)
├── CLAUDE.md                     ← Project config for Claude Code
├── maestro.toml                  ← Framework settings (when created)
├── HANDOFF.md                    ← Project state (single source of truth)
├── DECISIONS.md                  ← Decision audit trail
├── OPEN_QUESTIONS.md             ← Questions needing answers
├── WORKLOG.md                    ← Activity log
├── ROADMAP.md                    ← Strategic backlog by milestone
├── CHANGELOG.md                  ← Release notes per version
├── README.md                     ← Public-facing overview + quick start
│
├── .maestro/                     ← Framework command source of truth
│   └── commands/
│       ├── mae-explore.md        ← Delivery commands (8)
│       ├── mae-explore-lite.md
│       ├── mae-req.md
│       ├── mae-design.md
│       ├── mae-plan.md
│       ├── mae-do.md
│       ├── mae-review.md
│       ├── sync.md
│       ├── mae-init.md
│       ├── decide.md             ← Utility commands (4)
│       ├── sync.md
│       ├── status.md
│       └── md.md
│
├── .claude/                      ← Claude Code adapter
│   └── commands/
│       ├── mae-explore.md        ← Thin wrappers → .maestro/commands/
│       └── ...
│
├── .cursor/                      ← Cursor adapter (generated by installer)
│   └── rules/
│       ├── maestro-core.mdc
│       └── maestro-dispatch.mdc
│
├── .github/                      ← Codex adapter (generated by installer)
│   └── copilot-instructions.md
│
├── docs/                     ← Canonical delivery artifacts
│   ├── 01-explore/
│   ├── 02-requirements/          ← REQUIREMENTS.md
│   ├── 03-design/                ← DESIGN.md
│   ├── 04-plan/
│   │   ├── tasks/                ← Task files
│   │   └── reports/              ← Implementation reports
│   ├── 05-implementation/        ← Implementation reports (on demand)
│   ├── 06-review/                ← Review reports (on demand)
│   ├── 07-test/                  ← Test plans (on demand)
│   ├── 08-deploy/                ← Deployment config (on demand)
│   ├── 09-maintenance/           ← Issues, tech debt (on demand)
│   │   └── issues/
│   └── poc/                      ← Archived PoC artifacts (on demand)
│
├── .sessions/                    ← Working session folders
│   ├── 003-framework-evolution/
│   ├── 005-review/               ← Current review session
│   └── 009-prd-sdd-roadmap/
│
├── .maestro/templates/           ← Document templates
│   ├── prd.md
│   ├── sdd.md
│   ├── explore.md
│   ├── task.md
│   ├── summary.md
│   ├── report.md
│   ├── review.md
│   ├── issue.md
│   └── roadmap.md
│
├── setup/                        ← Browser-based setup wizard
│   ├── index.html
│   └── server.py
│
├── docs/                         ← Documentation
│   ├── installation.md
│   ├── user-guide.md
│   ├── tool-support.md           ← Capability matrix (to be created)
│   └── reference.md
│
├── install.sh                    ← Framework installer
└── notes/                        ← Raw ideas (notes/ideas.md)
```

---

## 6. Component Details

### 6.1 Command System

**Canonical commands** live in `.maestro/commands/mae-*.md`. Each command file defines:
- Prerequisites (what must exist before running)
- Behavior (step-by-step instructions for the AI)
- Output behaviors (what to flag, format, include)
- PoC Mode section (how behavior changes with `poc` flag)
- File size limits

**Adapter pattern:**
```
User types: /mae-explore
    │
    ▼
Tool reads: .claude/commands/mae-explore.md (adapter)
    │ Contains: "Follow .maestro/commands/mae-explore.md"
    ▼
AI follows: .maestro/commands/mae-explore.md (canonical)
    │ Contains: full behavioral instructions
    ▼
AI reads: MAESTRO.md (framework rules, output tiers, context loading)
```

Cursor adapters use `.cursor/rules/maestro-dispatch.mdc` which maps command names to `.maestro/commands/` files.

**PoC flag behavior (all commands):**
- Output file uses `-poc` suffix (e.g., `REQUIREMENTS-poc.md`)
- Header includes `**Phase: PoC**` banner
- Requirements are relaxed (command-specific)
- Additional sections: `## PoC Limitations`, `## Production Delta`
- When running without `poc` and a PoC artifact exists, use it as starting point

### 6.2 Installer (install.sh)

**Modes:**
- **Interactive** (default): One question — session visibility (committed or gitignored)
- **Quick** (`--quick`): No prompts, defaults to committed sessions
- **Preconfigured** (`--preconfigured`): Settings via environment variables (used by setup wizard)
- **Self-download** (curl pipe bash): Downloads files from GitHub, then runs installation

**What the installer always does:**
- Creates full folder structure (docs/01 through 08, .sessions/, notes/, templates/, .maestro/commands/)
- Installs all tool adapters (.claude/commands/, .cursor/rules/, .github/copilot-instructions.md)
- Copies framework files (MAESTRO.md, .maestro/commands/) — always updates to latest
- Copies templates using `create_if_missing` — never overwrites user customizations
- Creates tracking files using `create_if_missing` (HANDOFF.md, DECISIONS.md, etc.)
- Creates maestro.toml using `create_if_missing`

**File handling rules:**
- **Tracking files** (HANDOFF.md, DECISIONS.md, etc.): `create_if_missing` — never overwrite
- **Framework files** (MAESTRO.md, .maestro/commands/): Overwrite on install (they track upstream)
- **Templates** (.maestro/templates/*.md): `create_if_missing` — user may have customized
- **Config** (maestro.toml): `create_if_missing` — user's settings
- **Adapters** (.claude/, .cursor/, .github/): Regenerated on install (generated from commands)

**Self-download validation:**
- All download commands must fail fast (no `|| true`)
- Post-download: verify all expected files exist before proceeding
- Complete template list includes: prd, sdd, explore, task, summary, report, review, issue, roadmap

### 6.3 Configuration (maestro.toml)

```toml
[project]
name = "my-project"
session_visibility = "committed"  # or "gitignored"

# Output tier default: "standard" | "verbose" | "caveman"
output_tier = "standard"

[user]
description = "Senior Python architect, new to frontend"
strengths = ["backend", "python", "system-design"]
needs_help = ["frontend", "ux"]

# Team features activate when [[team.members]] is defined
# [[team.members]]
# name = "Piotr"
# role = "architect"
# strengths = ["backend", "python"]
# needs_help = ["frontend"]
```

**Team detection:** If `[[team.members]]` entries exist, the framework activates team features:
- WORKLOG.md includes "Who" column
- /sync becomes a required step after implementation batches
- Agent asks "Who am I working with?" at session start

### 6.4 Template System

Templates use a **core + optional** pattern:
```markdown
## 1. Core Section (always included)
{content}

<!-- OPTIONAL: Include when relevant -->
## 8. Optional Section
{content}
```

Commands reference templates for output structure. The AI reads the template and fills in content from its inputs. HTML comments mark optional sections — the AI includes or omits them based on project relevance.

### 6.5 Context Loading

Each command defines what to read and what to skip (specified in MAESTRO.md's Task-Based Loading table). The context budget is 4,000–8,000 words of reference material per task.

**Loading priority:** HANDOFF.md → command-specific inputs → maestro.toml → templates

### 6.6 ai-deck Integration Architecture

```
Maestro                              ai-deck (separate repo)
───────                              ──────────────────────
/mae-deck md ──delegates──►          draft command logic
/mae-deck html ──delegates──►        build command logic

~/.maestro/ai-deck/                  Asset storage
├── commands/                        Command files
├── templates/                       HTML template
├── components/                      Backgrounds, separators, layouts
└── themes/                          Cosmic theme + future themes
```

**Integration model:** Model A (scripts + pure agentic fallback)
- install.sh copies ai-deck assets to `~/.maestro/ai-deck/`
- /mae-deck command checks for Python; if available, runs deterministic scripts; if not, AI assembles HTML directly
- Zero additional pip dependencies for Maestro users

**Phased delivery:**
1. Phase 1: Pure agentic (command files + templates + components, AI assembles)
2. Phase 2: Deterministic scripts (Python stdlib only, auto-detected)
3. Phase 3: Optional pip package for standalone use

---

## 7. Resolved Questions

| # | Question | Resolution | Decided in |
|---|---|---|---|
| 1 | `.sessions/` or `sessions/` as canonical? | `.sessions/` is canonical; `sessions/` supported as alternative | Session 005 |
| 2 | Framework files overwrite on re-install? | Yes — framework files (MAESTRO.md, commands) update to latest. Templates and config use create_if_missing. | Session 005 |
| 3 | Full Jira replacement scope? | Not Jira-like exactly; well-incorporated into workflow for PMs, devs, and agents | Session 005/009 |
| 4 | `/mae-poc` command or flag? | Flag on existing commands (e.g. `/mae-req poc`). PoC artifacts as separate files, archived when done. | Session 005 |
| 5 | Optional capabilities (ai-deck)? | ai-deck is optional; /mae-deck gracefully reports if not installed | Session 009 |
| 6 | Solo/team mode? | Replaced by session_visibility + team inference from [[team.members]] | Session 005 |
| 7 | Tool adapter installation? | All adapters installed by default; unused adapters are inert | Session 005 |

---

**Notes:**
- This SDD describes a markdown-first framework — the "tech stack" is file conventions, not runtime code. The technical complexity lives in the installer (bash), command design (markdown instructions), and future Python CLI.
- The framework is currently in bootstrap: building itself using itself. This means the SDD describes both what exists and what is planned — distinguish via the version markers in the PRD's release strategy.
- Session 005 decisions override session 009 where they conflict (see Resolved Questions above).
