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
| Not comfortable with terminals | [Option A — Browser Setup Wizard](#option-a--browser-setup-wizard) |
| Comfortable with a terminal | [Option B — One-Line Install](#option-b--one-line-install) |
| A developer who wants full control | [Option C — Manual Install](#option-c--manual-install) |

---

## Option A — Browser Setup Wizard

The easiest option. Opens a form in your web browser — no terminal required.

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

## Option B — One-Line Install

For people comfortable with a terminal.

### Step 1 — Navigate to your project

```bash
cd /path/to/your-project
```

### Step 2 — Run the installer

```bash
curl -fsSL https://raw.githubusercontent.com/pjasielski/maestro/main/install.sh | bash
```

The installer will ask three questions (session visibility, AI tools, question style). Answer each and press Enter.

**Skip the questions (use defaults):**

```bash
curl -fsSL https://raw.githubusercontent.com/pjasielski/maestro/main/install.sh | bash -s -- . --quick
```

Defaults: all adapters, sessions committed, async questions.

### Step 3 — Follow the printed instructions

The installer prints tool-specific next steps when it finishes.

---

## Option C — Manual Install

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
| `templates/` | Document templates to match your team's standards |

---

## After Installing — First Steps

### Claude Code

1. Open a new Claude Code conversation in your project folder
2. Type `/mae-explore`

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
├── maestro.toml                      ← Settings (sessions, tools, question style)
├── HANDOFF.md                        ← Project status — single source of truth
├── DECISIONS.md                      ← Decision log
├── OPEN_QUESTIONS.md                 ← Questions to resolve
├── WORKLOG.md                        ← Activity log
│
├── .maestro/commands/                ← Maestro command definitions
├── .claude/commands/                 ← Claude Code integration (if selected)
├── .cursor/rules/                    ← Cursor integration (if selected)
├── .github/copilot-instructions.md   ← Copilot/Codex integration (if selected)
│
├── docs/
│   ├── 01-explore/
│   ├── 02-requirements/
│   ├── 03-design/
│   └── 04-plan/tasks/
│
├── .sessions/                        ← Working notes (gitignored or committed)
└── templates/                        ← Document templates
```

Maestro **never overwrites** files that already exist. Re-running the installer is safe.

---

## Team Setup

One person installs and commits. Others pull and configure their own tool.

**What to commit to git:**

```
✓  MAESTRO.md, CLAUDE.md, maestro.toml
✓  HANDOFF.md, DECISIONS.md, OPEN_QUESTIONS.md, WORKLOG.md
✓  docs/, templates/
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
rm -rf docs/ .sessions/ templates/
rm -f .github/copilot-instructions.md
```

Keep `CLAUDE.md` if it contains your own project notes.

---

## Troubleshooting

**"Command not found: curl"**
Use [Option C — Manual Install](#option-c--manual-install).

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
