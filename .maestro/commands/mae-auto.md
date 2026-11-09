# /mae-auto — Run to a stop point

`/mae-auto [stop-phase]` = `/mae-run {current phase}..{stop-phase}`. Default stop: `do`. One engine, two front doors: `/mae-run` for people who think in ranges, `/mae-auto` for people who want momentum.

⚠️ **Printed first, every time:** auto suppresses every confirmation between the question round and the single review, writing each artifact straight to `docs/` (the review keeps or undoes them). It commits as `[git]` says (default: after every task). It never pushes, and it does not change your tool's own permission mode (Claude Code auto mode, Codex approvals). If you would not let a colleague run the next N phases unattended after one round of questions, do not run this.

$ARGUMENTS — optional: stop phase (`requirements`, `design`, `architecture`, `plan`, `do`, `review`)

## Behavior

1. **Current phase** = the `NEXT` command from the state probe in `.maestro/commands/mae-help.md` § State probe. Do not re-derive it.
2. **Never skip explore.** If `docs/01-explore/` has no artifacts, the chain starts at `explore` regardless of the stop phase, runs it, and **stops for its question round** — the one interruption auto keeps, because building the wrong thing confidently is the worst outcome the framework can produce. After the answers, continue.
3. Probe says "answer questions first" → say which file and stop. Auto does not answer questions.
4. Probe says the project is already past the stop phase → say so and stop: "ARCHITECTURE.md exists; `/mae-auto architecture` has nothing to do. `/mae-auto` or `/mae-auto do`?"
5. Otherwise hand off to `/mae-run {current}..{stop}` with every rule in `mae-run.md`: one question round, one keep/undo review after the last specifying phase, commits per `[git]`, stop on first failure, final report.

## Rules

- Thin by design: no behaviour lives here. A rule auto needs goes in `mae-run.md`.
- The warning is not optional and not configurable.
- Documented, not advertised: `/mae-help all` lists it with the warning; nothing else suggests it.
