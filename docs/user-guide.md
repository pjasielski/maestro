# Maestro User Guide

## Getting Started

### Installation

```bash
curl -fsSL https://raw.githubusercontent.com/pjasielski/maestro/main/install.sh | bash
```

→ **[Full installation guide](installation.md)** — browser wizard, Cursor/Codex setup, team setup, troubleshooting

### First Steps

1. **Edit `CLAUDE.md`** — Add your project name, tech stack, and any project-specific notes
2. **Start a conversation** with Claude Code in your project directory
3. Claude reads `CLAUDE.md` → `MAESTRO.md` and understands the framework
4. Run `/mae-explore` to begin

### Understanding the Structure

After installation, you have three "zones":

| Zone | Location | Purpose | Editable? |
|------|----------|---------|-----------|
| **Framework** | `MAESTRO.md`, `.claude/commands/`, `templates/` | Framework behavior and commands | Don't edit MAESTRO.md; customize templates |
| **Delivery** | `delivery/` | Confirmed, canonical artifacts | Only via promotion from sessions |
| **Working** | `sessions/`, `notes/` | Drafts, analysis, working material | Freely editable |

---

## The Delivery Workflow

**Maestro does not force a rigid sequence.** You can revisit any phase, skip phases, or run them in any order. Common patterns:

- **Standard:** explore → prd → design → plan → do → review (full process)
- **PoC-first:** explore (light) → do (PoC) → feedback → explore (refined) → prd → design → do
- **Fast-track:** explore → design → do → review (skip formal PRD)
- **Iterative:** explore → prd → do (MVP) → feedback → explore again → do

Choose what fits your project. The phases below describe each tool, not a mandatory order.

### Phase 1: Explore

**Goal:** Understand the project — business context, technical landscape, risks.

```
/mae-explore                    # Auto-explore what's available
/mae-explore "payment system"   # Deep-dive into a specific area
/mae-explore /path/to/notes.md  # Analyze a document or transcript
/mae-explore ask                # Generate questions to deepen understanding
/mae-explore ask client          # Questions packaged for client meetings
/mae-explore doc                # Synthesize final explore report
```

**First explore:** The agent scans for existing resources (README, docs/, data/, source code) and reports what it finds. It asks which resources to include before reading them. The first artifact always includes a questions section to drive deeper understanding.

**Simple project:** Run `/mae-explore` once or twice, then `/mae-explore doc`. Done.

**Complex project:** Run multiple explorations over several sessions — different topics, transcripts, stakeholder notes. Use `/mae-explore ask` to generate structured question documents that can be answered asynchronously (by you or a client). The agent tracks readiness and suggests when you're ready for the final report.

**Readiness tracking:** After each explore, the agent updates a readiness indicator in `_summary.md` showing what's covered, what's missing, and whether you're ready for doc synthesis.

**Promotion:** After `explore doc`, the agent asks if you want to promote to `delivery/01-explore/`. Say yes when you're satisfied.

### Phase 2: PRD (Requirements)

**Goal:** Formalize what you're building.

```
/mae-prd
```

Reads your explore artifacts and generates a Product Requirements Document using `templates/prd.md`. The PRD is saved as a draft in your session — review it, request changes, then promote to `delivery/02-prd/PRD.md`.

**Template sections:** 7 core (always included) + 3 optional (constraints, release strategy, glossary — include when relevant).

### Phase 3: Design

**Goal:** Define the technical architecture.

```
/mae-design                      # Full solution design (reads PRD + explore report)
/mae-design auth-service          # Detail a specific component
/mae-design src/api/routes.py     # File-level spec
```

Works top-down: full architecture first, then drill into components and files. The agent reads both the PRD and the explore report's technical sections for context. Before generating the SDD, it presents a technical questionnaire for decisions it can't make from available information (tech stack, architecture patterns, deployment model). The SDD is drafted in your session, then promoted to `delivery/03-design/SDD.md`.

If the design process reveals missing information, the agent suggests running additional explore commands to fill the gap.

### Phase 4: Plan

**Goal:** Break the design into tasks.

```
/mae-plan
```

Reads the SDD and creates task files in `delivery/04-plan/tasks/`. Each task is a markdown file — your Jira replacement. Tasks go directly to delivery/ because they're meant to be immediately actionable.

### Execution: Do & Review

```
/mae-do                    # Smart suggestion: what to work on next
/mae-do task-003           # Execute a specific planned task
/mae-do "add error handling to API"  # Ad-hoc task

/mae-review                # Review uncommitted changes
/mae-review src/api/       # Review a specific directory
/mae-review sdd            # Review the SDD against the PRD
```

---

## Sessions

### What Is a Session?

A session is a working folder in `sessions/` (e.g., `sessions/002-api-design/`). It holds all artifacts from a stretch of related work: analysis files, drafts, reports, checkpoints.

Sessions are your **workbench** — messy, iterative, exploratory. Delivery is your **showcase** — clean, confirmed, canonical.

### Starting a Session

When you start a new Claude Code conversation, the agent:
1. Reads `HANDOFF.md` and `MAESTRO.md`
2. Checks for the latest session
3. Greets you with a summary
4. Asks what you'd like to work on

If you start working without naming a session, the agent will ask: "Should I open a session for this?"

### Session Files

- `_summary.md` — Living summary of what happened (auto-updated)
- `NN_description.md` — Numbered working artifacts (analysis, drafts, reports)
- `checkpoints/` — Project state snapshots (via `/mae-checkpoint`)

---

## Decision Management

### The Pipeline

```
notes/ideas.md    →    OPEN_QUESTIONS.md    →    DECISIONS.md    →    Canonical files
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

### Checkpoints

Save named snapshots for progress tracking:

```
/mae-checkpoint pre-design       # Before starting design
/mae-checkpoint sprint-1-end     # End of sprint
/mae-checkpoint list             # See all checkpoints
/mae-checkpoint compare pre-design sprint-1-end  # See what changed
```

---

## Solo vs Team Mode

### Solo Mode (default)

- Sessions and notes are committed to git
- WORKLOG has no "Who" column
- Good for personal projects and solo development

### Team Mode

- Sessions and notes are gitignored (each person's working material stays local)
- WORKLOG includes a "Who" column
- Delivery artifacts are shared via git
- Use `/sync` regularly to keep canonical files current

Switch mode in `maestro.toml`:
```toml
[project]
mode = "team"
```

---

## Customization

### Editing Templates

Templates in `templates/` are starting points. Edit them to match your domain:
- Add industry-specific sections to `prd.md` (e.g., regulatory requirements)
- Add compliance sections to `sdd.md`
- Change the explore report structure in `explore.md`

### Adding Custom Commands

Create a `.md` file in `.claude/commands/`:

```markdown
# /mae-estimate — Effort Estimation

Generate effort estimates for planned tasks.

## Behavior

1. Read task files in delivery/04-plan/tasks/
2. For each task, estimate: time, complexity, risk
3. Generate summary table
4. Save report to session folder
```

Name it `mae-estimate.md` and it becomes `/mae-estimate`.

### Extending Delivery Structure

Add folders for project-specific needs:

```
delivery/05-review/      # Formal review cycles
delivery/06-test/        # Test plans and strategies
delivery/07-deploy/      # Deployment configuration
delivery/08-compliance/  # Regulated domain requirements
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
