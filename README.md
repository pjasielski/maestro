<div align="center">

<img alt="Maestro" src="assets/maestro-logo.svg" width="300">

### Spec-driven delivery for AI coding tools.

Your AI tool forgets everything between chats. Maestro keeps requirements, design, decisions, and tasks in your repo as files — so every session picks up where the last one ended.

[![License: MIT](https://img.shields.io/badge/license-MIT-8B5CF6)](LICENSE)
[![Version](https://img.shields.io/badge/version-0.4.0-F59E0B)](CHANGELOG.md)
[![Tools](https://img.shields.io/badge/Claude%20Code%20·%20Cursor%20·%20Copilot-supported-64748B)](#multi-tool-support)

[Install](#install) · [Commands](#commands) · [PoC track](#the-poc-track) · [How it works](#how-it-works) · [Docs](docs/user-guide.md)

</div>

---

## The problem

AI coding tools have no memory of your project between chats. Every session starts the same way: re-explaining the architecture, re-litigating decisions you already made, watching the model rebuild context you paid for yesterday. Decisions live in scrollback. Nothing is auditable.

**Maestro fixes this with files, not magic.** Twelve commands write structured artifacts to disk — requirements, design, roadmap, tasks, decisions — and a handoff file the agent reads at the start of every session. Your AI tool picks up where it left off because the context is on disk, not in a context window.

```bash
curl -fsSL https://raw.githubusercontent.com/pjasielski/maestro/main/install.sh | bash
```

> [!TIP]
> Maestro is prompts and markdown. No daemon, no API key, no vendor lock-in — delete `MAESTRO.md` and `.maestro/` and your project is exactly as it was.

## What a session looks like

```
/mae-explore          Build understanding — analyze docs, code, transcripts
/mae-req              Formalize what you're building
/mae-design           Technical architecture, with trade-offs written down
/mae-plan             Roadmap and task files
/mae-do M02.03        Execute a task
/sync                 End of session — update HANDOFF, ROADMAP, DECISIONS
```

Next week, in a brand-new chat, the agent reads `HANDOFF.md` first and greets you with where you left off. That's the whole idea.

> [!NOTE]
> **Not every project needs every command.** Each command has a `## Skip When` section. A weekend project might be `explore → do`. A client engagement runs the full pipeline. The agent suggests; it never blocks.
> ```
> Simple:   explore → do
> PoC:      explore → poc → do
> Medium:   explore → design → plan → do
> Complex:  explore → req → design → plan → do → review
> ```

## The PoC track

Sometimes the full pipeline costs more than it returns. A prototype, a spike, a time-boxed build where you need to be writing code in twenty minutes, not reviewing three documents.

`/mae-poc` collapses requirements, design, and roadmap into **one file** — `docs/02-specs/POC.md` — and `/mae-do poc` executes straight from it.

```
/mae-explore          Understand the problem (or skip, if a brief already exists)
/mae-poc              One spec: scope, requirements, design, roadmap, risks
/mae-do poc           Execute the whole milestone
```

Why one file rather than three: the agent reads **once**. Three artifacts means three reads and three chances to miss one. The PoC spec is capped at 4,000 words on purpose — past that it isn't a PoC, and the command says so and offers to split into the full track.

It asks only blocking questions — stack, data source, deployment target — and records every other judgement call under **§ Risks & Assumptions** instead of stopping to ask. Speed is the point.

**When the prototype survives**, nothing is thrown away. The PoC is milestone `M01`, using the same task IDs as everything else, so `/mae-plan` simply continues at `M02` and the PoC's history stays intact as the project's first milestone.

> [!TIP]
> **`docs/00-reference/` — the material you didn't write.**
> Drop client briefs, specs, and transcripts here before you start. Maestro treats this folder as read-only and **authoritative on intent** — it outranks anything the agent infers from reading your code. When someone hands you a brief and a deadline, this is where the project begins.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/pjasielski/maestro/main/install.sh | bash
```

The installer asks three questions (session visibility, which AI tools, how to ask you questions), scaffolds `docs/`, and writes adapters for the tools you picked. **It never overwrites your files** — `HANDOFF.md`, `DECISIONS.md`, `CLAUDE.md`, and `maestro.toml` are preserved on reinstall.

Upgrading from an earlier version, or want the framework files refreshed:

```bash
curl -fsSL .../install.sh -o install.sh && bash install.sh . --force
```

→ **[Full installation guide](docs/installation.md)** — browser wizard, manual install, Cursor setup, teams, troubleshooting

## Commands

Eight delivery commands, four utilities. Every delivery command has a short alias.

| Command | Alias | What it does | Writes to |
|---------|-------|--------------|-----------|
| `/mae-explore` | `mex` | Build understanding; surface questions and gaps | `docs/01-explore/` |
| `/mae-poc` | `mpoc` | One-file spec for prototypes and time-boxed builds | `docs/02-specs/POC.md` |
| `/mae-req` | `mrq` | Formalize requirements | `docs/02-specs/REQUIREMENTS.md` |
| `/mae-design` | `mds` | Technical architecture with trade-offs | `docs/02-specs/ARCHITECTURE.md` |
| `/mae-plan` | `mpl` | Roadmap and task files | `docs/03-plan/` |
| `/mae-do` | `mdo` | Execute a task, planned or ad-hoc | code + `docs/04-implementation/` |
| `/mae-review` | `mrv` | Review code or delivery artifacts | `docs/05-review/` |
| `/mae-init` | — | One-time profile setup | `maestro.toml` |

| Utility | What it does |
|---------|--------------|
| `/status` | Project overview — phase, tasks, decisions, open questions |
| `/decide` | Record a decision in the audit trail |
| `/sync` | End-of-session save — HANDOFF, ROADMAP, DECISIONS |
| `/md` | Save the previous response to a session file, verbatim |

<details>
<summary><b>Sub-commands and variants</b></summary>

| Command | What it does |
|---------|--------------|
| `/mae-explore` | Analyze docs, topics, transcripts |
| `/mae-explore ask` | Generate questions for you, the client, or the team |
| `/mae-explore doc` | Synthesize the final explore report |
| `/mae-explore-lite` | Fast pass for small or well-understood projects |
| `/mae-poc --tasks` | Also emit individual task files, not just the roadmap table |
| `/mae-do poc` | Execute the whole PoC milestone from `POC.md` |
| `/mae-do M02.03` | Execute one planned task |
| `/mae-do path/to/task.md` | Execute a task from a specific file |

</details>

## How it works

### Sessions are a workbench; `docs/` is the record

Commands write drafts to `.sessions/`. You review. Confirmed work gets **promoted** to `docs/`.

```
/mae-explore  → session artifacts  ──promote──→  docs/01-explore/
/mae-req      → requirements draft ──promote──→  docs/02-specs/REQUIREMENTS.md
/mae-design   → design draft       ──promote──→  docs/02-specs/ARCHITECTURE.md
/mae-plan     → roadmap + tasks    ──────────→  docs/03-plan/
/mae-poc      → POC spec           ──────────→  docs/02-specs/POC.md
```

Only reviewed artifacts reach `docs/`, so `docs/` stays trustworthy — which is what makes it safe for the agent to treat as canonical. (`/mae-plan` and `/mae-poc` write straight through: their output is immediately actionable, so a review round-trip would only cost you time.)

### Nothing falls through the cracks

```
OPEN_QUESTIONS.md  →  DECISIONS.md  →  Canonical files
"should we?"          "we decided"     (via /sync)
```

### Creating is free; editing is reviewed

The agent writes new files and session material without asking. Editing `docs/`, `HANDOFF.md`, source code, or `maestro.toml` requires showing you the change first. That single rule is what keeps an eager model from quietly rewriting your architecture.

<details>
<summary><b>What the installer puts in your project</b></summary>

```
your-project/
├── MAESTRO.md                ← Framework instructions (don't edit)
├── CLAUDE.md                 ← Your project config (edit this)
├── maestro.toml              ← Settings: visibility, profile, tools
├── HANDOFF.md                ← Single source of truth for status
├── DECISIONS.md              ← Decision audit trail
├── OPEN_QUESTIONS.md         ← Questions needing answers
├── WORKLOG.md                ← Activity log
├── docs/
│   ├── 00-reference/         ← Material you didn't write (read-only)
│   ├── 01-explore/           ← EXPLORE.md (synthesis), IDEAS.md, explore artifacts
│   ├── 02-specs/             ← REQUIREMENTS.md, ARCHITECTURE.md, ARCHITECTURE.md, mock/ — or POC.md (PoC track)
│   ├── 03-plan/              ← ROADMAP.md + tasks/
│   ├── 04-implementation/    ← Reports from /mae-do
│   ├── 05-review/            ← Review reports        (on demand)
│   ├── 06-test/              ← Test plans            (on demand)
│   ├── 07-deploy/            ← Deployment config     (on demand)
│   └── 08-maintenance/       ← Bugs, tech debt       (on demand)
├── .sessions/                ← Working material, per session
├── .maestro/templates/       ← Document templates (customizable)
├── .maestro/commands/        ← Canonical command definitions
└── .claude/commands/         ← Tool adapters + aliases
```

A phase command is named after its folder: `/mae-explore` → `01-explore/`, `/mae-specs` → `02-specs/`, `/mae-plan` → `03-plan/`.

</details>

## Configuration

Everything lives in `maestro.toml`.

```toml
[project]
name = "my-project"
session_visibility = "committed"   # or "gitignored"
question_style = "async"           # or "sync"
ai_tools = ["claude", "cursor"]
```

| Setting | Options | Effect |
|---------|---------|--------|
| `session_visibility` | `committed` / `gitignored` | Whether `.sessions/` is in git. Committed suits solo projects; gitignored suits teams where sessions are personal |
| `question_style` | `async` / `sync` | `async` writes questions to a file you answer in your own time; `sync` asks in chat |
| `ai_tools` | `claude`, `cursor`, `copilot`, `codex` | Which adapters get generated |

<details>
<summary><b>Optional: user and team profiles</b></summary>

Tell Maestro what you're good at and it calibrates — deeper explanation where you need it, leaner where you don't.

```toml
[user]
description = "Senior Python architect, new to frontend"
strengths = ["backend", "python"]
needs_help = ["frontend", "ux"]
```

Defining `[[team.members]]` activates team behaviour: the agent asks who it's working with and adapts per person.

```toml
[[team.members]]
name = "Piotr"
role = "architect"
strengths = ["backend", "python"]
needs_help = ["frontend"]
```

</details>

## Templates

Every artifact is generated from a markdown template in `.maestro/templates/`. Edit them to match your standards — the framework uses whatever is there.

| Template | Produces |
|----------|----------|
| `requirements.md` | `REQUIREMENTS.md` |
| `design.md` | `DESIGN.md` (visual system) |
| `architecture.md` | `ARCHITECTURE.md` |
| `poc.md` | `POC.md` |
| `roadmap.md` | `ROADMAP.md` |
| `task.md` | `tasks/M{MM}.{NN}-{slug}.md` |
| `explore.md` · `review.md` · `report.md` | Session artifacts |
| `summary.md` | `_summary.md` |
| `issue.md` | `docs/08-maintenance/issues/` |

## Multi-tool support

Command definitions live once in `.maestro/commands/`. Each tool gets a thin adapter pointing at them — so a command behaves identically everywhere, and adding a tool never means rewriting prompts.

| Tool | Adapter | Usage |
|------|---------|-------|
| **Claude Code** | `.claude/commands/` | `/mae-explore` or `/mex` — autocomplete works |
| **Cursor** | `.cursor/rules/` + `.cursor/commands/` | Type `mae-explore` or `mex` in chat |
| **Copilot / Codex** | `.github/copilot-instructions.md` | Type the command name in chat |

## FAQ

<details>
<summary><b>So it's just prompts?</b></summary>

Yes. That's the point — nothing to run, nothing to host, nothing to migrate off. The value isn't in a runtime; it's in the artifacts landing in your repo in a shape the next session can read.

</details>

<details>
<summary><b>Why not just write good prompts?</b></summary>

You can, and for a one-off script you should. Maestro earns its keep when a project outlives a single context window — when you need to know *why* a decision was made three weeks ago, or hand the project to someone else, or resume after a month away. It's the difference between a conversation and a record.

</details>

<details>
<summary><b>This looks heavy for a prototype.</b></summary>

Then use the [PoC track](#the-poc-track): `explore → poc → do`, one spec file, no promotion round-trips. The full pipeline is there when a project earns it, not before.

</details>

<details>
<summary><b>Does this lock me in?</b></summary>

No. Maestro is markdown files in your repo. There's no runtime, no service, no account. If you stop using it, you're left with well-organized project documentation — which was worth having anyway.

</details>

<details>
<summary><b>Do I have to use all the docs folders?</b></summary>

No. `04` through `08` are created on demand — when you file your first bug, or the first time deployment gets non-trivial. A small project may never leave `01`–`03`, and a PoC may only ever touch `00`, `02-specs` (POC.md), and `04`.

</details>

<details>
<summary><b>Can I use it on an existing project?</b></summary>

Yes — that's what `/mae-explore` is for. Point it at a codebase and it builds the understanding artifacts from what's already there, rather than assuming a greenfield start.

</details>

## Requirements

- An AI coding tool: [Claude Code](https://claude.com/claude-code), [Cursor](https://cursor.sh), or GitHub Copilot
- A project directory

## Documentation

| Guide | Contents |
|-------|----------|
| [Installation](docs/installation.md) | Wizard, manual install, per-tool setup, troubleshooting |
| [User guide](docs/user-guide.md) | Working through a project phase by phase |
| [Reference](docs/reference.md) | Every command, flag, and config key |
| [Changelog](CHANGELOG.md) | Version history |

## License

MIT
