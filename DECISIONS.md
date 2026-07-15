# Decision Log

| # | Date | Session | Decision | Status |
|---|------|---------|----------|--------|
| D1 | 2026-04-20 | 001 | Framework name: Maestro (`mae-` prefix) | confirmed |
| D2 | 2026-04-20 | 001 | Config format: TOML (`maestro.toml`) | confirmed |
| D3 | 2026-04-20 | 001 | Artifact flow: sessions-first, promote to docs/ | confirmed |
| D4 | 2026-04-20 | 001 | Command naming: dashes (`/mae-explore`), flat files | confirmed |
| D5 | 2026-04-22 | 002 | Explore behavior: adaptive + readiness signals | confirmed |
| D6 | 2026-04-22 | 002 | User profile: `[user]` / `[[team.members]]` in maestro.toml | confirmed |
| D7 | 2026-04-22 | 002 | Utility commands reduced to 4: decide, sync, status, md | confirmed |
| D8 | 2026-05-20 | 003 | Multi-tool support: `.maestro/commands/` as source of truth | confirmed |
| D9 | 2026-05-20 | 003 | Output tiers: standard (default), verbose (-v), caveman (-c) | confirmed |
| D10 | 2026-06-10 | 005 | Session visibility replaces solo/team mode | confirmed |
| D11 | 2026-06-10 | 005 | `.sessions/` as canonical folder name (not `sessions/`) | confirmed |
| D12 | 2026-06-10 | 005 | PoC as flag on existing commands, not separate command | confirmed |
| D13 | 2026-06-10 | 005 | Installer: one question (visibility), always full structure | confirmed |
| D14 | 2026-06-10 | 005 | Versioning starts at v0.1.0 (semver, alpha) | confirmed |
| D15 | 2026-06-10 | 005 | mae-init becomes profile-only (installer handles scaffolding) | confirmed |
| D16 | 2026-06-10 | 005 | Roadmap = strategic (no checkboxes); Plan = tactical (checkboxes) | confirmed |
| D17 | 2026-07-11 | 015 | Skill-first architecture: canonical logic as SKILL.md (Agent Skills standard), commands as thin aliases, two-tier invocation (auto/suggest/explicit) | confirmed 2026-07-13 |
| D18 | 2026-07-11 | 014 | Positioning vs OpenSpec: complement/superset + interop, not head-on competitor | confirmed 2026-07-13 |
| D19 | 2026-07-11 | 014 | Adopt ADDED/MODIFIED/REMOVED delta format for canonical doc updates | confirmed 2026-07-13 |
| D20 | 2026-07-11 | 014 | /sync becomes the archive/merge step — living-doc lifecycle for docs/ | confirmed 2026-07-13 |
| D21 | 2026-07-11 | 015 | Capability-sharded canonical docs — requirements AND design split by capability when size warrants | confirmed 2026-07-14 |
| D22 | 2026-07-14 | 015 | Artifact-first capture: commands generate files (per each command's definition — may be several); user queries stay in chat; extensive chat answers → agent asks before saving; /md saves on demand | confirmed |
| D23 | 2026-07-14 | 015 | Unified task IDs: `M{MM}.{NN}` identical in ROADMAP # column, task filename (`M{MM}.{NN}-{slug}.md`), and task title; zero-padded; sub-tasks `M{MM}.{NN}a` | confirmed |
