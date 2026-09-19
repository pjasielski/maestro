# /mae-help — What should I run now?

State-aware guidance. Answers "what do I do next" from what exists on disk and shows the three or four commands that make sense now — never all of them.

$ARGUMENTS — optional: `all`, or one command name (`mae-req`, `mrq`, `sync`)

## Usage

```
/mae-help              → project state, the next command, 3–4 relevant commands
/mae-help all          → every command, grouped by phase
/mae-help {command}    → one command: what it does, when to skip it, what it reads, what it writes
```

## State probe (shared — defined here, nowhere else)

The framework's one state reader. `/status` renders it as "where am I"; `/mae-help` renders it as "what do I do"; `/mae-yolo` uses it to find the current phase; skill fit checks and gates (`.maestro/skills/CONVENTIONS.md` §1) use it to decide whether to announce or stay quiet. Change it here; every other file points here.

Existence checks, `grep`, and header lines only. Never read a canonical file in full to answer "what next".

| # | Probe | How |
|---|---|---|
| 1 | Session | Highest-numbered `.sessions/{NNN}-*/`; whether its `_summary.md` exists |
| 2 | Reference | `docs/00-reference/` has files; newest modification time |
| 3 | Explore | `docs/01-explore/` has files other than `.gitkeep` |
| 4 | Track | `docs/02-poc/POC.md` exists → PoC track; `docs/02-requirements/REQUIREMENTS.md` exists → full track; both → full track (graduated PoC) |
| 5 | Design | `docs/03-design/DESIGN.md` exists |
| 6 | Roadmap | `docs/04-plan/ROADMAP.md` exists; count `☐ todo`, `🔄`, `⏳`, `✅` in it (grep); PoC track without a roadmap: same counts in POC.md § 4 |
| 7 | Next task | First `☐ todo` row whose `Depends` entries are all `✅` — ROADMAP table on the full track, POC.md § 4 on the PoC track. Task files are not opened |
| 8 | Questions | Session files matching `*questions*.md` that still contain `**Response:** _` |
| 9 | Unsynced | `_summary.md` has `✓` decision lines without `[synced]` |
| 10 | Stale scope | Newest file in `docs/00-reference/` is newer than REQUIREMENTS.md (or POC.md) |

## State table

First matching row wins. This table is also the auto-trigger heuristic for skills — CONVENTIONS.md §3 points here.

| State | Next | Also relevant |
|---|---|---|
| Unanswered questions in the session (8) | Answer them — name the file | the command that asked them |
| No explore artifacts, no session (1, 3) | `/mae-explore` | `/mae-init` if `maestro.toml` has no profile |
| Explore artifacts; no REQUIREMENTS.md, no POC.md (3, 4) | `/mae-req` — or `/mae-poc` if the build is one milestone and time-boxed | `/mae-explore doc` if there is no final report yet |
| Reference newer than requirements (10) | `/mae-scope` | `/mae-explore {file}` when the new material is a whole area |
| REQUIREMENTS.md, no DESIGN.md (4, 5) | `/mae-design` | `/mae-review requirements` |
| DESIGN.md, no ROADMAP.md (5, 6) | `/mae-plan` | `/mae-review design` |
| POC.md, todo rows in § 4 (4, 6, 7) | `/mae-do poc`, or `/mae-do M01.{NN}` for the next one | `/mae-review` |
| ROADMAP.md with ☐ todo (6, 7) | `/mae-do {next unblocked id}` | `/mae-review`, `/status tasks` |
| Nothing todo; unsynced decisions (6, 9) | `/sync` | `/mae-plan` for the next milestone; a finished PoC graduates with `/mae-plan` at M02 |
| Everything synced, nothing todo | `/mae-plan` (next milestone) or `/mae-scope` (new request) | `/mae-explore` for a new area |

## Behavior

### Bare

1. Run the probe.
2. Print exactly this shape, nothing else:

```
STATE   {full track | PoC track} · {phase} · session {NNN}-{name}
NEXT    /mae-do M04.15 — {one line: why this, from the probe}
ALSO    /mae-review           {why it fits now}
        /status tasks         {…}
        /sync                 {…}
        /mae-help all         every command
```

3. Name a concrete argument wherever the probe gives one: `/mae-do M04.15`, not `/mae-do`.
4. Three or four lines under ALSO. Never the full list.
5. Nothing is written: no session file, no `_summary.md` update.

### all

Every command, grouped, one line each — command, alias, what it produces:

- **Explore** — `mae-explore` (`mex`), `mae-poc` (`mpoc`)
- **Specify** — `mae-req` (`mrq`), `mae-design` (`mds`), `mae-scope` (`msc`)
- **Plan and build** — `mae-plan` (`mpl`), `mae-do` (`mdo`), `mae-review` (`mrv`)
- **Session** — `status`, `decide`, `sync`, `md`, `mae-init`
- **Chaining** — `mae-run`, `mae-yolo`, each with its one-line warning from its command file

End with: "`/mae-help {command}` for details."

### {command}

Resolve aliases (`mex` → `mae-explore`, `msc` → `mae-scope`). Read only that command file. Answer four questions in at most twelve lines: what it does (its first paragraph); when to skip it (`## Skip When`); what it reads (`## Prerequisites` or step 1 of `## Behavior`); what it writes (`## Artifact Flow` or the save steps). Unknown name → the three closest names, nothing else.

## Rules

- Cheap enough to run habitually: no file is read in full except the one command file in `{command}` mode
- Suggests, never runs — `/mae-help` has no side effects
- Chaining commands appear under `all` only, never under NEXT or ALSO
- On a graduated PoC (POC.md and REQUIREMENTS.md both exist) the full-track rows apply
