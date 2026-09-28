# Work Log

| Date | Session | Summary |
|------|---------|---------|
| 2026-04-20 | 001-framework-bootstrap | Created Maestro framework: commands, templates, install.sh, README, sessions-first workflow |
| 2026-04-22 | 002-command-evolution | Rewrote explore command (readiness signals, ask sub-command), updated PRD/design commands, added user profiles, dropped 5 utility commands |
| 2026-05-20 | 003-framework-evolution | Multi-tool support (Cursor, Codex adapters), setup wizard, output tiers, .gitignore |
| 2026-06-09 | 005-review | Analyzed Codex review, reconciled roadmaps (005 vs 009), created PRD/SDD/ROADMAP, decided session visibility model, PoC flag approach, versioning |
| 2026-06-10 | 005-review | Tagged v0.1.0. Implementing Milestone 1: .sessions/ standardization, session visibility, tracking files, installer rework |
| 2026-07-11 | 014-competition | OpenSpec competitive analysis: coverage comparison, living-spec mechanic explainer, "Why Maestro" pitch doc. Proposed positioning: complement/superset of OpenSpec |
| 2026-07-11 | 015-skills | Skill-first architecture analysis (Agent Skills open standard, two-tier invocation model); self-contained competitive roadmap plan draft (02-skill-spec-plan.md) for chat handoff |
| 2026-08-03 | 018-reconciliation | v0.4.0 released: PoC track (`/mae-poc`, `docs/00-reference/`) merged and tagged; roadmap renumbered (PoC M07→M03, skills M03→M04); README rewritten; skills forensics confirmed no SKILL.md was ever written |
| 2026-08-21 | 22-new-scope | Developer critique scoped into roadmap: new v0.4.2 patch (P42.01–06) sequenced before the skill conversion; M04 +4 items (incl. `/mae-help`), M05 +6 items (canonical consolidation, `/mae-mock`, chaining, naming decision gate); D25–D33 recorded; two record corrections (empty m03 branch, `/mae-poc` scope) |
| 2026-09-17 | 017-skill-spike | M04.01: `mae-explore` as SKILL.md (canonical `.maestro/skills/`, symlinks for Claude Code/Cursor/Codex, validator-clean, trigger-eval kit) — blocked on keyboard test; M04.02: `.maestro/skills/CONVENTIONS.md` (tiers, state table, description pattern, frontmatter, checklist); Q8 added |
| 2026-09-19 | 018-framework-review | Adversarial review of MAESTRO.md, 13 commands, 11 templates, D22–D33: 40 findings, 4 blockers, three fix-first items queued into the Opus tier |
| 2026-09-19 | 019-m04-m05-commands | Built `/mae-help` (M04.15, state probe shared with `/status`), `/mae-run` + `/mae-yolo` (M05.11), `/mae-scope` + `msc` (M05.07), Mermaid dependency graph in `/mae-plan` + `/status --graph` (M04.18); one commit per task; M04.17 held on Q7 |
| 2026-09-27 | 22-new-scope | v0.5.0 on `release/v0.5.0` (alpha.0–4, rc.1): `02-specs`/`03-plan` layout, `/mae-specs` + requirements/design/architecture, five skills, `/mae-mock`, `/mae-idea`, `/mae-pr`, `[git]` policy, `response_capture`, installer fixes + clean-install test, docs |
| 2026-09-28 | 025-v05-review | rc.2 hotfix after the Codex review, reconciled in maestro-hq 025/03: offline install check (clone/download parity, pointers, fail-closed, no-Git, AGENTS.md merge, v0.4.0 upgrade); installer fails closed, same Cursor rules in both modes, AGENTS.md for Codex, no-Git → commit never; chains obey `[git]` and keep/undo their `docs/` writes; untrusted-content rule; DECISIONS.md read path; docs pass; D46–D50 |
