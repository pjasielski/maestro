---
name: mae-explore
description: >-
  Build shared understanding of a project before anything is specified or built:
  scope overview, gaps, risks, and questions for the user, client, or team. Use when the
  user wants to explore, scope, or make sense of an idea, brief, transcript, meeting
  notes, or an unfamiliar codebase; asks "what are we missing" or "what should we ask
  the client"; or is starting a new project or engagement, even if they never say
  "explore". Also handles /mae-explore, mex, "explore ask", and "explore doc".
  Do NOT use to formalize requirements (mae-requirements), design architecture (mae-architecture),
  plan tasks (mae-plan), implement or fix code (mae-do), review existing work
  (mae-review), or answer a quick factual question about the code. Answer those directly.
license: MIT
compatibility: >-
  Requires a project initialized with Maestro (.maestro/, HANDOFF.md, .sessions/).
  Any Agent Skills client (Claude Code, Cursor, Codex CLI).
metadata:
  maestro-tier: auto
  maestro-command: /mae-explore
  maestro-aliases: mex
  maestro-version: "0.5.0-spike"
---

# mae-explore — Build Understanding

Build mutual understanding of the project, business and technical. Adapt to what exists and what is needed. Every explore output includes questions that deepen understanding.

`$ARGUMENTS` (optional): a topic, a file path, `ask [audience]`, or `doc`.

## Fit check (auto-invocation only)

When this skill was chosen by the model rather than typed as `/mae-explore` or `mex`:

- If the project already has `docs/02-specs/REQUIREMENTS.md`, `docs/02-specs/POC.md`, or a task marked in-progress, say in one line what you are about to explore and why, then continue. Never produce an explore artifact silently in a project that is past exploration.
- If the request is a one-step factual question, answer it directly and do not run this protocol.

## Modes

| Invocation | Produces |
|---|---|
| `/mae-explore` | Smart default: the most useful artifact right now |
| `/mae-explore {topic}` | Focused deep-dive on one area |
| `/mae-explore {file path}` | Structured summary of a document or transcript |
| `/mae-explore ask [user\|client\|team\|technical]` | Question file for that audience (default: user) |
| `/mae-explore doc` | Final explore report from all artifacts, using the report template |

## Read context first

1. `docs/00-reference/` — source materials the user did not write (briefs, specs, transcripts, exported tickets). Authoritative on intent. Read in full unless very large; if large, report sizes and ask.
2. `docs/01-explore/` — confirmed explore artifacts.
3. Current session files in `.sessions/{NNN}-{name}/` — working artifacts.
4. `DECISIONS.md`, `OPEN_QUESTIONS.md`, `maestro.toml` (project context, user profile), `README.md` if present.
5. `doc` mode only: `.maestro/templates/explore.md` — the report structure.

On a first explore (no prior artifacts): also scan `docs/`, `data/`, and source code, listing file names, sizes, and directory tree only. Report what exists and ask which to include before reading large files or datasets.

**Reference material wins.** Where `docs/00-reference/` conflicts with what the code implies, the reference describes intent and the code describes current state. Report the difference as a finding.

## Smart default

**First explore (nothing exists):** scan resources as above, then produce an initial scope artifact: business and technical overview from what is available, gaps and problems tagged `GAP:` / `UNCLEAR:`, and a questions section.

**Subsequent explores:** assess readiness before choosing the artifact.

| Readiness signal | What it checks |
|---|---|
| Scope defined | Is there a business and technical overview? |
| Key questions resolved | Ratio of resolved to open questions in `_summary.md` and prior artifacts |
| Coverage breadth | Do artifacts cover business, technical, and stakeholder angles? |
| Blocking gaps | Any `GAP:` or `UNCLEAR:` flags still unresolved? |
| User intent | Has the user signalled readiness to move on? |

Then produce the most useful next artifact: gap analysis, deeper analysis of one area, risk identification, or a question list. When coverage is strong and gaps are few, say so: "Coverage looks solid — [covered]. Remaining gaps: [list]. Consider `/mae-explore doc` when ready, or continue exploring [areas]."

## Topic and file modes

**Topic** (`/mae-explore "auth system"`): focused analysis of that area. Read existing explore artifacts first to avoid repeating them.

**File** (`/mae-explore path/to/transcript.md`): read the file and produce a structured summary with key points, decisions mentioned, questions raised, action items, and relevance to project scope.

## Questions mode (`ask`)

Generate a structured question document for the audience, saved to the session folder. Questions are answered asynchronously in the file, so each has a `**Response:** _` placeholder. Format and ranking rules are in [references/question-format.md](references/question-format.md). There is no cap on the number of questions.

On the next explore, read answered questions and incorporate them.

## Final report (`doc`)

1. Read all explore working artifacts from the current and previous sessions.
2. Read anything already in `docs/01-explore/`.
3. Produce the report using `.maestro/templates/explore.md`.
4. Save to the session folder.
5. Ask: "Ready to promote to `docs/01-explore/`?"

The report is a living document. Running `doc` again replaces the previous version; the session keeps history through numbered files.

## After every artifact

1. Save it to the session folder as the next numbered file (`NN_kebab-description.md`).
2. Append a readiness assessment to the session `_summary.md`:

```markdown
## Explore Readiness
- Scope: ✓ defined / ✗ missing
- Business context: ✓ covered / ~ partial / ✗ missing
- Technical context: ✓ covered / ~ partial / ✗ missing
- Stakeholders: ✓ identified / ~ partial / ✗ missing
- Blocking questions: N remaining
- Recommendation: [continue exploring / ready for doc synthesis]
```

3. In chat: a link to the file and one or two sentences. Never paste the artifact back.

## Rules

- Every artifact ends with a questions section, ranked blocking → important → clarifying. Questions are first-class output, not an afterthought.
- Never invent business requirements. Flag unknowns as `GAP:` or `UNCLEAR:` and ask.
- Compare options when several approaches exist and recommend one.
- One artifact per invocation, or a small set only when content must be split.
- Working artifacts are free-form. Only the `doc` report uses the template.
- Never read large datasets or extensive doc folders without asking first.
- When unsure what to read or analyze, ask rather than guess.

## Skip when

- Requirements are already well defined (detailed client brief): go to `mae-req`.
- The scope is a trivial script: go to `mae-do`.
- The project is already well explored: check coverage before exploring again.

## Artifact flow

Source materials → `docs/00-reference/` (placed by the user, read first, never edited).
All explore artifacts → `.sessions/` (working material).
Final report (`doc`) → `.sessions/` → user promotes to `docs/01-explore/`.
Next: `/mae-req` to formalize requirements, or `/mae-poc` for the PoC track.
