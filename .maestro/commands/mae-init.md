# /mae-init — Initialize Maestro Framework

Initialize the Maestro delivery framework in the current project.

$ARGUMENTS — optional: project name, or `upgrade`

## Usage

```
/mae-init                    → interactive profile setup
/mae-init {project-name}     → set project name + profile setup
/mae-init upgrade            → migrate a pre-0.5.0 docs/ layout (see § Upgrade)
```

## Behavior

**Note:** Folder creation and file scaffolding are handled by `install.sh`. mae-init is for profile setup and project configuration.

1. Check if framework is already initialized (look for HANDOFF.md, maestro.toml)
   - If no: "Run the installer first (`install.sh`), then come back for profile setup."
   - If yes: proceed to profile setup

2. If no project name in `maestro.toml`, ask: "What's the project name?"

3. **Profile setup (conversational).**
   Ask: "Would you like to set up a profile? This helps Maestro tailor its assistance. (You can skip and add later.)"

   **Individual `[user]` section:**
   ```toml
   [user]
   description = "Senior Python architect, new to frontend"
   strengths = ["backend", "python", "system-design"]
   needs_help = ["frontend", "ux"]
   ```

   **Team `[[team.members]]` array:**
   Ask: "Who's on the team?" Then build the members list conversationally.
   ```toml
   [[team.members]]
   name = "Piotr"
   role = "architect"
   strengths = ["backend", "python", "system-design"]
   needs_help = ["frontend"]

   [[team.members]]
   name = "Anna"
   role = "frontend-developer"
   strengths = ["react", "css", "ux"]
   needs_help = ["backend", "databases"]
   ```

   When `[[team.members]]` is defined, team behaviors activate automatically (e.g., "Who" column in WORKLOG.md, agent asks "Who am I working with?" at session start).

   If skipped, omit the section entirely. The framework works without it — all commands behave generically.

4. Save report to session folder

## Upgrade

Migrates a pre-0.5.0 `docs/` layout. The installer never moves user docs; this does, because rewriting links needs judgement.

1. **Detect** old folders with files: `02-requirements/`, `02-poc/`, `03-design/`, `04-plan/`, `05-implementation/` … `09-maintenance/`. None → "Layout is current." Stop.
2. **Show the plan** before touching anything:
   - Moves (`git mv`, per file): `02-requirements/*`, `02-poc/*` → `02-specs/`; `03-design/DESIGN.md` → `02-specs/ARCHITECTURE.md`, the rest of `03-design/` → `02-specs/`; `04-plan/` → `03-plan/`; `05-`…`09-` → `04-`…`08-`
   - Link rewrites: every old path in tracked Markdown outside `.sessions/` (docs, HANDOFF.md, CLAUDE.md, task files, README), and `DESIGN.md` → `ARCHITECTURE.md` where it means architecture. Listed per file with counts
   - Conflicts: a target file already exists (empty folders from the installer are fine) → list them and stop
3. **Ask:** "Apply? (yes / no)". Nothing moves without yes.
4. **Apply:** unrelated uncommitted changes → offer to stash or stop. Run moves and rewrites, remove old folders left empty (pre-0.5.0 installs created all of them), then one commit: `chore(maestro): upgrade docs layout to v0.5.0`. Never push.
5. **Report:** files moved, links rewritten, commit hash, and one line: "`/mae-design` (`mds`) now means visual design; architecture is `/mae-architecture` (`mar`)."

## What init does NOT do
- Create folder structure (that's `install.sh` — creates docs/01-explore/, 02-specs/, 03-plan/)
- Create tracking files (that's `install.sh`)
- Set up source code structure (that's a `/mae-do` task after `/mae-architecture`)
- Choose tech stack (that's `/mae-explore` and `/mae-architecture`)
- Create or modify CLAUDE.md (user's responsibility)

## Output
Report: profile configured (or skipped), suggested next step (`/mae-explore`)
