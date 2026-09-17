# Explore question file format

Used by `mae-explore ask [audience]`. Save as the next numbered session file, for example `03_questions-client.md`. The audience fills in responses directly in the file.

## Ranking

- **Blocking** — answers needed before work can proceed. Each states what it unblocks.
- **Important** — significantly affects direction. Each states what it affects.
- **Clarifying** — would improve quality. Each states what it improves.

No cap on the number of questions. Rank honestly: a question is blocking only if work genuinely stops without the answer.

## Template

```markdown
# Explore: Questions for {audience}

## Blocking (answers needed before we can proceed)

### Q1: {question}
**Unblocks:** {what this enables}

**Response:** _

### Q2: {question}
**Unblocks:** {what this enables}

**Response:** _

## Important (significantly affects direction)

### Q3: {question}
**Affects:** {what it impacts}

**Response:** _

## Clarifying (would improve quality)

### Q4: {question}
**Improves:** {what it refines}

**Response:** _
```

## Chat message when the file is saved

With `question_style = "async"` (the default): "I have **N questions** — see `{session}/NN_questions.md`. Answer inline and let me know when ready."

With `question_style = "sync"`: ask the blocking questions directly in chat, and still save the file.
