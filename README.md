# Maestro — AI-Assisted Project Delivery Framework

> Lightweight framework for planning, designing, building, and shipping projects with an AI delivery partner.

## What Is Maestro?

Maestro turns Claude into a structured delivery partner. Instead of ad-hoc AI conversations, you get a repeatable workflow with tracked decisions, versioned artifacts, and a clear audit trail.

It works for solo developers, small teams, and client engagements — adapting its depth to your project's complexity.

## Quick Start

### Install

Maestro is a set of files (markdown commands, templates, framework instructions) that live in your project. "Installing" means copying these files in.

```bash
# Option 1: Clone and run the installer
git clone https://github.com/pjasielski/maestro.git /tmp/maestro
/tmp/maestro/install.sh /path/to/your-project

# Option 2: One-line install into current directory
curl -fsSL https://raw.githubusercontent.com/pjasielski/maestro/main/install.sh | bash
```

The installer creates the folder structure, copies framework files, and creates tracking files. It never overwrites existing files.

**Future:** `pip install maestro-delivery` / `uv add maestro-delivery` (Python CLI — planned).

### First Session

```
/mae-explore                  # Start exploring your project
/mae-explore doc              # Generate final explore report
/mae-prd                      # Formalize requirements into PRD
/mae-design                   # Create technical architecture (SDD)
/mae-plan                     # Break design into tasks
/mae-do                       # Execute tasks
/mae-review                   # Review code and artifacts
```

## Commands

### Delivery Commands

| Command | What It Does |
|---------|-------------|
| `/mae-init` | Set up user/team profile after installation |
| `/mae-explore` | Build understanding — analyze docs, topics, transcripts |
| `/mae-explore ask` | Generate questions to deepen understanding (for user, client, team) |
| `/mae-explore doc` | Synthesize final explore report from all artifacts |
| `/mae-prd` | Generate Product Requirements Document from explore artifacts |
| `/mae-design` | Create Solution Design Document from PRD |
| `/mae-plan` | Break design into actionable tasks |
| `/mae-do` | Execute a task (planned or ad-hoc) |
| `/mae-review` | Review code or delivery artifacts |
| `/mae-checkpoint` | Save a named snapshot of project state |

### Utility Commands

| Command | What It Does |
|---------|-------------|
| `/status` | Project overview (phase, tasks, decisions, questions) |
| `/status tasks` | Full task board |
| `/status decisions` | Decision summary |
| `/status questions` | Open questions by priority |
| `/decide` | Record a decision in the audit trail |
| `/sync` | Push decisions to canonical files |
| `/md` | Save current response to a session file |

## How It Works

### Sessions-First Workflow

Commands save artifacts to `.sessions/` (your workbench). You review, then **promote** to `delivery/` when ready.

```
/mae-explore  → session artifacts  ──promote──→  delivery/01-explore/
/mae-prd      → PRD draft          ──promote──→  delivery/02-prd/PRD.md
/mae-design   → SDD draft          ──promote──→  delivery/03-design/SDD.md
/mae-plan     → task files          ──────────→  delivery/04-plan/tasks/
```

This keeps delivery/ clean — only confirmed, reviewed artifacts live there.

### Decision Pipeline

```
notes/ideas.md  →  OPEN_QUESTIONS.md  →  DECISIONS.md  →  Canonical files
"what if?"         "should we?"          "we decided"     (via /sync)
```

Nothing gets lost. Every idea has a path to becoming a decision.

## Project Structure

After installation, your project gets:

```
your-project/
├── MAESTRO.md                ← Framework instructions (don't edit)
├── CLAUDE.md                 ← Your project config (edit this)
├── maestro.toml              ← Framework settings (session visibility, profile)
├── HANDOFF.md                ← Single source of truth for project status
├── DECISIONS.md              ← Decision audit trail
├── OPEN_QUESTIONS.md         ← Questions needing answers
├── WORKLOG.md                ← Activity log
├── delivery/
│   ├── 01-explore/           ← Confirmed explore artifacts
│   ├── 02-prd/               ← PRD.md
│   ├── 03-design/            ← SDD.md
│   └── 04-plan/tasks/        ← Task files (the plan)
├── .sessions/                ← Working material (per-session)
├── notes/ideas.md            ← Raw ideas and parking lot
├── templates/                ← Document templates (customizable)
└── .claude/commands/         ← Framework commands
```

## Templates

Maestro includes templates for key deliverables. Each has **core sections** (always included) and **optional sections** (marked with comments — include when relevant):

| Template | Purpose | Core Sections | Optional Sections |
|----------|---------|---------------|-------------------|
| `prd.md` | Product Requirements | Problem, personas, goals, requirements, scope, stories, risks | Constraints, release strategy, glossary |
| `sdd.md` | Solution Design | Overview, architecture, tech stack, data model, source structure, questions | AI/ML, integrations, infra, security, performance |
| `explore.md` | Explore Report | Summary, business analysis, technical analysis, risks, questions, recommendations | Stakeholders, change readiness, data assessment, AI feasibility |
| `task.md` | Task File | Description, acceptance criteria, files, notes | — |
| `summary.md` | Session Summary | What was done, decisions, open items, next steps | — |
| `report.md` | Command Report | Summary, output, flags, considerations, next steps | — |

Edit templates in `templates/` to match your team's standards.

## Session Visibility

Set in `maestro.toml`:

```toml
[project]
name = "my-project"
session_visibility = "committed"  # or "gitignored"
```

| Setting | `.sessions/` | Use case |
|---------|-------------|----------|
| `"committed"` | In git | Solo projects, full audit trail |
| `"gitignored"` | Gitignored | Teams where sessions are personal |

Team features (e.g., "Who" column in WORKLOG.md) activate automatically when `[[team.members]]` is defined in `maestro.toml`.

## User / Team Profile

Optional. Add to `maestro.toml` to tailor Maestro's assistance:

```toml
# Solo
[user]
description = "Senior Python architect, new to frontend"
strengths = ["backend", "python"]
needs_help = ["frontend", "ux"]

# Team — define each member
[[team.members]]
name = "Piotr"
role = "architect"
strengths = ["backend", "python"]
needs_help = ["frontend"]
```

The agent adapts: deeper assistance in unfamiliar areas, lighter in strengths. Set up during `/mae-init` or add manually.

## Customization

### Adding Custom Commands

Create a `.md` file in `.claude/commands/`:
- `mae-{name}.md` for delivery commands
- `{name}.md` for utility commands

Follow existing command files for format: title, arguments, behavior, rules.

### Extending Delivery Structure

Add folders to `delivery/` for project-specific needs:
- `delivery/05-review/` — created on demand for formal reviews
- `delivery/06-test/` — test plans and strategies
- `delivery/07-deploy/` — deployment configuration
- `delivery/08-compliance/` — for regulated projects

## Documentation

| Document | Purpose |
|----------|---------|
| `README.md` | Quick start and overview (this file) |
| `docs/user-guide.md` | How-to guide for the delivery workflow |
| `docs/reference.md` | Complete reference — every concept, command, and decision explained |

## Requirements

- [Claude Code](https://claude.com/claude-code) CLI
- A project directory

## License

MIT
