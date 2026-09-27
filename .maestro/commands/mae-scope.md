# /mae-scope — Scope-change intake

Mid-project, new scope arrives: a client request, a change file, a new brief in `docs/00-reference/`. Instead of re-running `/mae-req` and regenerating everything, decompose the request, classify each capability against what exists, write a client-sendable impact analysis, and only then — on confirmation — apply the deltas to every canonical file at once.

Alias: `msc`

$ARGUMENTS — optional: `"{description}"`, or a path to a request file; none → look in `docs/00-reference/`

## Usage

```
/mae-scope "client wants multi-currency and an approvals queue"
/mae-scope docs/00-reference/change-request-2.md
/mae-scope                → lists files in docs/00-reference/ newer than REQUIREMENTS.md, asks which one
```

## Prerequisites

- `docs/02-specs/REQUIREMENTS.md` or `docs/02-specs/POC.md` must exist — without one there is no scope to change; say so and suggest `/mae-explore` or `/mae-req`
- `ARCHITECTURE.md` and `ROADMAP.md` are optional inputs; a missing one drops its section from the delta with a one-line note

## Behavior

### Step 1 — Intake

Read: the request; REQUIREMENTS.md (or POC.md); ARCHITECTURE.md § 2 Architecture and § 4 Data Model plus any section the request names; ROADMAP.md milestone tables; `docs/03-plan/tasks/` filenames only; DECISIONS.md confirmed rows. Not the explore folder, not source code — a scope change is explored against existing constraints, which is what makes it different from `/mae-explore`.

Decompose the request into discrete capabilities — one verifiable sentence each, numbered `C1…Cn`. A "small request" is usually three.

### Step 2 — Classify

Exactly one class per capability:

| Class | Meaning | Test |
|---|---|---|
| **additive** | New; touches nothing that exists | No existing requirement, design section, or task changes meaning |
| **modifying** | Changes settled behaviour | An existing requirement or design section must be rewritten; nothing is contradicted |
| **conflicting** | Contradicts a shipped requirement or a recorded decision | Name the exact ID: `R-007`, `ARCHITECTURE.md § 4.1`, `D14` — and where it is load-bearing |

**Size check** before going further. More than five capabilities, or any capability with no anchor in an existing ARCHITECTURE.md section → stop: "This adds a product area, not a milestone — run `/mae-explore {area}` first, then `/mae-scope` to integrate the result." Continue only if the user says so.

### Step 3 — Impact analysis (analysis only; no canonical file is touched)

Write `.sessions/{NNN}/NN_scope-delta.md` from `.maestro/templates/scope-delta.md`:

- Sections `## Requirements`, `## Design`, `## Roadmap`, `## Decisions needed`; one line per change, prefixed `ADDED` / `MODIFIED` / `REMOVED` / `CONFLICT` (the D19 vocabulary; M05.01 later mechanises the merge)
- `MODIFIED` lines carry `(was: …)`; `CONFLICT` lines name what they contradict and every place that depends on it
- `## Roadmap` proposes the milestone: `M{next}`, tasks with S/M/L and dependencies, and existing tasks that become blocked
- `## Decisions needed`: each open choice and what it blocks
- Header: capability table with class per row, and one cost line — "3 capabilities: 2 additive, 1 conflicting — est. one milestone, M"

This file is client-sendable: it answers "what does this cost" in their vocabulary before any code exists. Chat gets the link and the cost line, nothing more.

Then ask: "Apply all, apply some (list capability IDs), or stop here?"

### Step 4 — Apply (only on explicit confirmation)

For the approved capabilities, in this order, each as a review-required diff:

1. **REQUIREMENTS.md** — add or modify rows; new IDs continue the file's own scheme
2. **ARCHITECTURE.md** — add or modify sections; a resolved `CONFLICT` is rewritten and the old text is quoted under Notes for one version
3. **ROADMAP.md** — append the milestone from `## Roadmap`; set `⏳ blocked` on existing tasks the delta blocks
4. **Task files** — generate `docs/03-plan/tasks/M{MM}.{NN}-{slug}.md` for the new milestone (`.maestro/templates/task.md`, IDs per D23)
5. **Log resolved conflicts** — one row per resolved `CONFLICT` through the `/decide` protocol, text "supersedes {ID}: {what changed}". *Deliberately isolated: when ADRs land (M05.06) this step emits an ADR instead, and nothing else here changes.*
6. **Deferred scope** — capabilities not approved go to HANDOFF.md under `## Deferred scope` as `- {date} · C{n} {one line} · see {NN_scope-delta.md}`; create the section if missing. They must not silently evaporate.

Report in chat: files changed, milestone added, tasks created, decisions logged, capabilities deferred — one line each.

## Output Behaviors

- Classification comes first; a capability the agent cannot classify is `UNCLEAR:` with a working class, never a silent guess
- Never invent requirements to fill a gap in the request — the gap goes under `## Decisions needed`
- Step 3 never edits a canonical file; step 4 never runs without the user's word

## Skip When

- No REQUIREMENTS.md yet — `/mae-req` territory
- The change is one requirement row — edit it under review, `/decide` if it reverses anything
- The change is a new product area — `/mae-explore {area}` first

## Artifact Flow

```
request (argument · file · docs/00-reference/)
  → /mae-scope  →  .sessions/{NNN}/NN_scope-delta.md          (analysis; send to the client)
  ──apply, on confirmation──→  REQUIREMENTS.md · ARCHITECTURE.md · ROADMAP.md · tasks/ · DECISIONS.md · HANDOFF.md § Deferred scope
```
