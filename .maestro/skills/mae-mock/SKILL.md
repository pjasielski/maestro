---
name: mae-mock
description: >-
  Build clickable, self-contained HTML mockups of the product's screens in
  docs/02-specs/mock/ (index.html, one file per screen, and _screens.md mapping screens
  to requirements) that open by double-click and can be sent to a client. Use when the
  user wants to see what the app could look like, show a client some screens, prototype
  a UI, or check a flow visually, even if they never say "mock". Also handles /mae-mock.
  Do NOT use to define the visual design system (mae-specs design), write requirements
  (mae-specs), or build the real frontend (mae-do). Propose first; produce only after the
  user confirms.
license: MIT
compatibility: >-
  Requires a project initialized with Maestro (.maestro/, HANDOFF.md, .sessions/).
  Any Agent Skills client (Claude Code, Cursor, Codex CLI).
metadata:
  maestro-tier: suggest
  maestro-command: /mae-mock
  maestro-version: "0.5.0"
---

# mae-mock — Clickable HTML Mockups

Standalone HTML mockups of the screens, so a client can see and click through what will be built. The HTML is the review artifact: no brief file.

$ARGUMENTS — optional: a screen list in quotes, or one `{screen}` to regenerate

## Gate (auto-invocation only)

When you chose this skill yourself, write nothing and say one line: "Want me to mock the screens with `/mae-mock`? (yes / not now)". Proceed only when the user typed the command or confirmed.

## Usage

```
/mae-mock                            screens inferred from the specs
/mae-mock "onboarding + dashboard"   these screens
/mae-mock {screen}                   regenerate one screen and its _screens.md row
```

## Read first

First match wins per concern. Never individual explore artifacts or session files.

| Concern | Sources, in priority order |
|---|---|
| What the screens must do | `docs/02-specs/REQUIREMENTS.md` → `docs/02-specs/POC.md` → `docs/01-explore/EXPLORE.md` |
| How they look | `docs/02-specs/DESIGN.md` → brand assets or screenshots in `docs/00-reference/` → neutral default, recorded in `_screens.md` |

Explore artifacts but no `EXPLORE.md` → ask once: "Run `/mae-explore doc` first, or mock from the latest report?"

## Behavior

1. **Confirm the screen list in chat before any HTML**, one message: "I'll mock these N screens: {list}, {desktop | mobile}, look from {source}. Go?" No DESIGN.md and no brand assets → add to the same line: "No brand assets found. Add some to `docs/00-reference/`, or use a neutral palette?"
2. **Generate** in `docs/02-specs/mock/`: one `{screen}.html` per screen and `index.html` linking every screen.
   - Self-contained: inline CSS and JS; no CDN, web fonts, remote images or any other external request. Opens by double-click; links between screens work locally
   - Realistic placeholder data, not lorem ipsum
   - DESIGN.md exists → use its tokens exactly
3. **Write `_screens.md`** from `.maestro/templates/screens.md`: each screen → the requirement IDs it demonstrates, or `exploratory`; the look source and the values used; assumptions; `GAP:` lines.
4. **Check before reporting:** no `http` in any `src` or `href`; every screen linked from `index.html` and listed in `_screens.md`. Fix, then report.
5. **Report** in chat: where it saved, screen count, gap count, next step (send to the client; `/mae-scope` for gaps; `/mae-specs design` extracts DESIGN.md once the mock is approved).

**Variants** ("show me three directions"): generate each in the session folder (`.sessions/{NNN}/mock-{variant}/`), then promote the chosen one to `docs/02-specs/mock/`.

## Rules

- A mock never edits requirements. A gap it exposes → `GAP: {what} — suggest /mae-scope` in `_screens.md`; `/mae-requirements` and `/mae-poc` read those lines as open questions.
- Writes straight to `docs/02-specs/mock/`, like `/mae-plan`. Regenerating replaces files; say which.
- DESIGN.md exists → the mock follows it. The mock came first and is approved → `/mae-specs design` extracts DESIGN.md from it.

## Skip When

- No UI (CLI, API, data pipeline)
- The client already supplied designs → put them in `docs/00-reference/` and run `/mae-specs design`
