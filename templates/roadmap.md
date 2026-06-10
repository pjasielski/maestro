# ROADMAP — {Project Name}

**Version:** {current version}
**Updated:** {YYYY-MM-DD}
**Sources:** {sessions, reviews, or documents that informed this roadmap}

<!--
  Maestro Roadmap Template
  Strategic backlog organized by milestone. Not a substitute for task files —
  this is *what to build*; task files are *how to build it*.

  Columns:
  - #: Item number within milestone (1.1, 1.2, ...)
  - Item: Short, descriptive name (bold)
  - Priority: P0 (bug) | P1 (required) | P2 (improvement) | P3 (future)
  - Effort: S (hours) | M (a session) | L (multiple sessions) | XL (multi-day)
  - Depends: Item numbers that must complete first, or "—"
  - Source: Where the need was identified (session numbers, review findings)

  Keep item descriptions concise — one line. If more detail is needed,
  reference a task file or delivery artifact.

  Convert high-priority items to task files via /mae-plan when ready.
-->

---

## Milestone 1: {Theme} ({target version})

{One-line description of this milestone's goal.}

| # | Item | Priority | Effort | Depends | Source |
|---|------|----------|--------|---------|--------|
| 1.1 | **{Item name — concise but descriptive enough to stand alone}** | P0 | S | — | {session/review} |
| 1.2 | **{Item name}** | P1 | M | 1.1 | {source} |

**Done when:** {One-line definition of done for this milestone.}

---

## Milestone 2: {Theme} ({target version})

{One-line description.}

| # | Item | Priority | Effort | Depends | Source |
|---|------|----------|--------|---------|--------|
| 2.1 | **{Item name}** | P1 | M | — | {source} |

**Done when:** {Definition of done.}

---

## Future (post {version})

| # | Item | Priority | Effort | Depends | Source |
|---|------|----------|--------|---------|--------|
| F.1 | **{Item name}** | P3 | L | {dependency} | {source} |

---

## How to Use

This roadmap is the **intake backlog** for `/mae-plan`. When ready to implement a milestone:

1. Run `/mae-plan` referencing specific items
2. Plan generates task files in `delivery/04-plan/tasks/`
3. Execute with `/mae-do`
4. Mark items here as complete

Milestones are not strictly sequential — items within a milestone can be picked independently.
P0 items should be addressed before feature work.
