# Installing Maestro

Maestro is a set of files that live inside your project. Installing means copying those files in. There is nothing to buy, no account to create, and nothing to configure on a server.

---

## Before You Start

You need:
- A project folder (any folder where your project lives)
- One of these AI tools: **Claude Code**, **Cursor**, **Copilot**, or **Codex**
- A terminal (Mac: Terminal app or iTerm; Windows: Command Prompt or PowerShell)

---

## Choose Your Path

| I am… | Best option |
|-------|-------------|
| Anyone with a terminal (recommended) | [Option A — One-Line Install](#option-a--one-line-install) |
| Installing an unreleased branch or a tag | [Installing from a branch or tag](#installing-from-a-branch-or-tag) |
| A developer who wants full control | [Option B — Manual Install](#option-b--manual-install) |
| Not comfortable with terminals | [Option C — Browser Setup Wizard](#option-c--browser-setup-wizard-frozen) (frozen) |

---

## Option A — One-Line Install

Recommended.

### Step 1 — Navigate to your project

```bash
cd /path/to/your-project
```

### Step 2 — Run the installer

```bash
curl -fsSL https://raw.githubusercontent.com/pjasielski/maestro/main/install.sh | bash
```

The installer asks five questions (session visibility, AI tools, question style, when to commit, which responses to save as files). Answer each and press Enter.

**Skip the questions (use defaults):**

```bash
curl -fsSL https://raw.githubusercontent.com/pjasielski/maestro/main/install.sh | bash -s -- . --quick
```

Defaults: all adapters, sessions committed, async questions, commit per task (never push), files for work products only.

**Force reinstall (overwrite all framework files):**

```bash
curl -fsSL https://raw.githubusercontent.com/pjasielski/maestro/main/install.sh | bash -s -- . --force
```

Replaces MAESTRO.md, commands, templates, and adapters. Project files (HANDOFF.md, DECISIONS.md, CLAUDE.md) are preserved; `maestro.toml` keeps every existing key and gains keys added since your install. Without `--force`, customised templates are also kept.

**Upgrading from before v0.5.0:** the installer never moves your docs. It prints `Old layout found` when `docs/02-requirements/`, `02-poc/`, `03-design/` or `04-plan/` hold files; then run `/mae-init upgrade` in your agent, which shows the moves and link rewrites and commits once after you confirm.

### Step 3 — Follow the printed instructions

The installer prints tool-specific next steps when it finishes.

---

## Installing from a branch or tag

`main` is the released version. Any branch or tag installs the same way: `release/v0.5.0` and `dev` carry the next version before it's released; a tag such as `v0.5.0-rc.1` never moves, which makes it the safest pick for real work.

**New project** — from the project folder:

```bash
MAESTRO_BRANCH=release/v0.5.0 bash -c 'curl -fsSL "https://raw.githubusercontent.com/pjasielski/maestro/$MAESTRO_BRANCH/install.sh" | bash'
```

Add `-s -- . --quick` after the last `bash` (inside the quotes) to skip the questions.

**Existing Maestro project** (refreshes framework files; keeps `HANDOFF.md`, `DECISIONS.md`, `OPEN_QUESTIONS.md`, `WORKLOG.md`, `CLAUDE.md` and every existing `maestro.toml` key, and adds new keys):

```bash
MAESTRO_BRANCH=release/v0.5.0 bash -c 'curl -fsSL "https://raw.githubusercontent.com/pjasielski/maestro/$MAESTRO_BRANCH/install.sh" | bash -s -- . --force'
```

`MAESTRO_BRANCH` is used twice: in the URL it picks which installer runs; as a variable it picks which files that installer downloads. Swap in any branch or tag.

**Going back** (roll back): run the same command with the previous tag, or with `MAESTRO_BRANCH=main` for the release.

**Right after a push**, GitHub's raw CDN can serve the previous version for a few minutes. If a new command is missing, wait and re-run.

**Check it worked:** open your AI tool in the project and run `/mae-help`. If it answers with the project's state and a suggested next command, the install is good.

---

## Option B — Manual Install

For developers who want to inspect or customise the files before installing.

```bash
git clone https://github.com/pjasielski/maestro.git /tmp/maestro
/tmp/maestro/install.sh /path/to/your-project
```

Or install into the current directory:

```bash
git clone https://github.com/pjasielski/maestro.git /tmp/maestro
/tmp/maestro/install.sh .
```

### Customising after install

| File | What to edit |
|------|-------------|
| `CLAUDE.md` | Project description, stack, current phase |
| `maestro.toml` | Session visibility, AI tools, question style, user profile |
| `.maestro/templates/` | Document templates to match your team's standards |

---

## Option C — Browser Setup Wizard (frozen)

> **Frozen at v0.4.0.** The wizard still works, but it does not ask the newer questions (when to commit, which responses to save). The installer fills those with defaults (`commit = "task"`, `response_capture = "artifacts"`); change them in `maestro.toml`. Prefer Option A.

Opens a form in your web browser — no terminal required.

### Step 1 — Download the setup wizard

Download this file: [setup/index.html](https://raw.githubusercontent.com/pjasielski/maestro/main/setup/index.html)

(Right-click the link → Save As → save anywhere on your computer.)

### Step 2 — Open it in your browser

Double-click the downloaded `index.html` file. A setup form will open.

### Step 3 — Fill in the form

The form asks:

1. **Session visibility** — Committed (saved in git) or Gitignored (personal working material)?
2. **AI tool** — which tool(s) will you use? You can pick more than one.
3. **Question style** — Should the agent ask questions in file (async) or in chat (sync)?

Click **Generate Setup Script** when done.

### Step 4 — Run the downloaded script

The wizard downloads a `maestro-setup.sh` script. Open a terminal, navigate to your project folder, then run it:

```bash
cd /path/to/your-project
bash ~/Downloads/maestro-setup.sh
```

Your browser will show a confirmation with tool-specific next steps.

---

## After Installing — First Steps

### Claude Code

1. Open a new Claude Code conversation in your project folder
2. Type `/mae-help` — it names the one command to run now (usually `/mae-explore`)

### Cursor

1. Open your project in Cursor
2. Open the AI chat panel (`Cmd+L` or `Ctrl+L`)
3. Type `/mae-explore`

> Cursor does not autocomplete `/mae-*` commands — type them in full.

### Copilot / Codex

1. Open your repo — it reads `.github/copilot-instructions.md` automatically
2. Type `/mae-explore`

---

## What Gets Installed

```
your-project/
├── MAESTRO.md                        ← Framework rules (read by your AI tool)
├── CLAUDE.md                         ← Your project config — edit this
├── maestro.toml                      ← Settings (sessions, tools, questions, [git], response_capture)
├── HANDOFF.md                        ← Project status — single source of truth
├── DECISIONS.md                      ← Decision log
├── OPEN_QUESTIONS.md                 ← Questions to resolve
├── WORKLOG.md                        ← Activity log
│
├── .maestro/skills/                  ← Skills the agent may offer (explore, specs, scope, idea, mock)
├── .maestro/commands/                ← Maestro command definitions
├── .claude/skills/, .claude/commands/ ← Claude Code integration (if selected)
├── .agents/skills/                   ← Skills for Cursor and Codex (if selected)
├── .cursor/rules/                    ← Cursor integration (if selected)
├── .github/copilot-instructions.md   ← Copilot/Codex integration (if selected)
│
├── docs/
│   ├── 00-reference/
│   ├── 01-explore/
│   ├── 02-specs/
│   ├── 03-plan/tasks/
│   └── 04-implementation/ … 08-maintenance/   (empty until needed)
│
├── .sessions/                        ← Working notes (gitignored or committed)
└── .maestro/templates/               ← Document templates
```

Maestro **never overwrites** your files (HANDOFF, DECISIONS, CLAUDE.md, `maestro.toml` keys, customised templates). Re-running the installer is safe; it refreshes framework files and appends new config keys.

---

## Team Setup

One person installs and commits. Others pull and configure their own tool.

**What to commit to git:**

```
✓  MAESTRO.md, CLAUDE.md, maestro.toml
✓  HANDOFF.md, DECISIONS.md, OPEN_QUESTIONS.md, WORKLOG.md
✓  docs/, .maestro/templates/
✓  .maestro/commands/, .claude/commands/, .cursor/rules/
✗  .sessions/  — personal working notes (when session_visibility = "gitignored")
```

The `.gitignore` created by the installer handles this automatically.

Each team member configures their own AI tool — see [Adding a Tool Later](#adding-a-tool-later).

---

## Adding a Tool Later

Re-run the installer (safe — skips existing files):

```bash
curl -fsSL https://raw.githubusercontent.com/pjasielski/maestro/main/install.sh | bash
```

Select the additional tool when prompted.

**Manual Cursor setup** (if you prefer not to re-run):

Create `.cursor/rules/maestro-core.mdc`:

```markdown
---
description: Maestro delivery framework rules
alwaysApply: true
---
Read MAESTRO.md at the project root for all framework behavior.
```

Create `.cursor/rules/maestro-dispatch.mdc`:

```markdown
---
description: Maestro command dispatcher
alwaysApply: true
---
When user types /mae-X in chat, read .maestro/commands/mae-X.md and follow its protocol.
Commands: mae-explore, mae-req, mae-design, mae-plan, mae-do, mae-review,
          mae-init, status, decide, sync, md
```

---

## Uninstalling

Maestro is just files. To remove it:

```bash
rm -rf .maestro/ .cursor/rules/maestro-*.mdc
rm -f MAESTRO.md maestro.toml HANDOFF.md DECISIONS.md OPEN_QUESTIONS.md WORKLOG.md
rm -rf docs/ .sessions/
rm -f .github/copilot-instructions.md
```

Keep `CLAUDE.md` if it contains your own project notes.

---

## Troubleshooting

**"Command not found: curl"**
Use [Option B — Manual Install](#option-b--manual-install).

**"Permission denied" when running install.sh**
```bash
chmod +x install.sh && ./install.sh
```

**Cursor doesn't respond to /mae-explore**
- Confirm `.cursor/rules/maestro-core.mdc` and `maestro-dispatch.mdc` exist
- Restart Cursor to reload rules
- Check your Cursor model — Claude or GPT-4o work best

**"Already initialized" message**
Maestro is already installed. Run `/mae-explore` in your AI tool to start.

**Missing files after install**
The installer skips files that already exist. Re-run to fill in anything missing — it is safe to run multiple times.
