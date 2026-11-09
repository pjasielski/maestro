# /mae-design — Visual Design System

Write `docs/02-specs/DESIGN.md`: the visual system (colour, type, spacing, components) in the DESIGN.md format, so mocks, code and other agents use the same values. Architecture is `/mae-architecture`.

**Artifact** (MAESTRO.md § Artifact Capture): DESIGN.md draft (session) → `docs/02-specs/DESIGN.md` on promotion; report.

$ARGUMENTS — optional: focus (e.g. "colours only")

## Prerequisites
- The project has a UI (per EXPLORE.md, REQUIREMENTS.md or `docs/02-specs/mock/`). No UI → say so and stop
- Explore artifacts but no `EXPLORE.md` → ask once (MAESTRO.md § Layout Rules)

## Behavior

1. **Pick the source, first match wins:**
   - Approved mock in `docs/02-specs/mock/` → **extract**: the colours, type and components the client already approved, plus the choices recorded in `_screens.md`. Don't invent new ones
   - Brand assets or screenshots in `docs/00-reference/`
   - Neither → ask: "No mock or brand assets found. Add some to `docs/00-reference/`, or shall I propose a neutral system?"
2. **Read:** REQUIREMENTS.md (screens, platforms, accessibility), DECISIONS.md, `.maestro/templates/design.md` (output structure)
3. **Generate DESIGN.md** from the template: exact token values in the front matter; the eight prose sections in spec order. Name the source of each choice (mock, brand asset, default). Unknown brand value → `GAP:`, never invented. Flag text/background pairs below WCAG AA contrast
4. **Save draft** to the session; offer promotion to `docs/02-specs/DESIGN.md` (same rule as `/mae-requirements` step 4)
5. **Save report** to the session

## Rules
- DESIGN.md exists → mocks follow it. Changes after sign-off go through `/mae-scope`
- Visual only: no component logic, APIs or data (that's ARCHITECTURE.md)

## Skip When
- No UI (CLI, API, data pipeline)
- The client has a design system — reference it in `docs/00-reference/` instead of restating it

## File Size
- Target: 800–2,000 words; hard max: 3,000
- Past the hard max, split per the main-file rule: DESIGN.md (foundations) + `design/{component-group}.md`
