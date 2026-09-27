---
version: alpha
name: {Product} Design System
description: {one line: the look and feel}
colors:
  primary: "{#hex}"
  on-primary: "{#hex}"
  surface: "{#hex}"
  on-surface: "{#hex}"
  error: "{#hex}"
typography:
  heading-lg:
    fontFamily: {Font}
    fontSize: {32px}
    fontWeight: {700}
    lineHeight: {1.2}
  body-md:
    fontFamily: {Font}
    fontSize: {16px}
    fontWeight: {400}
    lineHeight: {1.5}
rounded:
  md: {8px}
spacing:
  sm: {8px}
  md: {16px}
  lg: {24px}
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.body-md}"
    rounded: "{rounded.md}"
    padding: "{spacing.sm}"
---

<!--
  Maestro visual design template: DESIGN.md format (google-labs-code/design.md, version alpha).
  Front matter = exact tokens; prose = why and how to apply them. Keep the eight sections in this order.
  Token references: {colors.primary}. Component keys: backgroundColor, textColor, typography, rounded, padding, size, height, width.
  Source of each choice: approved mock → brand assets in docs/00-reference/ → ask. Name it per section.
  Target: 800–2,000 words | Hard max: 3,000. Past it, split per the main-file rule: DESIGN.md + design/{component-group}.md.
-->

## Overview

{Look and feel in 2–3 sentences; audience; source: mock / brand assets / default.}

## Colors

{Role of each colour token; contrast rules.}

## Typography

{Scale and when each style is used.}

## Layout

{Grid, spacing scale, breakpoints.}

## Elevation & Depth

{Shadows or flat; how hierarchy is shown.}

## Shapes

{Corner radius, borders.}

## Components

{Each component in the front matter: states, usage.}

## Do's and Don'ts

- {Do}
- {Don't}
