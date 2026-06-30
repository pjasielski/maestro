# REQUIREMENTS: Maestro — AI-Assisted Project Delivery Framework

**Date:** 2026-06-18
**Version:** v0.2.0
**Status:** Draft — reconciled
**Explore report:** .sessions/003-framework-evolution/, .sessions/005-review/
**Changes from v0.1:** Renamed from PRD.md. Activity-based command names (mae-req, mae-design). REQUIREMENTS.md/DESIGN.md as universal artifact names. Session 010 consolidation decisions.

---

## 1. Problem Statement

### 1.1 Background

AI coding tools (Claude Code, Cursor, Codex, Copilot) have transformed how software gets written, but they operate at the code level. The broader delivery lifecycle — requirements gathering, architecture design, planning, decision tracking, review — remains ad-hoc. Developers using AI assistants have no structured way to maintain project context across sessions, track decisions, or produce consistent delivery artifacts.

Existing delivery frameworks (SAFe, Scrum tooling) are heavyweight, designed for large teams, and built around traditional PM workflows. They don't leverage AI capabilities and add overhead that solo developers and small teams can't justify.

### 1.2 Problem

Technical professionals working with AI tools experience:

- **Context loss** between sessions — the AI starts fresh each conversation, losing architectural decisions and project state
- **Inconsistent outputs** — no standardized artifact format means each session produces different quality
- **No decision trail** — decisions made during AI conversations are lost unless manually documented
- **Tool lock-in** — workflows built for one AI tool don't transfer to others
- **Missing lifecycle coverage** — AI tools help with coding but not with the explore→design→plan→review pipeline that precedes and follows it

### 1.3 Evidence

- The framework prototype has been used across multiple real projects (including a declarative LangGraph implementation where it drove the full explore→PRD→SDD→plan→do pipeline)
- Review session 005 confirmed core architecture is sound (7.5/10 delivery effectiveness score), with gaps primarily in operational discipline and post-implementation state management
- Users of AI coding tools routinely report losing context and redoing work across sessions (common pattern in Claude Code community)

---

## 2. Users & Personas

| Persona | Description | Goals | Pain Points | Usage Frequency |
|---|---|---|---|---|
| Solo Developer | Developer building projects with AI assistance | Maintain project context, produce consistent artifacts, track decisions | Context loss across sessions, ad-hoc workflows, no audit trail | Daily |
| Architect | Solutions/enterprise architect designing and overseeing delivery | Structured exploration, traceable design decisions, clear handoff artifacts | Design rationale lost in chat history, inconsistent documentation quality | Daily–Weekly |
| Product Manager | PM managing requirements and tracking progress | Lightweight task management, requirements formalization, status visibility | Heavy tools (Jira) or no tools at all, disconnected from dev workflow | Daily |
| Team Lead | Lead coordinating a small team's delivery | Shared decision trail, consistent artifacts, session handoffs between members | No shared context for AI-assisted work, each person's sessions are siloed | Weekly |

**Primary user:** Solo Developer / Architect (broadest audience, most immediate value)

---

## 3. Goals & Success Criteria

### 3.1 Business Goals

| # | Goal | Metric | Target | How to Measure |
|---|---|---|---|---|
| 1 | Establish Maestro as a usable open-source delivery framework | GitHub stars + forks | 200 stars within 6 months of public release | GitHub metrics |
| 2 | Support real project delivery end-to-end | Projects completed using full lifecycle | 3+ projects (including Maestro itself) | Case studies, dogfooding |
| 3 | Work across multiple AI tools | Tools with verified support | Claude Code + Cursor + Codex | Tested adapter matrix |
| 4 | Enable non-technical users to participate in delivery | PM-friendly commands working | `/status`, `/mae-explore ask`, task management usable by PMs | User testing |

### 3.2 User Goals

| Persona | Goal | How We'll Know It's Met |
|---|---|---|
| Solo Developer | Never lose context between AI sessions | HANDOFF.md + session summaries restore full context in < 1 min |
| Architect | Produce client-quality delivery artifacts | PRD/SDD/explore outputs used in real client engagements without rework |
| Product Manager | Track project progress without heavy tooling | `/status` provides immediate visibility; tasks manageable via markdown |
| Team Lead | Share AI-assisted work across team members | Session visibility configured for team; synced HANDOFF.md enables seamless handoffs |

---

## 4. Requirements

### 4.1 Functional Requirements

| ID | Requirement | Priority | Acceptance Criteria |
|---|---|---|---|
| FR-01 | Provide 8 delivery commands covering explore→PRD→design→plan→do→review→checkpoint→init | Must | All commands produce structured artifacts following templates |
| FR-02 | Provide 4 utility commands (decide, sync, status, md) for project management | Must | Decision tracking, state sync, status overview, and file saving work reliably |
| FR-03 | Maintain project context via HANDOFF.md as single source of truth | Must | New sessions restore full context by reading HANDOFF.md + session summary |
| FR-04 | Sessions-first artifact flow with promotion to docs/ | Must | All command output goes to .sessions/; promotion to docs/ requires user confirmation |
| FR-05 | Decision pipeline: ideas → open questions → decisions → canonical files | Must | Full audit trail from initial idea to implemented decision |
| FR-06 | Task management via markdown files in docs/04-plan/tasks/ | Must | Tasks have statuses (todo/in-progress/done/blocked), are created by /mae-plan |
| FR-07 | Session visibility configuration (committed or gitignored) with team support via `[[team.members]]` | Must | Session visibility set in maestro.toml; team behavior (WORKLOG "who" column, /sync required) inferred from team members being defined |
| FR-08 | Install via curl pipe bash with simplified setup (one question: session visibility) | Must | Fresh install creates complete framework scaffold with all tool adapters; re-install is non-destructive for user files |
| FR-09 | Support multiple AI tools via adapter pattern (all adapters installed by default) | Should | Claude Code, Cursor, and Codex adapters installed automatically; unused adapters are inert |
| FR-10 | User/team profile in maestro.toml, set up conversationally via mae-init | Should | Agent asks natural questions and generates TOML profile; non-technical users never edit TOML directly |
| FR-11 | Output tiers (standard / -v verbose / -c caveman) for all commands | Should | Each command respects tier flags, producing appropriate output density |
| FR-12 | Template system for all delivery artifacts (PRD, SDD, explore, task, roadmap, etc.) | Must | Templates are customizable, ship with core + optional section pattern |
| FR-13 | Auto-save substantive responses to numbered session files | Must | Every proposal/analysis/draft saved as NN_description.md in session folder |
| FR-14 | Consistency flags (CONSISTENCY, GAP, UNCLEAR, STALE, DRIFT) | Should | Agent automatically flags contradictions between artifacts |
| FR-15 | PoC workflow via `poc` flag on existing commands | Should | All delivery commands accept `poc` flag; PoC artifacts use separate files (PRD-poc.md), archived to docs/poc/ when production versions replace them |
| FR-16 | Browser-based setup wizard for non-technical users | Nice | setup/index.html generates install command from user selections |
| FR-17 | Integration with ai-deck presentation framework | Should | /mae-deck command delegates to ai-deck for presentation generation |

### 4.2 Non-Functional Requirements

| ID | Category | Requirement | Target |
|---|---|---|---|
| NFR-01 | Portability | Framework is plain markdown + TOML — no runtime dependencies | Works in any directory with any AI tool that reads markdown |
| NFR-02 | Context budget | Reference material per task stays within budget | 4,000–8,000 words loaded per command invocation |
| NFR-03 | File sizes | Delivery artifacts stay within defined limits | PRD: 1,500–3,000 words; SDD: 2,000–4,000 words; Tasks: 200–500 words |
| NFR-04 | Install time | Fresh installation completes quickly | < 30 seconds for curl pipe bash |
| NFR-05 | Tool neutrality | Framework instructions (MAESTRO.md) contain no tool-specific language | MAESTRO.md is tool-agnostic; tool-specific code lives in adapters only |
| NFR-06 | Git friendliness | All artifacts are plain text, diffable, and merge-friendly | No binary files in docs/ or .sessions/ |

---

## 5. Scope

### 5.1 In Scope (v0.1.0–v0.5.0)

- 8 delivery commands + 4 utility commands (all as markdown files)
- Sessions-first artifact flow with docs/ promotion (`.sessions/` canonical)
- HANDOFF.md / DECISIONS.md / OPEN_QUESTIONS.md / WORKLOG.md tracking system
- maestro.toml configuration (session_visibility, user/team profile)
- Template system (PRD, SDD, explore, task, summary, report, review, issue, roadmap)
- install.sh with simplified setup + curl pipe bash support (all tool adapters by default)
- Browser-based setup wizard (static HTML)
- Claude Code native support + Cursor/Codex adapters (all installed automatically)
- Output tiers (standard, verbose, caveman)
- PoC flag on all delivery commands with separate artifact files
- Implementation reports in docs/05-implementation/
- ai-deck integration via /mae-deck wrapper command
- Documentation (README, user guide, tool capability matrix)

### 5.2 Out of Scope (Future)

- **Python CLI** (`uvx maestro init`) — replaces install.sh for package-managed installation
- **Maestro UI app** — desktop/web UI with agent integration, lightweight IDE + project management
- **GitHub Pages hosting** — maestro.tools/setup for the wizard
- **Plugin system** — third-party command packages
- **AI provider abstraction** — Maestro delegates to whichever AI tool the user has
- **Automated CI/CD integration** — testing framework commands in CI
- **Real-time collaboration** — multiple users editing simultaneously
- **Interactive artifacts** — JSON → HTML form conversion for question filling

### 5.3 Assumptions

- Users have at least one AI coding tool installed (Claude Code, Cursor, Codex, or Copilot)
- Users are comfortable with command-line workflows for v1 (non-CLI users are a future persona)
- Git is the version control system (framework conventions assume git)
- Projects are file-based (not database-driven content management)

### 5.4 Dependencies

| # | Dependency | Owner | Needed By | Risk if Late |
|---|---|---|---|---|
| 1 | ai-deck framework (separate repo) | Piotr | Before /mae-deck command | Maestro works without it; presentation feature delayed |
| 2 | AI tool adapter testing (Cursor, Codex) | Piotr | Before multi-tool claim in docs | Can ship Claude Code-first, add others incrementally |
| 3 | Real-project validation beyond bootstrap | Piotr | Before v1.0 public release | Framework risks being untested outside its own domain |

---

## 6. Epics & User Stories

### Epic 1: Core Delivery Pipeline
**Description:** The 8 delivery commands that drive the explore→PRD→design→plan→do→review lifecycle.
**Priority:** 1

| Story ID | User Story | Acceptance Criteria | Priority |
|---|---|---|---|
| US-1.1 | As a developer, I want to run /mae-explore to analyze documents and build understanding so that I don't start designing with incomplete knowledge | Explore command produces structured analysis with questions, gaps, and readiness assessment | Must |
| US-1.2 | As a developer, I want /mae-req to generate a requirements document from explore artifacts so that requirements are formalized and traceable | PRD follows template, references explore findings, flags ambiguities | Must |
| US-1.3 | As an architect, I want /mae-design to produce an SDD with a technical questionnaire so that design decisions are explicit and reasoned | SDD covers architecture, tech stack, data model, source structure; questionnaire surfaces decisions needing human input | Must |
| US-1.4 | As a developer, I want /mae-plan to break the SDD into task files so that I have actionable work items | Task files created in docs/04-plan/tasks/ with statuses, effort estimates, and dependency info | Must |
| US-1.5 | As a developer, I want /mae-do to execute tasks (planned or ad-hoc) so that I can implement with AI assistance while maintaining traceability | Execution reports saved to session; task status updated on completion | Must |
| US-1.6 | As a lead, I want /mae-review to evaluate code or artifacts against the SDD/PRD so that quality is maintained | Review produces severity-sorted findings with concrete fix suggestions | Must |

### Epic 2: Project State Management
**Description:** The tracking system that maintains project context across sessions.
**Priority:** 1

| Story ID | User Story | Acceptance Criteria | Priority |
|---|---|---|---|
| US-2.1 | As a developer, I want HANDOFF.md to always reflect current project state so that any session can start with full context | HANDOFF.md updated via /sync with review; contains status, decisions, architecture, priorities | Must |
| US-2.2 | As a team lead, I want DECISIONS.md to maintain a complete audit trail so that we can trace why any decision was made | Every /decide appends date, session, decision, and status; never deletes | Must |
| US-2.3 | As a developer, I want /status to show project overview, tasks, decisions, and open questions so that I have instant visibility | Status command with sub-commands (tasks, decisions, questions) produces formatted overview | Must |
| US-2.4 | As a developer, I want session summaries auto-updated so that returning to a session doesn't require reading every file | _summary.md updated on decisions confirmed, questions identified, files created, task status changes | Should |

### Epic 3: Multi-Tool Support
**Description:** Framework works across AI coding tools, not just Claude Code.
**Priority:** 2

| Story ID | User Story | Acceptance Criteria | Priority |
|---|---|---|---|
| US-3.1 | As a Cursor user, I want Maestro commands available in Cursor so that I get the same delivery workflow | Cursor rules files (.cursor/rules/) generated by installer; commands work via Cursor's interface | Should |
| US-3.2 | As a Codex user, I want Maestro to work with Codex so that I can use my preferred tool | Codex adapter documented and tested; known limitations listed | Should |
| US-3.3 | As a framework user, I want a capability matrix documenting what works in each tool so that I can set expectations | docs/tool-support.md lists command x tool support levels | Should |

### Epic 4: Installation & Onboarding
**Description:** Getting Maestro installed and running in a project.
**Priority:** 1

| Story ID | User Story | Acceptance Criteria | Priority |
|---|---|---|---|
| US-4.1 | As a developer, I want to install Maestro with a single curl command so that setup is frictionless | `curl ... \| bash` creates full framework scaffold; one question (session visibility); all tool adapters installed automatically | Must |
| US-4.2 | As a developer, I want re-running the installer to be safe so that I can update without losing my work | Re-install never overwrites user-customized files (HANDOFF.md, maestro.toml, templates/); framework files update to latest | Must |
| US-4.3 | As a non-technical user, I want a browser-based setup wizard so that I can configure Maestro without memorizing command flags | setup/index.html generates a preconfigured install command | Nice |
| US-4.4 | As a developer, I want /mae-init to set up my profile conversationally so that the agent adapts to my expertise without me editing TOML | Init asks natural questions ("What's your role?", "What are you good at?") and generates maestro.toml profile sections | Must |

### Epic 5: ai-deck Integration
**Description:** Presentation generation capability integrated into Maestro via the ai-deck framework.
**Priority:** 2

| Story ID | User Story | Acceptance Criteria | Priority |
|---|---|---|---|
| US-5.1 | As a developer, I want /mae-deck to generate presentations from project artifacts so that I can produce client-ready decks from my delivery work | /mae-deck command delegates to ai-deck framework; works with Maestro sessions and delivery artifacts | Should |
| US-5.2 | As a Maestro user, I want ai-deck installed automatically with Maestro so that presentation generation works without additional setup | install.sh copies ai-deck assets to ~/.maestro/ai-deck/ during installation | Should |
| US-5.3 | As a developer, I want ai-deck to work without Python (pure agentic fallback) so that all users can generate presentations | If Python is not available, AI tool assembles HTML directly from templates and components | Should |

### Epic 6: PoC Workflow
**Description:** Support for iterative, prototype-driven development using the existing command set.
**Priority:** 2

| Story ID | User Story | Acceptance Criteria | Priority |
|---|---|---|---|
| US-6.1 | As a developer, I want to add `poc` to any delivery command so that I get a lighter, prototype-focused version of the artifact | All delivery commands accept `poc` flag; output includes PoC banner, limitations section, and production delta section | Should |
| US-6.2 | As a developer, I want PoC artifacts stored as separate files so that they can coexist with production artifacts during transition | PoC artifacts named `REQUIREMENTS-poc.md`, `SDD-poc.md`, etc.; archived to `docs/poc/` when production versions are ready | Should |
| US-6.3 | As a developer, I want production commands to use my PoC artifact as a starting point so that I don't redo work | Running `/mae-req` when `REQUIREMENTS-poc.md` exists reads the PoC version and expands it | Should |

---

## 7. Risks

| # | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| 1 | Installer overwrites user customizations on re-install | H (confirmed bug) | H | Fix cp → create_if_missing for templates; framework files update by default with clear messaging |
| 2 | Partial installs fail silently in curl mode | H (confirmed bug) | H | Remove \|\| true from downloads; validate file set post-download |
| 3 | Tool-agnostic claim not fully validated | M | M | Create capability matrix; test adapters systematically; document known gaps |
| 4 | Context loss in long-running projects despite tracking system | M | H | Strengthen HANDOFF.md auto-update; add rolling project digest |
| 5 | Framework feels too sequential for iterative/PoC work | M | M | PoC flag on all commands; document alternative pathways prominently |
| 6 | ai-deck integration adds complexity to Maestro installation | L | M | ai-deck is optional; /mae-deck gracefully reports if not installed |
| 7 | Bootstrap dogfooding masks gaps visible to new users | M | M | Test on 2-3 external projects before v1.0 claim |

---

## 8. Constraints

| Type | Constraint | Impact on Solution |
|---|---|---|
| Technical | No runtime dependencies — framework is pure markdown + TOML | Cannot build sophisticated state management; relies on AI tool compliance |
| Technical | Must work via curl pipe bash installation | No pip or npm for the framework itself (ai-deck may use pip separately) |
| Design | AI tool compliance is probabilistic, not guaranteed | Commands are instructions, not code; output quality varies by model |
| Scope | Bootstrap project — framework building itself | Must balance self-documentation with shipping usable features |

---

## 9. Release Strategy

**MVP definition:** All 12 commands working, installer safe and idempotent, Claude Code fully supported, documentation complete.

**Phasing:**

- **v0.1.0 (current):** Alpha — core commands working, installer functional but with known bugs, Claude Code primary support.
- **v0.2.0:** Foundation fixes — installer rework, .sessions/ standardization, session visibility model, versioning setup.
- **v0.3.0:** PoC workflow — `poc` flag on all commands, implementation reports folder, context loading strictness, post-do sync.
- **v0.4.0:** Documentation & onboarding — mae-init profile rework, capability matrix, README update, user guide. ai-deck Phase 1 integration.
- **v0.5.0:** PM features — task metadata expansion, status filters, rolling project digest. ai-deck Phase 2.
- **v1.0:** Public release — all the above validated on 3+ projects, documentation polished, known limitations documented.

**Post-v1.0:**
- Python CLI (`uvx maestro init`)
- Maestro UI app (desktop/web)
- Plugin ecosystem
- Interactive artifacts (JSON → HTML forms)

**Acceptance testing:** Dogfooding on this repo + validation on 2 external projects (diverse stacks and team sizes).

---

## Appendix: Glossary

| Term | Definition |
|---|---|
| Session | A working folder (.sessions/NNN-name/) containing artifacts for one work period; material is promoted to docs/ when confirmed |
| Delivery folder | Canonical artifact storage (docs/01-explore/ through docs/09-maintenance/) — only confirmed, reviewed content lives here |
| Promotion | Moving a draft artifact from .sessions/ to docs/ after user review |
| Artifact flow | The pipeline: .sessions/ (workbench) → docs/ (confirmed) |
| HANDOFF.md | Single source of truth for project status, decisions, architecture — read at the start of every session |
| Adapter | A thin wrapper file that translates Maestro's tool-neutral commands into a specific AI tool's format |
| Output tier | Density level for command output: standard (default), verbose (-v), caveman (-c) |
| Session visibility | Whether session folders are committed to git (private projects) or gitignored (open-source / team projects) |
| PoC flag | Modifier (`poc`) added to delivery commands for lighter, prototype-focused artifacts |
| ai-deck | Presentation framework (separate repo) integrated into Maestro via /mae-deck |

---

**Notes:**
- This PRD describes the Maestro framework itself — a bootstrap situation where the framework documents its own requirements
- Review findings from session 005 (installer bugs, tool-agnostic gaps) are incorporated as risks and requirements
- Session 005 decisions override session 009 where they conflict (versioning, PoC approach, mode model, installer scope)
- ai-deck was previously called "Presently" during exploration; "ai-deck" is the repository/framework name
