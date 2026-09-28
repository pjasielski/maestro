# /mae-run — Chain delivery phases

Run several delivery phases in one pass: **one question round at the front, one review at the end.** Same commands, same artifacts, same rules — with the per-phase interruptions removed. A chain never changes what a command produces, only when it asks.

Documented, not advertised: not in the quickstart; listed by `/mae-help all`. `/mae-yolo` is the momentum front door to the same engine.

$ARGUMENTS — required: a range `{a}..{b}`, or an explicit list `/mae-x -> /mae-y -> /mae-z`. Anything after the range goes to the last phase as its argument.

## Usage

```
/mae-run requirements..plan                          → /mae-requirements, /mae-design (if UI), /mae-architecture, /mae-plan
/mae-run explore..do                                 → the whole track
/mae-requirements -> /mae-architecture -> /mae-plan  → explicit list, no design
/mae-run architecture..do M02                        → "M02" is passed to /mae-do
```

Phase order: `explore` → `requirements` → `design` → `architecture` → `plan` → `do` → `review`. Short forms `req`, `arch`; `specs` = `requirements..architecture`. A range includes `design` only when `/mae-specs` would (missing and the project has a UI). `poc` is not a chain phase — on the PoC track (probe 4 in `mae-help.md`) the engine substitutes `/mae-poc` for `requirements..plan` and `/mae-do poc` for `do`; the user still writes the full-track names.

## Behavior

### 1. Resolve and validate

- `a..b` expands to the phase list; `a` must precede `b`. A one-phase range is refused: "that is just `/mae-{a}`".
- The `->` list must contain delivery commands only, in ascending phase order. Mixing `->` with `..` is an error; say which form to use.
- **Missing prerequisites.** Each phase's prerequisite artifact must exist on disk or be produced earlier in the same chain. `architecture..do` with no REQUIREMENTS.md → stop: "`architecture` needs REQUIREMENTS.md, which does not exist. `/mae-run requirements..do` works." Never fill the gap silently.
- Print the resolved plan, one line per phase, plus the trade-off in one line: "N phases, one question round now; each artifact is written straight to `docs/`; one review after `{last specifying phase}` keeps or undoes them; commits per `[git]`." Confirm once. This confirmation is the approval for the chain's `docs/` writes, and the only confirmation before the question round.

### 2. One question round

- Before producing anything, run each phase's question step in **collect** mode — explore's `blocking` questions, architecture's Must Answer tier, design's source question, poc's blocking questions — and write them once, deduplicated, to `NN_chain-questions.md` in the session folder, grouped by phase. Each question carries `**Response:** _` and a working default where one is defensible (the `Pre-answered (assumed):` vocabulary from `/mae-explore`).
- Say: "N questions across {phases} — see `{file}`. Answer inline and say `go`. Unanswered questions proceed on their working default and are marked `UNCLEAR:` in the artifact they affect."
- Non-blocking questions (Important, Clarifying, Recommend, Your call) are not asked. They become `UNCLEAR:` flags inside the artifact they belong to.
- No blocking questions anywhere → say so in one line and continue without stopping.

### 3. Run the specifying phases

- Each phase runs its own protocol (command file, or skill / `mae-specs` reference) unchanged, with two changes: it writes its artifact **straight to the canonical path in `docs/`** instead of a session draft, and it skips its "ready to promote?" prompt and per-phase report. The next phase reads that file the normal way.
- Before a phase overwrites or edits a file that already exists, copy it to `.sessions/{NNN}/_chain-backup/{same path}`. Record every file the chain creates or changes, in order.
- Chat gets one line per phase: "`requirements` → `docs/02-specs/REQUIREMENTS.md` (new)".

### 4. One review

- After the last specifying phase (`plan`; or `architecture`, `design`, `requirements`, `explore` when the range ends earlier): one message listing every file the chain created or changed, in order, each with its link, `(new)` or `(changed)`, and its report header (Summary, Flags). Then: "Keep? (all / undo {list} / undo all)".
- Undo deletes a file the chain created and restores a changed one from `_chain-backup/`. Undoing a spec also undoes everything built on it later in the chain (undo `requirements` → its plan too); list those before acting. After any undo, stop the chain there if `do` was in range — `do` runs only against kept specs.

### 5. `do` and `review` after the review

- `do` runs as `/mae-do M{MM}` multi-task execution on the milestone the chain planned (or the one named in the argument): stop on first failure, task status and ROADMAP updated after every task, never batched.
- **Git follows `[git]` exactly** (MAESTRO.md § Git Policy). A chain batches questions and reviews; it never loosens a git setting. `commit = "never"` → no commits, and the report says "not committed". `branch = "milestone"` → the branch question is asked once, before the first task. Never push, merge or open a PR inside a chain.
- `review` runs `/mae-review` over what the chain produced and saves its findings as usual.

### 6. Final report

Saved to the session as `NN_chain-report.md`; chat gets the link and one sentence. Contents: phases run; files kept and undone, with links; questions answered vs. deferred, with the defaults used; commits made (hashes, one line each) or "not committed"; what was **not** done and why — failure, undone artifact, missing prerequisite. Never paste the artifacts back into chat.

## Rules

- Stop on first failure at any phase. Leave an accurate record: files written, `_chain-backup/`, task statuses, commits. The keep/undo review still runs for what was written.
- Instruction priority is unchanged: an explicit instruction in the question file wins over any default.
- If a phase's protocol changes, the chain changes with it. Fix behaviour in that file, never here.

## Skip When

- One phase — run the command
- The user wants to see each artifact before the next is built — that is the default flow, not a chain
