# Maestro User Guide

## Getting Started

### Installation

```bash
curl -fsSL https://raw.githubusercontent.com/pjasielski/maestro/main/install.sh | bash
```

→ **[Full installation guide](installation.md)** — upgrades, branches and tags, Cursor/Codex setup, team setup, troubleshooting

### First Steps

1. **Put source material** (client briefs, specs, transcripts, brand assets) in `docs/00-reference/`
2. **Start a conversation** in your project directory. Your tool's adapter points the agent to `MAESTRO.md`, which reads `HANDOFF.md`: `CLAUDE.md` (Claude Code), `.cursor/rules/` (Cursor), `AGENTS.md` (Codex), `.github/copilot-instructions.md` (Copilot)
3. Run `/mae-help` (Codex and Copilot: type `mae-help`) — it names the command to run now (on a new project, `/mae-explore`)
4. Optional: add your project name and stack to `CLAUDE.md`, or to `AGENTS.md` outside the Maestro block

### Understanding the Structure

| Zone | Location | Purpose | Editable? |
|------|----------|---------|-----------|
| **Framework** | `MAESTRO.md`, `.maestro/skills/`, `.maestro/commands/`, `.maestro/templates/` | Framework behaviour | Don't edit MAESTRO.md; customise templates |
| **Delivery** | `docs/` | Confirmed, canonical artifacts | Through promotion from sessions, with review |
| **Working** | `.sessions/` | Drafts, analysis, working material | Freely |

A phase command is named after its folder: `/mae-explore` → `docs/01-explore/`, `/mae-specs` → `docs/02-specs/`, `/mae-plan` → `docs/03-plan/`.

---

## The Delivery Workflow

**Maestro does not force a rigid sequence.** Revisit, skip, or reorder phases. Four common paths (the README draws them):

- **Quick:** explore → do
- **Client-first:** explore → mock → client feedback → poc or specs → plan → do
- **PoC:** explore → poc → do poc → plan (M02 onward) if it works
- **Full:** explore → specs → plan → do → review, with changes through scope

`/mae-help` answers "what now?" from what exists on disk. The phases below describe each tool, not a mandatory order.

### Phase 1: Explore

**Goal:** understand the project — business context, technical landscape, risks.

```
/mae-explore                    # Auto-explore what's available
/mae-explore "payment system"   # Deep-dive into a specific area
/mae-explore /path/to/notes.md  # Analyze a document or transcript
/mae-explore ask client         # Questions for a client meeting
/mae-explore doc                # Synthesize docs/01-explore/EXPLORE.md
/mae-explore I-07               # Explore a parked idea
```

**First explore:** the agent reads `docs/00-reference/` first (authoritative on intent), lists other resources, and asks before reading large ones. Every artifact includes questions.

**Questions** are grouped Business / Technical. Technical ones the agent can answer are pre-filled for you to confirm (`Pre-answered:`, or `Pre-answered (assumed):` for judgement calls); business ones are never pre-filled (`OPEN — ask the client`). Multiple-choice questions label a working default; tick an option to answer. The file header counts what is pre-answered and what is open.

**Synthesis:** `/mae-explore doc` writes `EXPLORE.md`, the one explore file every later command reads. Promote it when you're satisfied.

**Ideas:** `/mae-idea "offline mode"` parks a maybe-later in `docs/01-explore/IDEAS.md` without interrupting you.

### Phase 2: Specs

**Goal:** agree what to build, how it looks, and how it's built.

```
/mae-specs                       # Build whatever is missing, one question round, one review
/mae-specs requirements          # = /mae-requirements (mrq) → REQUIREMENTS.md, what and why
/mae-specs design                # = /mae-design (mds) → DESIGN.md, the visual system (UI projects)
/mae-specs architecture          # = /mae-architecture (mar) → ARCHITECTURE.md, how it's built
/mae-architecture auth-service   # One component → architecture/auth-service.md
/mae-mock                        # Clickable HTML screens in docs/02-specs/mock/
```

Bare `/mae-specs` builds only the missing parts: requirements, then design if there's a UI, then architecture. When everything exists it points you to `/mae-scope` for changes. One part is drafted in your session and promoted to `docs/02-specs/` after review. Several parts are written straight to `docs/02-specs/`, so each builds on the last, and one review at the end keeps or undoes them.

`/mae-mock` confirms the screen list in chat, then writes self-contained HTML you can send to a client. Gaps it exposes are listed as `GAP:` lines in `_screens.md`, which `/mae-requirements` and `/mae-poc` pick up. Once the client approves the mock, `/mae-design` extracts `DESIGN.md` from it.

**Large specs** split by the main-file rule: `ARCHITECTURE.md` stays the entry point and links `architecture/{component}.md`; commands open a sub-file only when a task touches it.

### PoC track

```
/mae-poc          # One file: requirements + architecture + roadmap → docs/02-specs/POC.md
/mae-do poc       # Execute the whole milestone
/mae-plan         # If it works: plan M02 onward from POC.md
```

### Phase 3: Plan

**Goal:** break the specs into tasks.

```
/mae-plan
```

Reads ARCHITECTURE.md (or REQUIREMENTS.md alone, or POC.md) and writes `docs/03-plan/ROADMAP.md` and task files in `docs/03-plan/tasks/`, directly, because they're immediately actionable.

### Execution: Do, Review, PR

```
/mae-do                    # Smart suggestion: what to work on next
/mae-do M02.03             # Execute a planned task
/mae-do M02                # Execute a whole milestone, stop on first failure
/mae-do "add error handling to API"  # Ad-hoc task

/mae-review                # Review uncommitted changes
/mae-review architecture   # Review ARCHITECTURE.md against REQUIREMENTS.md
/mae-pr                    # Push the branch and open a draft PR
```

By default `/mae-do` commits after each task (`feat(M02.03): …` with a `Task:` trailer), never pushes, asks once per milestone about a branch, and writes a PR description to the session when a milestone completes. `/mae-pr` is the explicit push. All of it is set in `maestro.toml` `[git]`.

### Changing scope

```
/mae-scope "client wants multi-currency"   # Impact analysis first, applied on confirmation
/mae-scope --direct "…"                    # Additive changes applied straight away; conflicts still stop
```

---

## Sessions

### What Is a Session?

A session is a working folder in `.sessions/` (e.g., `.sessions/002-api-design/`). It holds all artifacts from a stretch of related work: analysis files, drafts, reports.

Sessions are your **workbench** — messy, iterative, exploratory. Delivery is your **showcase** — clean, confirmed, canonical.

### Starting a Session

When you start a new conversation, the agent:
1. Reads `HANDOFF.md` and `MAESTRO.md`
2. Checks for the latest session
3. Greets you with a summary
4. Asks what you'd like to work on

If you start working without naming a session, the agent will ask: "Should I open a session for this?"

### Session Files

- `_summary.md` — Living summary of what happened (auto-updated)
- `NN_description.md` — Numbered working artifacts (analysis, drafts, reports)

---

## Decision Management

### The Pipeline

```
IDEAS.md / chat    →    OPEN_QUESTIONS.md    →    DECISIONS.md    →    Canonical files
"what if?"              "should we?"              "we decided"         (via /sync)
```

### Commands

- **`/decide "use PostgreSQL for the database"`** — Records the decision in `DECISIONS.md`
- **`/sync`** — Pushes confirmed decisions to `HANDOFF.md` and delivery artifacts
- **`/mae-explore ask`** — Generates structured questions during exploration (replaces `/probe` and `/question`)

### Decision Markers

Used in `_summary.md` to track lifecycle:

| Marker | Meaning |
|--------|---------|
| `✓` | Confirmed — locked in |
| `~` | Proposed — direction agreed, details TBD |
| `?` | Tentative — floated but not discussed |
| `⏸` | Parked — deliberately deferred |

---

## Status & Tracking

```
/status              # Overview: phase, task counts, blockers, recent activity
/status tasks        # Full task board grouped by status
/status decisions    # Decision summary with unsynced items
/status questions    # Open questions by priority
```

---

## Solo and Team Projects

Two independent settings in `maestro.toml`:

- **`session_visibility`** — `"committed"` (default; sessions in git, full audit trail) or `"gitignored"` (each person's working material stays local; `docs/` is still shared)
- **`[[team.members]]`** — define team members and team behaviour switches on: the agent asks who it's working with, WORKLOG gets a "Who" column, and `/sync` is how decisions reach everyone

```toml
[project]
session_visibility = "gitignored"

[[team.members]]
name = "Ana"
role = "backend"
```

---

## Customization

### Editing Templates

Templates in `.maestro/templates/` are starting points. Edit them to match your domain:
- Add industry-specific sections to `requirements.md` (e.g., regulatory requirements)
- Add compliance sections to `architecture.md`
- Change the explore report structure in `explore.md`

### Adding Custom Commands

Create a `.md` file in `.maestro/commands/` and a one-line wrapper pointing to it in `.claude/commands/` (Claude Code) or `.cursor/commands/` (Cursor), like the installed ones:

```markdown
# /mae-estimate — Effort Estimation

Generate effort estimates for planned tasks.

## Behavior

1. Read task files in docs/03-plan/tasks/
2. For each task, estimate: time, complexity, risk
3. Generate summary table
4. Save report to session folder
```

Name it `mae-estimate.md` and it becomes `/mae-estimate`. Codex and Copilot won't see it unless you add a row to the command table outside the Maestro block in `AGENTS.md` / `.github/copilot-instructions.md`.

### Extending Delivery Structure

Add folders for project-specific needs:

```
docs/04-implementation/ # Implementation reports from /mae-do
docs/05-review/      # Formal review cycles
docs/06-test/        # Test plans and strategies
docs/07-deploy/      # Deployment configuration
docs/08-maintenance/ # Bugs, tech debt, maintenance
```

---

## Tips

1. **Let explore be messy.** Run it multiple times on different topics. The `doc` command synthesizes order from chaos.
2. **Promote early, iterate in delivery.** Don't wait for perfection in sessions — promote a solid draft and refine the canonical version.
3. **Use `/decide` liberally.** Every significant choice deserves a record. Your future self will thank you.
4. **Check `/status` regularly.** It shows unsynced decisions and open questions — things that might block you.
5. **Keep HANDOFF.md current.** Run `/sync` when you've made important decisions. This is what the next conversation (or team member) reads first.
6. **Don't skip explore.** Even for "simple" projects, a quick exploration surfaces assumptions and risks you didn't know you had.
7. **Set up a user profile.** Add `[user]` (solo) or `[[team.members]]` (team) to `maestro.toml` — it helps the agent adapt explanations and recommendations to your expertise.
