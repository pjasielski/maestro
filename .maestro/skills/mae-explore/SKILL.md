---
name: mae-explore
description: >-
  Build shared understanding of a project before anything is specified or built:
  scope overview, gaps, risks, and questions for the user, client, or team. Use when the
  user wants to explore, scope, or make sense of an idea, brief, transcript, meeting
  notes, or an unfamiliar codebase; asks "what are we missing" or "what should we ask
  the client"; or is starting a new project or engagement, even if they never say
  "explore". Also handles /mae-explore, mex, "explore ask", "explore doc", and idea IDs (I-NN).
  Do NOT use to write specs (mae-specs), park an idea for later (mae-idea), plan tasks
  (mae-plan), implement or fix code (mae-do), review existing work (mae-review), or
  answer a quick factual question about the code. Answer those directly.
license: MIT
compatibility: >-
  Requires a project initialized with Maestro (.maestro/, HANDOFF.md, .sessions/).
  Any Agent Skills client (Claude Code, Cursor, Codex CLI).
metadata:
  maestro-tier: auto
  maestro-command: /mae-explore
  maestro-aliases: mex
  maestro-version: "0.5.0"
---

# mae-explore — Build Understanding

Build mutual understanding of the project — business and technical. Adapts to what exists and what's needed. Every explore output includes questions to deepen understanding.

$ARGUMENTS — optional: topic, file path, idea ID (`I-NN`), "ask", or "doc"

## Fit check (auto-invocation only)

When you chose this skill yourself, compare the request with the state table in `.maestro/commands/mae-help.md`. If the project is past explore (REQUIREMENTS.md, POC.md or an in-progress task exists), say in one line what you are about to explore and why, then continue. A one-step factual question gets a direct answer, not this protocol.

## Usage

```
/mae-explore                  → smart default: produce whatever is most useful now
/mae-explore {topic}          → targeted analysis of a specific area
/mae-explore {file path}      → analyze/summarize a specific document or transcript
/mae-explore I-NN             → explore a parked idea from docs/01-explore/IDEAS.md
/mae-explore ask              → generate questions to deepen understanding
/mae-explore ask {audience}   → questions for: user, client, team, technical
/mae-explore doc              → synthesize docs/01-explore/EXPLORE.md from all artifacts
```

## Smart Default (no arguments)

### First Explore (nothing exists)

1. **Scan for existing project resources:**

   - **Read `docs/00-reference/` first** — source materials the user did not write (client briefs, specs, transcripts, exported tickets). This is the primary source of intent. Read these files in full unless they are very large, in which case report sizes and ask.
   - Always read: `README.md`, `maestro.toml`, `HANDOFF.md`
   - Scan `docs/` — list file names and sizes (do NOT read contents yet)
   - Scan `data/` — list file names only (flag if folder is large)
   - Scan source code — directory tree structure only (no file contents)
   - Report findings: "I see these existing resources: [list]. Which should I include in my analysis?"
   - Wait for user direction before reading large files or datasets

   **Reference material is authoritative.** Where `docs/00-reference/` conflicts with what the code implies, the reference wins and the difference is a finding worth reporting — code describes the current state, reference describes the intent.
2. **Produce initial scope artifact** containing:

   - Business + technical overview (from whatever is available)
   - Identified gaps and potential problems (`GAP:` / `UNCLEAR:` tags)
   - **Questions section** — questions the agent needs answered to proceed (see Questions Format below)

### Subsequent Explores

Detect what exists and assess readiness:

| Readiness signal                 | What it checks                                                              |
| -------------------------------- | --------------------------------------------------------------------------- |
| **Scope defined**          | Is there a business + technical overview?                                   |
| **Key questions resolved** | Ratio of resolved vs. open questions in `_summary.md` and prior artifacts |
| **Coverage breadth**       | Do artifacts cover business, technical, AND stakeholder angles?             |
| **Blocking gaps**          | Any `GAP:` or `UNCLEAR:` flags still unresolved?                        |
| **User intent**            | Has the user indicated readiness to move on?                                |

Based on readiness, produce the most useful next artifact:

- **Gap analysis** — what's missing based on existing artifacts
- **Deeper analysis** — drill into an area that needs more understanding
- **Risk identification** — flags and concerns from available material
- **Question list** — questions for specific audiences

When coverage is strong and gaps are few, suggest:

> "Coverage looks solid — [list what's covered]. Remaining gaps: [list]. Consider `/mae-explore doc` when ready, or continue exploring [specific areas]."

### Readiness Indicator

After each explore artifact, append a readiness assessment to `_summary.md`:

```markdown
## Explore Readiness
- Scope: ✓ defined / ✗ missing
- Business context: ✓ covered / ~ partial / ✗ missing
- Technical context: ✓ covered / ~ partial / ✗ missing
- Stakeholders: ✓ identified / ~ partial / ✗ missing
- Blocking questions: N remaining
- Recommendation: [continue exploring / ready for doc synthesis]
```

## Targeted Analysis (topic or file)

### Topic

`/mae-explore "auth system"` produces a focused deep-dive analysis on the specified area. Reads existing explore artifacts for context to avoid redundancy.

### File / Transcript

`/mae-explore /path/to/transcript.md` reads the file and produces a structured summary:

- Key points and takeaways
- Decisions mentioned
- Questions raised
- Action items
- Relevance to project scope

### Idea (I-NN)

Read the row in `docs/01-explore/IDEAS.md`, set its status to `exploring`, then explore it as a topic. Status changes after that (`promoted → {id}`, `dropped ({why})`) are not made here.

## Questions (ask)

```
/mae-explore ask               → questions to deepen mutual understanding (default: for user)
/mae-explore ask {audience}    → questions for: user, client, team, technical
```

Writes a question file to the session folder, answered asynchronously. On the next explore, read the answers and use them.

### Pre-fill rule

Decide by what a wrong guess costs, not by how confident you are:

| A wrong guess… | Do | Marker |
|---|---|---|
| is cheap to correct later | Pre-fill; name where it gets verified | `Pre-answered:` |
| changes a value or scope; the build stays valid | Pre-fill as a stated assumption | `Pre-answered (assumed):` |
| means wasted work or a silently wrong output | Leave open | `OPEN` |
| concerns a preference, priority, budget or business rule | Leave open, always | `OPEN` |

- **Route by who holds the knowledge, not by topic.** Technical → team/architect: pre-fill freely; verified at implementation. Business → client: never pre-filled, whatever your confidence; mark `OPEN — ask the client`. A confident pre-fill on a client-only question reads as an answer and gets silently accepted.
- An `OPEN` question may carry a **working default**, kept apart from the answer, so the build proceeds if it stays unanswered.
- `(assumed)` keeps judgement calls under review; never file one as plain `Pre-answered:`.
- Header count line: "5 pre-answered (2 assumed), 3 open".

### Question types

- **Confirm** (pre-answered only): `- [ ] Pre-answered: {answer} — verified at {where}`. Tick to confirm, edit to correct; untouched, it stands.
- **Multiple choice:** options as `- [ ]`, one labelled `*(working default)*`. Ticking one answers it; nothing ticked = still open and the default applies. The label is not an answer.
- **Open:** `**Response:** _`, plus `**Working default:** {…}` on its own line when one is defensible.

Group questions **Business** / **Technical**; within each group, tag the tier and list `blocking` first, then `important`, `clarifying`.

**Output format:**

```markdown
# Explore: Questions for {audience}
5 pre-answered (2 assumed), 3 open. Tick, edit or answer inline.

## Business

### Q1 [blocking]: {question}
**OPEN — ask the client** · **Unblocks:** {what this enables}
- [ ] {option A}
- [ ] {option B} *(working default)*

### Q2 [important]: {question}
**OPEN — ask the client** · **Affects:** {what it impacts}
**Working default:** {value}
**Response:** _

## Technical

### Q3 [blocking]: {question}
**Unblocks:** {what this enables}
- [ ] Pre-answered: {answer} — verified at {where}

### Q4 [clarifying]: {question}
**Improves:** {what it refines}
- [ ] Pre-answered (assumed): {answer} — {why it's a judgement call}
```

## Final Report (doc)

1. Read ALL explore working artifacts from the current and previous sessions
2. Read any existing material in `docs/01-explore/`
3. Produce structured report using `.maestro/templates/explore.md`, linking each supporting artifact it draws on
4. Save to session folder
5. Ask: "Ready to promote to docs/01-explore/EXPLORE.md?"

`EXPLORE.md` is the fixed name and the only explore file downstream commands read. It is a **living document** — running `explore doc` again replaces it (session keeps the history via numbered files).

## Behavior

1. **Read context:**

   - `docs/00-reference/` (source materials — authoritative on intent)
   - `docs/01-explore/` (confirmed artifacts)
   - Current session files (working artifacts)
   - `DECISIONS.md`, `OPEN_QUESTIONS.md`
   - `maestro.toml` (project context, user profile if configured)
   - `README.md` (if exists)
   - On first explore (no prior artifacts): scan `docs/`, `data/`, `src/` — report what's available, ask before reading
   - For `doc` mode: `.maestro/templates/explore.md` (report structure)
2. **Generate artifact** — type depends on mode (see above)
3. **Every artifact MUST include a questions section** — questions the agent needs answered to deepen understanding. This is not optional. The goal is to build mutual understanding through iterative Q&A.
4. **Save to session folder** (numbered file, e.g., `03_scope-analysis.md`)
5. **Update readiness indicator** in `_summary.md`
6. **For `doc` mode only:** offer promotion to `docs/01-explore/EXPLORE.md`

## Output Behaviors

- Surface unknowns and flag gaps (`GAP:`, `UNCLEAR:`)
- Compare options when multiple approaches exist. Recommend one you consider best.
- Group questions Business / Technical; rank by tier (blocking → important → clarifying)
- When uncertain about what to read or analyze, ask the user rather than guessing

## Skip When
- Requirements are already well-defined (e.g., detailed brief from client) — skip to `/mae-specs`
- Building a trivial script with obvious scope — skip to `/mae-do`
- Returning to a well-explored project — check if coverage is already sufficient before exploring again

## Artifact Flow

Source materials → docs/00-reference/ (placed by the user, read first, never edited)
All explore artifacts → .sessions/ (working material)
Final report (`doc`) → .sessions/ → user promotes to docs/01-explore/EXPLORE.md
When ready → user runs `/mae-specs` to write the specs, or `/mae-poc` for the PoC track

## Rules

- Never invent business requirements — flag unknowns as questions
- Each invocation produces ONE artifact (or a small set if content requires splitting)
- Working artifacts are free-form — no template required
- Only the final report (`doc`) uses the template
- If no material exists and no topic specified, scan for resources and ask orientation questions
- Never auto-read large datasets or extensive doc folders without asking the user first
