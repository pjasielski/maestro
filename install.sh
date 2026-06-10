#!/bin/bash
# install.sh — Install Maestro framework into a project
#
# Usage:
#   ./install.sh [target-directory]          # interactive setup
#   ./install.sh [target-directory] --quick  # skip prompts, defaults
#   ./install.sh [target-directory] --preconfigured  # read settings from env vars
#   curl -fsSL https://raw.githubusercontent.com/pjasielski/maestro/main/install.sh | bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-.}"
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"
QUICK_MODE="${2:-}"

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

ask_choice() {
  local prompt="$1"
  shift
  local options=("$@")
  echo "$prompt" >&2
  for i in "${!options[@]}"; do
    echo "  $((i+1))) ${options[$i]}" >&2
  done
  local choice
  read -r -p "Choice [1]: " choice </dev/tty
  echo "${choice:-1}"
}

create_if_missing() {
  local filepath="$1"
  local content="$2"
  if [ ! -f "$filepath" ]; then
    echo "$content" > "$filepath"
    echo "  Created: $(basename "$filepath")"
  else
    echo "  Exists:  $(basename "$filepath") (preserved)"
  fi
}

section() {
  echo ""
  echo "── $1 ──────────────────────────"
}

# ─────────────────────────────────────────────
# Detect reinstall
# ─────────────────────────────────────────────

REINSTALL=false
if [ -f "$TARGET/MAESTRO.md" ]; then
  REINSTALL=true
  echo "Maestro detected — updating framework files, preserving your files."
  echo ""
fi

print_header

# ─────────────────────────────────────────────
# Configuration: one question (session visibility)
# ─────────────────────────────────────────────

PROJECT_NAME="$(basename "$TARGET")"
SESSION_VISIBILITY="committed"

if [ "$QUICK_MODE" = "--quick" ]; then
  echo "Quick mode: full structure, all adapters, sessions committed."
elif [ -n "$PRECONFIGURED_MODE" ]; then
  PROJECT_NAME="${PROJECT_NAME:-$(basename "$TARGET")}"
  SESSION_VISIBILITY="${SESSION_VISIBILITY:-committed}"
  echo "Preconfigured mode: $PROJECT_NAME"
elif [ "$REINSTALL" = false ]; then
  section "Setup"
  VIS_CHOICE=$(ask_choice "Session visibility:" \
    "Committed — sessions saved in git (solo projects, full audit trail)" \
    "Gitignored — sessions are personal working material (teams)")
  if [ "$VIS_CHOICE" = "2" ]; then
    SESSION_VISIBILITY="gitignored"
  fi
fi

# On reinstall, read existing visibility from maestro.toml if present
if [ "$REINSTALL" = true ] && [ -f "$TARGET/maestro.toml" ]; then
  EXISTING_VIS=$(grep 'session_visibility' "$TARGET/maestro.toml" 2>/dev/null | sed 's/.*= *"\(.*\)"/\1/' || true)
  [ -n "$EXISTING_VIS" ] && SESSION_VISIBILITY="$EXISTING_VIS"
fi

# ─────────────────────────────────────────────
# Create folder structure (always full)
# ─────────────────────────────────────────────

section "Creating folders"

mkdir -p "$TARGET/delivery/01-explore"
mkdir -p "$TARGET/delivery/02-prd"
mkdir -p "$TARGET/delivery/03-design"
mkdir -p "$TARGET/delivery/04-plan/tasks"
mkdir -p "$TARGET/delivery/05-review"
mkdir -p "$TARGET/delivery/06-test"
mkdir -p "$TARGET/delivery/07-deploy"
mkdir -p "$TARGET/delivery/08-maintenance/issues"
echo "  Created: delivery/ (full structure)"

mkdir -p "$TARGET/.sessions"
mkdir -p "$TARGET/notes"
mkdir -p "$TARGET/templates"
mkdir -p "$TARGET/.maestro/commands"
mkdir -p "$TARGET/.claude/commands"
mkdir -p "$TARGET/.cursor/rules"
mkdir -p "$TARGET/.github"
echo "  Created: .sessions/, notes/, templates/, .maestro/commands/"

# ─────────────────────────────────────────────
# Copy framework files (always update)
# ─────────────────────────────────────────────

section "Copying framework files"

cp "$SCRIPT_DIR/MAESTRO.md" "$TARGET/MAESTRO.md"
echo "  Copied: MAESTRO.md"

for cmd in "$SCRIPT_DIR/.maestro/commands/"*.md; do
  [ -f "$cmd" ] || continue
  BASENAME="$(basename "$cmd")"
  cp "$cmd" "$TARGET/.maestro/commands/$BASENAME"
done
echo "  Copied: .maestro/commands/ ($(ls "$TARGET/.maestro/commands/" | wc -l | tr -d ' ') files)"

# ─────────────────────────────────────────────
# Copy templates (never overwrite user customizations)
# ─────────────────────────────────────────────

section "Copying templates"

TMPL_NEW=0
TMPL_SKIP=0
for tmpl in "$SCRIPT_DIR/templates/"*.md; do
  [ -f "$tmpl" ] || continue
  BASENAME="$(basename "$tmpl")"
  if [ ! -f "$TARGET/templates/$BASENAME" ]; then
    cp "$tmpl" "$TARGET/templates/$BASENAME"
    TMPL_NEW=$((TMPL_NEW + 1))
  else
    TMPL_SKIP=$((TMPL_SKIP + 1))
  fi
done
echo "  New: $TMPL_NEW | Preserved: $TMPL_SKIP"

# ─────────────────────────────────────────────
# Claude Code adapters
# ─────────────────────────────────────────────

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
echo "  Created: .claude/commands/ (thin wrappers)"

# ─────────────────────────────────────────────
# Cursor adapters
# ─────────────────────────────────────────────

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
- On new chat: read HANDOFF.md, check .sessions/ for highest-numbered folder, greet user
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

echo "  Created: .cursor/rules/ (core + dispatch)"

# ─────────────────────────────────────────────
# Codex adapter
# ─────────────────────────────────────────────

section "Setting up Codex"

cat > "$TARGET/.github/copilot-instructions.md" <<'EOF'
# Maestro — AI-Assisted Delivery Framework

You are an AI delivery partner. Follow MAESTRO.md at the project root for all framework behavior, output standards, phases, and conventions.

## Quick Reference

**Output:** Lead with answer. No filler. Tables for comparisons. Save every substantive response as a numbered file in the current session folder.

**On new chat:** Read HANDOFF.md → check .sessions/ for highest-numbered folder → greet user → create session folder → begin work.

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

# ─────────────────────────────────────────────
# Tracking files (never overwrite)
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

| # | Date | Session | Decision | Status |
|---|------|---------|----------|--------|"

create_if_missing "$TARGET/OPEN_QUESTIONS.md" "# Open Questions

| # | Priority | Question | Context | Status |
|---|----------|----------|---------|--------|"

create_if_missing "$TARGET/WORKLOG.md" "# Work Log

| Date | Session | Summary |
|------|---------|---------|"

create_if_missing "$TARGET/notes/ideas.md" "# Ideas

Capture raw ideas, what-ifs, and parking-lot items here.
Promote to OPEN_QUESTIONS.md when they need a decision.

---"

# ─────────────────────────────────────────────
# maestro.toml (never overwrite)
# ─────────────────────────────────────────────

section "Creating config"

create_if_missing "$TARGET/maestro.toml" "[project]
name = \"$PROJECT_NAME\"
session_visibility = \"$SESSION_VISIBILITY\"

# Uncomment and fill in to enable profile-aware behavior:
# [user]
# description = \"Your role and expertise\"
# strengths = [\"area1\", \"area2\"]
# needs_help = [\"area3\", \"area4\"]

# Uncomment to define team members (activates team features):
# [[team.members]]
# name = \"Name\"
# role = \"role\"
# strengths = [\"area1\"]
# needs_help = [\"area2\"]"

# ─────────────────────────────────────────────
# CLAUDE.md (never overwrite)
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
    echo "  Exists:  CLAUDE.md (preserved)"
  fi
fi

# ─────────────────────────────────────────────
# .gitignore
# ─────────────────────────────────────────────

if [ ! -f "$TARGET/.gitignore" ]; then
  if [ "$SESSION_VISIBILITY" = "gitignored" ]; then
    cat > "$TARGET/.gitignore" <<'EOF'
# Maestro: personal working artifacts (gitignored)
.sessions/
notes/
.DS_Store
EOF
    echo "  Created: .gitignore (.sessions/ gitignored)"
  else
    cat > "$TARGET/.gitignore" <<'EOF'
.DS_Store
# .sessions/ and notes/ committed (change session_visibility in maestro.toml)
EOF
    echo "  Created: .gitignore (.sessions/ committed)"
  fi
else
  echo "  Exists:  .gitignore (preserved)"
fi

# ─────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────

echo ""
echo "╔══════════════════════════════════════╗"
echo "║    Maestro installed successfully    ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "Project: $PROJECT_NAME"
echo "Sessions: $SESSION_VISIBILITY"
echo "Adapters: Claude Code, Cursor, Codex"
echo ""
echo "── Next steps ──────────────────────────"
echo "  1. Edit CLAUDE.md with your project details"
echo "  2. Run /mae-init to set up your profile (optional)"
echo "  3. Run /mae-explore to start"
echo ""
echo "── Available commands ───────────────────"
echo "  /mae-explore    Build project understanding"
echo "  /mae-prd        Formalize requirements"
echo "  /mae-design     Create technical architecture"
echo "  /mae-plan       Break design into tasks"
echo "  /mae-do         Execute tasks"
echo "  /mae-review     Review code and artifacts"
echo "  /mae-checkpoint Save project state snapshot"
echo ""
