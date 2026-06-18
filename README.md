# Maestro — AI-Assisted Project Delivery Framework

> Lightweight framework for planning, designing, building, and shipping projects with an AI delivery partner.

## What Is Maestro?

Maestro turns AI coding tools into structured delivery partners. Instead of ad-hoc conversations, you get a repeatable workflow with tracked decisions, versioned artifacts, and a clear audit trail.

It works for solo developers, small teams, and client engagements — adapting its depth to your project's complexity.

**Supported tools:** Claude Code, Cursor, GitHub Copilot (Codex).

## Quick Start

### Install

```bash
curl -fsSL https://raw.githubusercontent.com/pjasielski/maestro/main/install.sh | bash
```

The installer creates the folder structure, copies framework files, sets up tool adapters (Claude Code, Cursor, Codex), and creates tracking files. It never overwrites existing files.

→ **[Full installation guide](docs/installation.md)** — browser wizard, manual install, Cursor setup, team setup, troubleshooting

### First Session

```
/mae-explore                  # Start exploring your project
/mae-explore doc              # Generate final explore report
/mae-req                      # Formalize requirements
/mae-design                   # Create technical architecture
/mae-plan                     # Create roadmap and tasks
/mae-do                       # Execute tasks
/mae-review                   # Review code and artifacts
```

## Commands

### Delivery Commands

| Command | Alias | What It Does |
|---------|-------|-------------|
| `/mae-init` | — | Set up user/team profile after installation |
| `/mae-explore` | `mex` | Build understanding — analyze docs, topics, transcripts |
| `/mae-explore ask` | — | Generate questions for user, client, team |
| `/mae-explore doc` | — | Synthesize final explore report |
| `/mae-req` | `mrq` | Generate requirements document from explore artifacts |
| `/mae-design` | `mds` | Create technical design document from requirements |
| `/mae-plan` | `mpl` | Create roadmap, enrich milestones, generate tasks |
| `/mae-do` | `mdo` | Execute a task (planned or ad-hoc) |
| `/mae-review` | `mrv` | Review code or delivery artifacts |

### Utility Commands

| Command | What It Does |
|---------|-------------|
| `/status` | Project overview (phase, tasks, decisions, questions) |
| `/decide` | Record a decision in the audit trail |
| `/sync` | End-of-session save — update HANDOFF, ROADMAP, DECISIONS |
| `/md` | Save current response to a session file |

### Aliases

Every delivery command has a 3-letter shortcut for faster typing:

```
/mex  = /mae-explore     /mrq = /mae-req       /mds = /mae-design
/mpl  = /mae-plan        /mdo = /mae-do        /mrv = /mae-review
```

## How It Works

### Sessions-First Workflow

Commands save artifacts to `.sessions/` (your workbench). You review, then **promote** to `delivery/` when ready.

```
/mae-explore  → session artifacts  ──promote──→  delivery/01-explore/
/mae-req      → requirements draft ──promote──→  delivery/02-requirements/REQUIREMENTS.md
/mae-design   → design draft       ──promote──→  delivery/03-design/DESIGN.md
/mae-plan     → roadmap + tasks    ──────────→  delivery/04-plan/
```

This keeps delivery/ clean — only confirmed, reviewed artifacts live there.

### Decision Pipeline

```
OPEN_QUESTIONS.md  →  DECISIONS.md  →  Canonical files
"should we?"          "we decided"     (via /sync)
```

Nothing gets lost. Every idea has a path to becoming a decision.

### Adaptive Workflow

Not every project needs every command. Maestro suggests what to skip:

```
Simple project:   explore → do
Medium project:   explore → design → plan → do
Complex project:  explore → req → design → plan → do → review
```

Each command has a `## Skip When` section. The agent suggests but never blocks.

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
│   ├── 02-requirements/      ← REQUIREMENTS.md
│   ├── 03-design/            ← DESIGN.md
│   └── 04-plan/              ← ROADMAP.md + tasks/
├── .sessions/                ← Working material (per-session)
├── templates/                ← Document templates (customizable)
├── .maestro/commands/        ← Canonical command files
├── .claude/commands/         ← Claude Code adapters + aliases
└── .cursor/rules/            ← Cursor adapters
```

## Templates

| Template | Purpose | Output File |
|----------|---------|-------------|
| `requirements.md` | Requirements document | `REQUIREMENTS.md` |
| `design.md` | Technical design | `DESIGN.md` |
| `roadmap.md` | Project roadmap with milestones | `ROADMAP.md` |
| `explore.md` | Explore report | Session artifact |
| `task.md` | Task file | `task-NNN.md` |
| `summary.md` | Session summary | `_summary.md` |
| `review.md` | Review report | Session artifact |

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

The agent adapts: deeper assistance in unfamiliar areas, lighter in strengths.

## Multi-Tool Support

Maestro works across AI coding tools. Canonical command files live in `.maestro/commands/`. Each tool gets thin adapters:

| Tool | Adapter Location | How Commands Work |
|------|-----------------|-------------------|
| **Claude Code** | `.claude/commands/` | `/mae-explore` or `/mex` — autocomplete works |
| **Cursor** | `.cursor/rules/` | Type `mae-explore` or `mex` in chat — dispatch rule loads the command |
| **Codex** | `.github/copilot-instructions.md` | Type command name in chat |

## Requirements

- An AI coding tool: [Claude Code](https://claude.com/claude-code), [Cursor](https://cursor.sh), or GitHub Copilot
- A project directory

## License

MIT
