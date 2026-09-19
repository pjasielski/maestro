# Project Status

Show current project state. Supports sub-commands for focused views.

$ARGUMENTS — optional sub-command: tasks, decisions, questions

## Usage

```
/status              → overview (default)
/status tasks        → task board
/status decisions    → decision summary
/status questions    → open questions
```

## Behavior

### Overview (default)

State is read with the **state probe** in `.maestro/commands/mae-help.md` § State probe — existence checks, `grep`, and header lines only. `/status` renders it as "where am I"; `/mae-help` renders the same probe as "what do I do". Do not re-derive the probe here.

In addition to the probe:
1. `HANDOFF.md` § Current Status only — phase, blockers (header block, not the whole file)
2. `OPEN_QUESTIONS.md` — count rows by priority
3. `WORKLOG.md` — last 3 rows
4. Task counts — the `**Status:**` header line of each file in `docs/04-plan/tasks/`, not the files

Output:
```
PROJECT: {name}
PHASE: {current phase}

PROGRESS
  {phase list with status markers: done / in progress / pending}

TASKS: {N} todo, {N} in-progress, {N} done, {N} blocked
DECISIONS: {N} confirmed ({N} unsynced)
QUESTIONS: {N} open ({N} high priority)
BLOCKERS: {list or "None"}

RECENT ACTIVITY
  {last 3 worklog entries}
```

### Tasks (/status tasks)

Read all files in `docs/04-plan/tasks/`. Group by status:

```
TASK BOARD

IN PROGRESS
  [{id}] {title} — {priority} — {assigned}

TODO
  [{id}] {title} — {priority} — {effort}

BLOCKED
  [{id}] {title} — blocked by: {blocker}

DONE (last 5)
  [{id}] {title} — completed {date}
```

If no task files exist, say: "No tasks yet. Use `/mae-plan` to create the implementation plan."

### Decisions (/status decisions)

Read `DECISIONS.md`. Group by status:

```
DECISIONS

UNSYNCED (not yet in HANDOFF.md)
  [{date}] {decision} — {status marker}

RECENT (last 10)
  [{date}] {decision} — {status marker}

Total: {N} confirmed, {N} proposed, {N} tentative, {N} parked
```

### Questions (/status questions)

Read `OPEN_QUESTIONS.md`. Show by priority:

```
OPEN QUESTIONS

HIGH
  [{id}] {question} — blocks: {what}

MEDIUM
  [{id}] {question}

LOW
  [{id}] {question}

RESOLVED RECENTLY (last 5)
  [{id}] {question} — resolved: {date}
```

## Rules

- State comes from the shared probe in `mae-help.md`; `/status` adds counts and recent activity, `/mae-help` adds the suggestion

- Keep output concise — no decorative borders
- Task/decision/question counts always shown in overview, even if zero
- Unsynced decisions flag reminds user to run `/sync`
- If a sub-command target has no data, say what command creates it
