#!/bin/bash
# install.sh — Install Maestro framework into a project
#
# Usage:
#   ./install.sh [target-directory]          # interactive setup
#   ./install.sh [target-directory] --quick  # skip prompts, Claude Code only, core folders
#   curl -fsSL https://raw.githubusercontent.com/pjasielski/maestro/main/install.sh | bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-.}"
TARGET="$(cd "$TARGET" && pwd)"
QUICK_MODE="${2:-}"

# --preconfigured: read settings from env vars (used by setup/server.py and setup/index.html)
PRECONFIGURED_MODE=""
[ "$QUICK_MODE" = "--preconfigured" ] && PRECONFIGURED_MODE="yes"

# ─────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────

print_header() {
  echo ""
  echo "╔══════════════════════════════════════╗"
  echo "║    Maestro Framework Installer       ║"
  echo "╚══════════════════════════════════════╝"
  echo ""
  echo "Installing into: $TARGET"
  echo ""
}

ask() {
  local prompt="$1"
  local default="$2"
  local answer
  if [ -n "$default" ]; then
    read -r -p "$prompt [$default]: " answer
    echo "${answer:-$default}"
  else
    read -r -p "$prompt: " answer
    echo "$answer"
  fi
}

ask_choice() {
  local prompt="$1"
  shift
  local options=("$@")
  echo "$prompt"
  for i in "${!options[@]}"; do
    echo "  $((i+1))) ${options[$i]}"
  done
  local choice
  read -r -p "Choice [1]: " choice
  echo "${choice:-1}"
}

ask_multichoice() {
  local prompt="$1"
  shift
  local options=("$@")
  echo "$prompt"
  echo "  (enter numbers separated by spaces, e.g. 1 2)"
  for i in "${!options[@]}"; do
    echo "  $((i+1))) ${options[$i]}"
  done
  local choices
  read -r -p "Choices [1]: " choices
  echo "${choices:-1}"
}

create_if_missing() {
  local filepath="$1"
  local content="$2"
  if [ ! -f "$filepath" ]; then
    echo "$content" > "$filepath"
    echo "  Created: $(basename "$filepath")"
  else
    echo "  Exists:  $(basename "$filepath") (skipped)"
  fi
}

section() {
  echo ""
  echo "── $1 ──────────────────────────"
}

# ─────────────────────────────────────────────
# Check already initialized
# ─────────────────────────────────────────────

if [ -f "$TARGET/HANDOFF.md" ] && [ -f "$TARGET/MAESTRO.md" ]; then
  echo "⚠️  Maestro already initialized in this directory."
  echo "   To re-run setup: delete HANDOFF.md and MAESTRO.md first."
  echo "   To add a new tool: run /mae-init tools in Claude Code."
  exit 0
fi

print_header

# ─────────────────────────────────────────────
# Quick mode (non-interactive)
# ─────────────────────────────────────────────

if [ "$QUICK_MODE" = "--quick" ]; then
  PROJECT_NAME="$(basename "$TARGET")"
  MODE="solo"
  TOOLS="1"     # Claude Code only
  SCOPE="1"     # Core folders only
  echo "Quick mode: Claude Code, solo, core folders."
elif [ -n "$PRECONFIGURED_MODE" ]; then
  # Settings passed via environment variables from setup wizard
  PROJECT_NAME="${PROJECT_NAME:-$(basename "$TARGET")}"
  MODE="${MODE:-solo}"
  TOOLS="${TOOLS:-1}"
  SCOPE="${SCOPE:-1}"
  echo "Preconfigured mode: $PROJECT_NAME, $MODE"
else
  # ─────────────────────────────────────────────
  # Interactive setup
  # ─────────────────────────────────────────────

  section "Project"
  PROJECT_NAME=$(ask "Project name" "$(basename "$TARGET")")

  echo ""
  MODE_CHOICE=$(ask_choice "Mode:" "Solo (one person)" "Team (multiple people)")
  if [ "$MODE_CHOICE" = "2" ]; then
    MODE="team"
  else
    MODE="solo"
  fi

  echo ""
  TOOLS=$(ask_multichoice "Which AI tool(s) will you use?" \
    "Claude Code (VS Code / CLI)" \
    "Cursor" \
    "Codex (OpenAI)" \
    "All of the above")

  echo ""
  SCOPE_CHOICE=$(ask_choice "Delivery folder scope:" \
    "Core — explore, prd, design, plan  (recommended)" \
    "Full — core + review, test, deploy, maintenance" \
    "Minimal — no delivery folders (session-based only)")
  SCOPE="$SCOPE_CHOICE"
fi

# ─────────────────────────────────────────────
# Parse tool selections
# ─────────────────────────────────────────────

SETUP_CLAUDE=false
SETUP_CURSOR=false
SETUP_CODEX=false

for t in $TOOLS; do
  case "$t" in
    1) SETUP_CLAUDE=true ;;
    2) SETUP_CURSOR=true ;;
    3) SETUP_CODEX=true ;;
    4) SETUP_CLAUDE=true; SETUP_CURSOR=true; SETUP_CODEX=true ;;
  esac
done

# ─────────────────────────────────────────────
# Build tools list for maestro.toml
# ─────────────────────────────────────────────

TOOLS_LIST=""
$SETUP_CLAUDE && TOOLS_LIST="${TOOLS_LIST}\"claude-code\", "
$SETUP_CURSOR && TOOLS_LIST="${TOOLS_LIST}\"cursor\", "
$SETUP_CODEX  && TOOLS_LIST="${TOOLS_LIST}\"codex\", "
TOOLS_LIST="${TOOLS_LIST%, }"  # strip trailing comma

# ─────────────────────────────────────────────
# Create folder structure
# ─────────────────────────────────────────────

section "Creating folders"

# Core delivery folders (always if scope != minimal)
if [ "$SCOPE" != "3" ]; then
  mkdir -p "$TARGET/delivery/01-explore"
  mkdir -p "$TARGET/delivery/02-prd"
  mkdir -p "$TARGET/delivery/03-design"
  mkdir -p "$TARGET/delivery/04-plan/tasks"
  echo "  Created: delivery/ (core)"
fi

# Full delivery folders
if [ "$SCOPE" = "2" ]; then
  mkdir -p "$TARGET/delivery/05-review"
  mkdir -p "$TARGET/delivery/06-test"
  mkdir -p "$TARGET/delivery/07-deploy"
  mkdir -p "$TARGET/delivery/08-maintenance/issues"
  echo "  Created: delivery/05-08 (full)"
fi

mkdir -p "$TARGET/sessions"
mkdir -p "$TARGET/notes"
mkdir -p "$TARGET/templates"
mkdir -p "$TARGET/.maestro/commands"

# Tool-specific folders
$SETUP_CLAUDE && mkdir -p "$TARGET/.claude/commands"
$SETUP_CURSOR && mkdir -p "$TARGET/.cursor/rules"
$SETUP_CODEX  && mkdir -p "$TARGET/.github"

echo "  Created: sessions/, notes/, templates/, .maestro/commands/"

# ─────────────────────────────────────────────
# Copy framework files
# ─────────────────────────────────────────────

section "Copying framework files"

cp "$SCRIPT_DIR/MAESTRO.md" "$TARGET/MAESTRO.md"
echo "  Copied: MAESTRO.md"

# Copy command specs to .maestro/commands/ (single source of truth)
for cmd in "$SCRIPT_DIR/.claude/commands/"*.md; do
  [ -f "$cmd" ] || continue
  BASENAME="$(basename "$cmd")"
  cp "$cmd" "$TARGET/.maestro/commands/$BASENAME"
done
echo "  Copied: .maestro/commands/ ($(ls "$TARGET/.maestro/commands/" | wc -l | tr -d ' ') command files)"

# Copy templates
for tmpl in "$SCRIPT_DIR/templates/"*.md; do
  [ -f "$tmpl" ] || continue
  BASENAME="$(basename "$tmpl")"
  cp "$tmpl" "$TARGET/templates/$BASENAME"
done
echo "  Copied: templates/"

# ─────────────────────────────────────────────
# Claude Code adapters
# ─────────────────────────────────────────────

if $SETUP_CLAUDE; then
  section "Setting up Claude Code"
  for cmd in "$TARGET/.maestro/commands/"*.md; do
    [ -f "$cmd" ] || continue
    BASENAME="$(basename "$cmd")"
    CMDNAME="${BASENAME%.md}"
    cat > "$TARGET/.claude/commands/$BASENAME" <<EOF
# $CMDNAME
Follow the protocol defined in \`.maestro/commands/$BASENAME\`.
Pass \$ARGUMENTS through as-is.
EOF
  done
  echo "  Created: .claude/commands/ (thin wrappers → .maestro/commands/)"
fi

# ─────────────────────────────────────────────
# Cursor adapters
# ─────────────────────────────────────────────

if $SETUP_CURSOR; then
  section "Setting up Cursor"

  cat > "$TARGET/.cursor/rules/maestro-core.mdc" <<'EOF'
---
description: Maestro delivery framework — core rules and behavior
alwaysApply: true
---

Read `MAESTRO.md` at the project root before responding to any delivery-related request.

MAESTRO.md contains: output standards, delivery phases, context loading rules, file conventions, decision tracking, and the New Chat Protocol.

Follow all rules in MAESTRO.md. Key rules:
- Save every substantive response as a numbered file in the current session folder
- Use flags (CONSISTENCY:, GAP:, UNCLEAR:) when appropriate
- On new chat: read HANDOFF.md, check sessions/ for highest-numbered folder, greet user
- Output standard: lead with answer, no filler, tables for comparisons
- Instruction priority: user's explicit instruction > command defaults > MAESTRO.md baseline
EOF

  cat > "$TARGET/.cursor/rules/maestro-dispatch.mdc" <<'EOF'
---
description: Maestro command dispatcher — maps /mae-* commands to protocol files
alwaysApply: true
---

When the user writes any of the following in chat, read the corresponding file and execute its full protocol. Do not summarise or shortcut the protocol — read the file first.

| User types | Load and follow |
|------------|----------------|
| /mae-explore (+ optional args) | .maestro/commands/mae-explore.md |
| /mae-prd (+ optional args) | .maestro/commands/mae-prd.md |
| /mae-design (+ optional args) | .maestro/commands/mae-design.md |
| /mae-plan (+ optional args) | .maestro/commands/mae-plan.md |
| /mae-do (+ optional args) | .maestro/commands/mae-do.md |
| /mae-review (+ optional args) | .maestro/commands/mae-review.md |
| /mae-checkpoint (+ optional args) | .maestro/commands/mae-checkpoint.md |
| /mae-init (+ optional args) | .maestro/commands/mae-init.md |
| /status (+ optional args) | .maestro/commands/status.md |
| /decide (+ optional args) | .maestro/commands/decide.md |
| /sync | .maestro/commands/sync.md |
| /md (+ optional args) | .maestro/commands/md.md |

Text after the command name = $ARGUMENTS passed to the protocol.
Always read the file — do not guess the protocol from memory.
EOF

  echo "  Created: .cursor/rules/maestro-core.mdc"
  echo "  Created: .cursor/rules/maestro-dispatch.mdc"
fi

# ─────────────────────────────────────────────
# Codex adapter
# ─────────────────────────────────────────────

if $SETUP_CODEX; then
  section "Setting up Codex"

  # Read MAESTRO.md for inclusion (first 80 lines = core rules)
  cat > "$TARGET/.github/copilot-instructions.md" <<'EOF'
# Maestro — AI-Assisted Delivery Framework

You are an AI delivery partner. Follow MAESTRO.md at the project root for all framework behavior, output standards, phases, and conventions.

## Quick Reference

**Output:** Lead with answer. No filler. Tables for comparisons. Save every substantive response as a numbered file in the current session folder.

**On new chat:** Read HANDOFF.md → check sessions/ for highest-numbered folder → greet user → create session folder → begin work.

**Instruction priority:** User's explicit instruction > command defaults > MAESTRO.md baseline.

**Flags:** CONSISTENCY: (contradiction) | GAP: (missing info) | UNCLEAR: (ambiguous) | STALE: (outdated artifact) | DRIFT: (code ≠ SDD)

## Commands

When user types any of these, read the corresponding file and follow its full protocol:

| Command | File |
|---------|------|
| /mae-explore | .maestro/commands/mae-explore.md |
| /mae-prd | .maestro/commands/mae-prd.md |
| /mae-design | .maestro/commands/mae-design.md |
| /mae-plan | .maestro/commands/mae-plan.md |
| /mae-do | .maestro/commands/mae-do.md |
| /mae-review | .maestro/commands/mae-review.md |
| /mae-checkpoint | .maestro/commands/mae-checkpoint.md |
| /mae-init | .maestro/commands/mae-init.md |
| /status | .maestro/commands/status.md |
| /decide | .maestro/commands/decide.md |
| /sync | .maestro/commands/sync.md |

Always read the file before executing — do not guess the protocol.
EOF

  echo "  Created: .github/copilot-instructions.md"
fi

# ─────────────────────────────────────────────
# Tracking files
# ─────────────────────────────────────────────

section "Creating tracking files"

TODAY="$(date +%Y-%m-%d)"

create_if_missing "$TARGET/HANDOFF.md" "# HANDOFF — $PROJECT_NAME

**Status:** Not started
**Phase:** exploration
**Updated:** $TODAY

---

## Current Focus
{What are we working on?}

## Key Decisions
| Decision | Date | Status |
|----------|------|--------|

## Architecture
{High-level architecture summary once design is done}

## Recent Changes
| Date | Change |
|------|--------|"

create_if_missing "$TARGET/DECISIONS.md" "# Decision Log

| Date | Session | Decision | Status |
|------|---------|----------|--------|"

create_if_missing "$TARGET/OPEN_QUESTIONS.md" "# Open Questions

| ID | Priority | Question | Context | Status |
|----|----------|----------|---------|--------|"

create_if_missing "$TARGET/WORKLOG.md" "# Work Log

| Date | Session | Summary |
|------|---------|---------|"

create_if_missing "$TARGET/notes/ideas.md" "# Ideas

Capture raw ideas, what-ifs, and parking-lot items here.
Promote to OPEN_QUESTIONS.md when they need a decision.

---"

# ─────────────────────────────────────────────
# maestro.toml
# ─────────────────────────────────────────────

section "Creating config"

if [ ! -f "$TARGET/maestro.toml" ]; then
  cat > "$TARGET/maestro.toml" <<EOF
[project]
name = "$PROJECT_NAME"
mode = "$MODE"

[tools]
active = [$TOOLS_LIST]

# Output tier default: "standard" | "verbose" | "caveman"
# Override per-command with -v or -c flags
output_tier = "standard"

# Uncomment to share sessions with team (remove sessions/ from .gitignore too):
# share_sessions = true
EOF
  echo "  Created: maestro.toml"
else
  echo "  Exists:  maestro.toml (skipped)"
fi

# ─────────────────────────────────────────────
# CLAUDE.md
# ─────────────────────────────────────────────

if [ ! -f "$TARGET/CLAUDE.md" ]; then
  cat > "$TARGET/CLAUDE.md" <<'CLAUDEEOF'
# CLAUDE.md

## Framework Instructions

See `MAESTRO.md` for all delivery framework behavior, commands, output standards, and conventions. MAESTRO.md is the canonical framework reference.

When interacting, always apply instructions from `MAESTRO.md`.
Always save substantive responses to a file in the session folder unless the response is very short (< 80 words).

## Project

- **Framework:** Maestro (command prefix: `mae-`)
- **What this is:** {describe your project}
- **Current phase:** exploration
- **Stack:** {your tech stack}
- **Language:** English
CLAUDEEOF
  echo "  Created: CLAUDE.md"
else
  if ! grep -q "MAESTRO.md" "$TARGET/CLAUDE.md"; then
    printf '\n## Framework Instructions\n\nSee `MAESTRO.md` for all delivery framework behavior.\n' >> "$TARGET/CLAUDE.md"
    echo "  Updated: CLAUDE.md (added MAESTRO.md reference)"
  else
    echo "  Exists:  CLAUDE.md (already references MAESTRO.md)"
  fi
fi

# ─────────────────────────────────────────────
# .gitignore
# ─────────────────────────────────────────────

if [ ! -f "$TARGET/.gitignore" ]; then
  if [ "$MODE" = "team" ]; then
    cat > "$TARGET/.gitignore" <<'EOF'
# Maestro: personal working artifacts (gitignored in team mode)
sessions/
notes/
.DS_Store
EOF
    echo "  Created: .gitignore (team mode — sessions/ gitignored)"
  else
    cat > "$TARGET/.gitignore" <<'EOF'
.DS_Store
# sessions/ and notes/ committed in solo mode
# Change mode to "team" in maestro.toml to gitignore them
EOF
    echo "  Created: .gitignore (solo mode — sessions/ committed)"
  fi
else
  echo "  Exists:  .gitignore (skipped — check manually for sessions/ entry)"
fi

# ─────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────

echo ""
echo "╔══════════════════════════════════════╗"
echo "║    ✓ Installation complete           ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "Project: $PROJECT_NAME  |  Mode: $MODE"
echo ""

if $SETUP_CLAUDE; then
  echo "── Claude Code ──────────────────────────"
  echo "  Open a new Claude Code conversation."
  echo "  Type: /mae-explore"
  echo ""
fi

if $SETUP_CURSOR; then
  echo "── Cursor ───────────────────────────────"
  echo "  Open your project in Cursor."
  echo "  In the AI chat, type: /mae-explore"
  echo "  (Cursor rules are loaded automatically)"
  echo ""
fi

if $SETUP_CODEX; then
  echo "── Codex ────────────────────────────────"
  echo "  Codex reads .github/copilot-instructions.md automatically."
  echo "  Type: /mae-explore"
  echo ""
fi

echo "── Available commands ───────────────────"
echo "  /mae-explore    Build project understanding"
echo "  /mae-prd        Formalize requirements"
echo "  /mae-design     Create technical architecture"
echo "  /mae-plan       Break design into tasks"
echo "  /mae-do         Execute tasks"
echo "  /mae-review     Review code and artifacts"
echo "  /mae-checkpoint Save project state snapshot"
echo ""
echo "Edit CLAUDE.md with your project details, then run /mae-explore."
echo ""
