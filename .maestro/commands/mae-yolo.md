# /mae-yolo — Run to a stop point

`/mae-yolo [stop-phase]` = `/mae-run {current phase}..{stop-phase}`. Default stop: `do`. One engine, two front doors: `/mae-run` for people who think in ranges, `/mae-yolo` for people who want momentum.

⚠️ **Printed first, every time:** yolo suppresses every confirmation between the question round and the single review. It commits after every task. It never pushes. If you would not let a colleague run the next N phases unattended after one round of questions, do not run this.

$ARGUMENTS — optional: stop phase (`req`, `design`, `plan`, `do`, `review`)

## Behavior

1. **Current phase** = the `NEXT` command from the state probe in `.maestro/commands/mae-help.md` § State probe. Do not re-derive it.
2. **Never skip explore.** If `docs/01-explore/` has no artifacts, the chain starts at `explore` regardless of the stop phase, runs it, and **stops for its question round** — the one interruption yolo keeps, because building the wrong thing confidently is the worst outcome the framework can produce. After the answers, continue.
3. Probe says "answer questions first" → say which file and stop. Yolo does not answer questions.
4. Probe says the project is already past the stop phase → say so and stop: "DESIGN.md exists; `/mae-yolo design` has nothing to do. `/mae-yolo` or `/mae-yolo do`?"
5. Otherwise hand off to `/mae-run {current}..{stop}` with every rule in `mae-run.md`: one question round, one review after the last specifying phase, per-task commits inside `do`, stop on first failure, final report.

## Rules

- Thin by design: no behaviour lives here. A rule yolo needs goes in `mae-run.md`.
- The warning is not optional and not configurable.
- Documented, not advertised: `/mae-help all` lists it with the warning; nothing else suggests it.
