# Maestro skill conventions

**Status:** v1, set by M04.02 (2026-09-17) from the M04.01 spike. Applies to every skill under `.maestro/skills/`. Validated against the Agent Skills specification (agentskills.io) and its reference validator.

## 1. Invocation tiers (D17)

Three tiers, one question each: what does a false positive cost?

| Tier | False positive costs | Frontmatter | Body section | Tool behaviour |
|---|---|---|---|---|
| **auto** | One announced line | No invocation field | `## Fit check (auto-invocation only)` | Model may invoke; user may type it |
| **suggest** | An unwanted document | No invocation field | `## Gate (auto-invocation only)` | Model may invoke, but the gate stops it at a one-line proposal |
| **explicit** | Executed work, commits, edited canonical files | `disable-model-invocation: true` | `## Guard` | Only the typed command runs it |

**Auto.** The fit check compares the request with the state table in §3. If the project is past the skill's phase, the skill says in one line what it is about to do and why, then continues. A one-step factual question is answered directly, without the protocol.

**Suggest.** The standard has no "propose first" mode, so the skill must stay model-invocable to be able to suggest itself. The gate carries the tier: when the model chose the skill, it writes nothing and says one line: "This looks like {phase} work. Want me to run `/{command}`? (yes / not now)". It proceeds only when the user typed the command or confirmed. The description ends with "Propose first; produce only after the user confirms."

**Explicit.** `disable-model-invocation: true` is honoured by Claude Code and Cursor. Codex ignores it and reads `{skill}/agents/openai.yaml` with `allow_implicit_invocation: false`; ship both. The body guard is the last line of defence: "If this skill was invoked without the user typing `/{command}`, stop and say so."

`UNCLEAR:` the reference validator rejects `disable-model-invocation` as a non-spec field (spike finding F2). Working default: keep it, because it is the only mechanism the tools offer; expect exactly one "Unexpected fields" line per explicit skill from `agentskills validate`, and have `maestro validate` (M06.01) whitelist it. Drop the exception the day the spec adds an invocation field.

## 2. Tier assignment

| Skill | Tier | Why |
|---|---|---|
| `mae-explore` | auto | Questions are cheap; fit check announces itself |
| `mae-review` | auto | Read-only; findings, no edits |
| `status` | auto | Read-only |
| `mae-help` (M04.15) | auto | Read-only; the "what next" question is the trigger |
| `mae-poc` | suggest | Writes `POC.md` straight to `docs/` |
| `mae-req` | suggest | An unwanted draft is the failure mode |
| `mae-design` | suggest | Same |
| `mae-plan` | suggest | Writes ROADMAP and tasks straight to `docs/` |
| `decide` | suggest | A wrongly recorded decision outlives the session |
| `mae-scope` (M05.07) | suggest | Edits canonical files under review |
| `mae-mock` (M05.09, gated on Q6) | suggest | Provisional |
| `mae-do` | explicit | Executes work and commits (D27) |
| `mae-run`, `mae-yolo` (M05.11) | explicit | Chain explicit commands |
| `mae-approve` (M04.17) | explicit | Acts on annotations |
| `sync` | explicit | Edits HANDOFF and ROADMAP |
| `mae-init` | explicit | Writes `maestro.toml` |
| `md` | explicit | User-only by definition |

The explore/review/status → req/design/plan/decide → do/sync/init split is D17. The rows for commands not yet built are provisional (`~`) and are confirmed by the task that builds each command. `mae-explore-lite` is not in the command table; `UNCLEAR:` whether it survives M04.03. Working default: fold it into `mae-explore` as a `lite` argument.

## 3. State table (auto-trigger heuristic)

The state probe and the state table live in `.maestro/commands/mae-help.md` (§ State probe, § State table) since M04.15 landed. They are not copied here. Fit checks (auto tier) compare the request with that table; suggest-tier gates use it the same way: if the request matches the expected next step, the proposal names it; if not, the proposal says which state the project is in. `/status`, `/mae-help`, and `/mae-yolo` all read the same probe.

## 4. Description pattern

Four parts, in this order, imperative voice, user intent rather than mechanics. Target 400–800 characters; the spec caps at 1,024 and Claude Code truncates at 1,536.

```
{What it produces, one clause}. Use when the user {intent 1}, {intent 2}, or {intent 3},
even if they never say "{keyword}". Also handles /{command}, {alias}[, "{sub-mode}"].
Do NOT use to {near-miss 1} ({adjacent-skill}), {near-miss 2} ({adjacent-skill}), or
{near-miss 3}. {What to do instead, one clause}.
```

Rules:
- Every "Do NOT" names the Maestro skill that should take the request, so the model routes instead of declining.
- Near-misses are the ones that share keywords: the strongest negatives, not random topics.
- The slash name and aliases appear in the description because Codex has no wrapper files; a typed `mex` has to match here.
- Suggest tier appends "Propose first; produce only after the user confirms." Explicit tier replaces the "Use when" part with "Runs only when the user types `/{command}`."
- Never fix a failing eval query by pasting its words in. Fix the category.

## 5. Frontmatter

Exactly these fields, in this order. Nothing else.

```yaml
---
name: mae-explore                 # equals the directory name; lowercase, digits, single hyphens; ≤64
description: >-                   # §4 pattern; ≤1024 characters
  …
license: MIT
compatibility: >-                 # fixed text for every Maestro skill; ≤500
  Requires a project initialized with Maestro (.maestro/, HANDOFF.md, .sessions/).
  Any Agent Skills client (Claude Code, Cursor, Codex CLI).
metadata:                         # string values only; quote numbers
  maestro-tier: auto | suggest | explicit
  maestro-command: /mae-explore
  maestro-aliases: mex            # comma-separated if several; omit if none
  maestro-version: "0.5.0"
disable-model-invocation: true    # explicit tier only
---
```

Never use: `allowed-tools` (a permission grant with tool-specific semantics), `model`, `effort`, `context`, `agent`, `hooks`, `paths`, `when_to_use`, `arguments`. Arguments come in through `$ARGUMENTS`. No shell injection (`` !`cmd` ``) in bodies; it is Claude-only.

## 6. Naming

- Skill `name` = directory name = command name without the slash: `mae-explore`, `sync`.
- Framework delivery skills carry the `mae-` prefix. Utility skills keep their D7 names for now; whether they get the prefix on conversion is Q8.
- Aliases (`mex`, `mrq`) are not skills. They stay thin wrappers in `.claude/commands/` and `.cursor/commands/`, and are listed in the description for tools without wrappers.
- One skill per behaviour. Variants are arguments, not sibling skills.

## 7. Body structure

`# {name} — {title}`, then the `$ARGUMENTS` line, then the tier section from §1, then in this order as needed: Modes, Read context first, Behaviour, After every artifact, Rules, Skip when, Artifact flow. Target under 150 lines; hard limit 500. Formats owned by the skill go to `references/` and are linked by relative path, one level deep. Shared templates stay in `.maestro/templates/` and are referenced by project path (they are also installed by `install.sh`); M04.03 may revisit. Keep behaviour identical to the command file being replaced; the conversion is packaging, not a rewrite (D25).

## 8. Placement

Canonical: `.maestro/skills/{name}/`. Tool paths point at it: `.claude/skills/{name}` for Claude Code, `.agents/skills/{name}` for Codex and Cursor (Cursor also reads `.claude/skills/`). The spike uses symlinks; the installer mechanism, including Windows, is M04.06. Never edit a tool copy.

## 9. Validation checklist (before committing a skill)

1. `uvx --from skills-ref agentskills validate .maestro/skills/{name}` passes, or fails only on `disable-model-invocation` for an explicit skill.
2. `name` equals the directory; description ≤1,024 characters; body under 500 lines.
3. `docs/06-test/skill-trigger-eval/{name}.queries.json` exists with 8–10 should-trigger and 8–10 near-miss should-not queries.
4. Auto and suggest tiers: `trigger-eval.sh` passes (rate > 0.5 for should, < 0.5 for should-not, 3 runs).
5. Suggest tier: an auto-invocation produces the one-line proposal and no file.
6. Explicit tier: a should-trigger query produces no skill call.
7. The old command file and wrappers are removed in the same commit only after M04.03's clash test (spike F6) says they collide.
