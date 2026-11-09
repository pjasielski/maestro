# Scope delta: {request title}
**Date:** {YYYY-MM-DD}
**Session:** {NNN}-{name}
**Request:** {argument text · file path · docs/00-reference/{file}}
**Against:** REQUIREMENTS.md v{n} · ARCHITECTURE.md v{n} · ROADMAP.md (last milestone M{MM})

## Capabilities

| # | Capability | Class | Anchors |
|---|---|---|---|
| C1 | {one verifiable sentence} | additive / modifying / conflicting | {R-IDs, ARCHITECTURE §, task IDs it touches} |

**Cost:** {n} capabilities: {a} additive, {m} modifying, {c} conflicting — est. {one milestone / part of M{MM}}, {S/M/L}

## Requirements

```
ADDED     R-{id}  {text}                                       ← C1
MODIFIED  R-{id}  {new text}  (was: {old text})                ← C2
CONFLICT  R-{id}  {what contradicts it; load-bearing in ARCHITECTURE.md § …, task M{MM}.{NN}}  ← C3
```

## Design

```
ADDED     § {section}  {what}
MODIFIED  § {section}  {what changes}  (was: …)
CONFLICT  § {section}  {assumption that breaks; every place that depends on it}
```

## Roadmap

```
ADDED     M{MM} {name} — {n} tasks, est. {S/M/L}
          M{MM}.01 {task}  [S]  depends: —
          M{MM}.02 {task}  [M]  depends: M{MM}.01
MODIFIED  M{MM}.{NN} — now blocked by M{MM}.01
```

## Decisions needed

```
Q1  {question}  → blocks {task or capability}
Q2  {question}  → blocks {…}
```

---
**Notes:**
- {UNCLEAR: classifications the agent is unsure of, with the working class used}
