#!/bin/bash
# install.sh — Install Maestro framework into a project
#
# Usage:
#   ./install.sh [target-directory]            # interactive setup
#   ./install.sh [target-directory] --quick    # skip prompts, defaults
#   ./install.sh [target-directory] --force    # overwrite ALL files (full reinstall)
#   ./install.sh [target-directory] --preconfigured  # read settings from env vars
#   curl -fsSL https://raw.githubusercontent.com/pjasielski/maestro/main/install.sh | bash
#
# To install from a specific branch:
#   MAESTRO_BRANCH=feat/my-branch bash -c 'curl -fsSL "https://raw.githubusercontent.com/pjasielski/maestro/$MAESTRO_BRANCH/install.sh" | bash'

set -e

MAESTRO_BRANCH="${MAESTRO_BRANCH:-main}"
MAESTRO_URL="${MAESTRO_URL:-https://raw.githubusercontent.com/pjasielski/maestro/$MAESTRO_BRANCH}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-/dev/null}")" 2>/dev/null && pwd || pwd)"
TARGET="${1:-.}"
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"
QUICK_MODE="${2:-}"
FORCE_MODE=false

PRECONFIGURED_MODE=""
[ "$QUICK_MODE" = "--preconfigured" ] && PRECONFIGURED_MODE="yes"
[ "$QUICK_MODE" = "--force" ] && FORCE_MODE=true

# ─────────────────────────────────────────────
# Self-download when running via curl (no local source files)
# ─────────────────────────────────────────────

_CLEANUP_SOURCE=false
if [ ! -f "$SCRIPT_DIR/MAESTRO.md" ]; then
  echo "Downloading framework files..."
  SOURCE_DIR="$(mktemp -d)"
  _CLEANUP_SOURCE=true
  _DL_FAIL=0

  if ! curl -fsSL "$MAESTRO_URL/MAESTRO.md" -o "$SOURCE_DIR/MAESTRO.md"; then
    echo "ERROR: Failed to download MAESTRO.md — cannot continue." >&2
    rm -rf "$SOURCE_DIR"
    exit 1
  fi

  mkdir -p "$SOURCE_DIR/.maestro/commands"
  for _cmd in mae-explore mae-req mae-design mae-plan mae-do mae-review mae-init mae-explore-lite status decide sync md; do
    if ! curl -fsSL "$MAESTRO_URL/.maestro/commands/$_cmd.md" -o "$SOURCE_DIR/.maestro/commands/$_cmd.md" 2>/dev/null; then
      echo "  Warning: failed to download $_cmd.md" >&2
      _DL_FAIL=$((_DL_FAIL + 1))
    fi
  done

  mkdir -p "$SOURCE_DIR/templates"
  for _tmpl in requirements design explore task summary report review roadmap; do
    if ! curl -fsSL "$MAESTRO_URL/templates/$_tmpl.md" -o "$SOURCE_DIR/templates/$_tmpl.md" 2>/dev/null; then
      echo "  Warning: failed to download template $_tmpl.md" >&2
      _DL_FAIL=$((_DL_FAIL + 1))
    fi
  done

  if [ "$_DL_FAIL" -gt 0 ]; then
    echo "  $_DL_FAIL file(s) failed to download. Install will continue with available files."
  fi
else
  SOURCE_DIR="$SCRIPT_DIR"
fi

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

ask_multichoice() {
  local prompt="$1"
  shift
  local options=("$@")
  echo "$prompt" >&2
  echo "  (enter numbers separated by spaces, e.g. 1 2)" >&2
  for i in "${!options[@]}"; do
    echo "  $((i+1))) ${options[$i]}" >&2
  done
  local choices
  read -r -p "Choices [1]: " choices </dev/tty
  echo "${choices:-1}"
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
SESSION_VISIBILITY="${SESSION_VISIBILITY:-committed}"
TOOLS="${TOOLS:-}"
QUESTION_STYLE="${QUESTION_STYLE:-async}"

SETUP_CLAUDE=true
SETUP_CURSOR=true
SETUP_COPILOT=true
SETUP_CODEX=true

if [ "$QUICK_MODE" = "--force" ]; then
  echo "Force mode: overwriting all framework files (templates, adapters, MAESTRO.md, commands)."
  echo "Project files preserved: HANDOFF.md, DECISIONS.md, OPEN_QUESTIONS.md, WORKLOG.md, maestro.toml, CLAUDE.md"
  echo ""
elif [ "$QUICK_MODE" = "--quick" ]; then
  echo "Quick mode: all adapters, sessions committed, async questions."
elif [ -n "$PRECONFIGURED_MODE" ]; then
  PROJECT_NAME="${PROJECT_NAME:-$(basename "$TARGET")}"
  SESSION_VISIBILITY="${SESSION_VISIBILITY:-committed}"
  QUESTION_STYLE="${QUESTION_STYLE:-async}"
  TOOLS="${TOOLS:-5}"
  echo "Preconfigured mode: $PROJECT_NAME"
elif [ "$REINSTALL" = false ]; then
  section "Setup"

  VIS_CHOICE=$(ask_choice "Session visibility:" \
    "Committed — sessions saved in git (solo projects, full audit trail)" \
    "Gitignored — sessions are personal working material (teams)")
  if [ "$VIS_CHOICE" = "2" ]; then
    SESSION_VISIBILITY="gitignored"
  fi

  echo ""
  TOOLS=$(ask_multichoice "Which AI tool(s) will you use?" \
    "Claude Code (VS Code / CLI)" \
    "Cursor" \
    "Copilot (GitHub)" \
    "Codex (OpenAI)" \
    "All of the above")

  echo ""
  QS_CHOICE=$(ask_choice "How should the agent ask questions?" \
    "In file — agent writes questions to markdown for async review (recommended)" \
    "In chat — agent asks questions during conversation")
  if [ "$QS_CHOICE" = "2" ]; then
    QUESTION_STYLE="sync"
  fi
fi

# Parse tool selections
if [ -n "$TOOLS" ]; then
  SETUP_CLAUDE=false
  SETUP_CURSOR=false
  SETUP_COPILOT=false
  SETUP_CODEX=false
  for t in $TOOLS; do
    case "$t" in
      1) SETUP_CLAUDE=true ;;
      2) SETUP_CURSOR=true ;;
      3) SETUP_COPILOT=true ;;
      4) SETUP_CODEX=true ;;
      5) SETUP_CLAUDE=true; SETUP_CURSOR=true; SETUP_COPILOT=true; SETUP_CODEX=true ;;
    esac
  done
fi

# On reinstall, read existing settings from maestro.toml if present
if [ "$REINSTALL" = true ] && [ -f "$TARGET/maestro.toml" ]; then
  EXISTING_VIS=$(grep 'session_visibility' "$TARGET/maestro.toml" 2>/dev/null | sed 's/.*= *"\(.*\)"/\1/' || true)
  [ -n "$EXISTING_VIS" ] && SESSION_VISIBILITY="$EXISTING_VIS"
  EXISTING_QS=$(grep 'question_style' "$TARGET/maestro.toml" 2>/dev/null | sed 's/.*= *"\(.*\)"/\1/' || true)
  [ -n "$EXISTING_QS" ] && QUESTION_STYLE="$EXISTING_QS"

  # Read ai_tools from existing config
  EXISTING_TOOLS=$(grep 'ai_tools' "$TARGET/maestro.toml" 2>/dev/null || true)
  if [ -n "$EXISTING_TOOLS" ]; then
    SETUP_CLAUDE=false; SETUP_CURSOR=false; SETUP_COPILOT=false; SETUP_CODEX=false
    echo "$EXISTING_TOOLS" | grep -q '"claude"'  && SETUP_CLAUDE=true
    echo "$EXISTING_TOOLS" | grep -q '"cursor"'  && SETUP_CURSOR=true
    echo "$EXISTING_TOOLS" | grep -q '"copilot"' && SETUP_COPILOT=true
    echo "$EXISTING_TOOLS" | grep -q '"codex"'   && SETUP_CODEX=true
  fi
fi

# ─────────────────────────────────────────────
# Create folder structure
# ─────────────────────────────────────────────

section "Creating folders"

mkdir -p "$TARGET/docs/01-explore"
mkdir -p "$TARGET/docs/02-requirements"
mkdir -p "$TARGET/docs/03-design"
mkdir -p "$TARGET/docs/04-plan/tasks"
mkdir -p "$TARGET/docs/05-implementation"
mkdir -p "$TARGET/docs/06-review"
mkdir -p "$TARGET/docs/07-test"
mkdir -p "$TARGET/docs/08-deploy"
mkdir -p "$TARGET/docs/09-maintenance/issues"
echo "  Created: docs/ (full structure)"

mkdir -p "$TARGET/.sessions"
mkdir -p "$TARGET/templates"
mkdir -p "$TARGET/.maestro/commands"
echo "  Created: .sessions/, templates/, .maestro/commands/"

# ─────────────────────────────────────────────
# Copy framework files (always update)
# ─────────────────────────────────────────────

section "Copying framework files"

cp "$SOURCE_DIR/MAESTRO.md" "$TARGET/MAESTRO.md"
if [ ! -f "$TARGET/MAESTRO.md" ]; then
  echo "ERROR: MAESTRO.md not found after copy — install cannot continue." >&2
  exit 1
fi
echo "  Copied: MAESTRO.md"

for cmd in "$SOURCE_DIR/.maestro/commands/"*.md; do
  [ -f "$cmd" ] || continue
  BASENAME="$(basename "$cmd")"
  cp "$cmd" "$TARGET/.maestro/commands/$BASENAME"
done
echo "  Copied: .maestro/commands/ ($(ls "$TARGET/.maestro/commands/" | wc -l | tr -d ' ') files)"

# ─────────────────────────────────────────────
# Copy templates (overwrite only with --force)
# ─────────────────────────────────────────────

section "Copying templates"

TMPL_NEW=0
TMPL_SKIP=0
TMPL_REPLACED=0
for tmpl in "$SOURCE_DIR/templates/"*.md; do
  [ -f "$tmpl" ] || continue
  BASENAME="$(basename "$tmpl")"
  if [ -f "$TARGET/templates/$BASENAME" ] && ! $FORCE_MODE; then
    TMPL_SKIP=$((TMPL_SKIP + 1))
  elif [ -f "$TARGET/templates/$BASENAME" ]; then
    cp "$tmpl" "$TARGET/templates/$BASENAME"
    TMPL_REPLACED=$((TMPL_REPLACED + 1))
  else
    cp "$tmpl" "$TARGET/templates/$BASENAME"
    TMPL_NEW=$((TMPL_NEW + 1))
  fi
done
if $FORCE_MODE; then
  echo "  New: $TMPL_NEW | Replaced: $TMPL_REPLACED | Preserved: $TMPL_SKIP"
else
  echo "  New: $TMPL_NEW | Preserved: $TMPL_SKIP"
fi

# ─────────────────────────────────────────────
# Claude Code adapters (wrappers + aliases)
# ─────────────────────────────────────────────

if $SETUP_CLAUDE; then
  section "Setting up Claude Code"

  mkdir -p "$TARGET/.claude/commands"

  # Create thin wrappers for all mae-* commands
  for cmd in "$TARGET/.maestro/commands/"mae-*.md; do
    [ -f "$cmd" ] || continue
    BASENAME="$(basename "$cmd")"
    CMDNAME="${BASENAME%.md}"
    cat > "$TARGET/.claude/commands/$BASENAME" <<EOF
# $CMDNAME
Follow the protocol defined in \`.maestro/commands/$BASENAME\`.
Pass \$ARGUMENTS through as-is.
EOF
  done

  # Create wrappers for utility commands (non-mae- prefixed)
  for cmd in decide sync status md; do
    if [ -f "$TARGET/.maestro/commands/$cmd.md" ]; then
      cat > "$TARGET/.claude/commands/$cmd.md" <<EOF
# $cmd
Follow the protocol defined in \`.maestro/commands/$cmd.md\`.
Pass \$ARGUMENTS through as-is.
EOF
    fi
  done

  # Create aliases
  for pair in mex:mae-explore mrq:mae-req mds:mae-design mpl:mae-plan mdo:mae-do mrv:mae-review; do
    alias_name="${pair%%:*}"
    canonical="${pair##*:}"
    cat > "$TARGET/.claude/commands/$alias_name.md" <<EOF
# $alias_name
Follow the protocol defined in \`.maestro/commands/$canonical.md\`.
Pass \$ARGUMENTS through as-is.
EOF
  done

  echo "  Created: .claude/commands/ (wrappers + aliases)"
fi

# ─────────────────────────────────────────────
# Cursor adapters
# ─────────────────────────────────────────────

if $SETUP_CURSOR; then
section "Setting up Cursor"

mkdir -p "$TARGET/.cursor/rules"
mkdir -p "$TARGET/.cursor/commands"

# Copy Cursor rules from source if they exist, otherwise generate
if [ -d "$SOURCE_DIR/.cursor/rules" ]; then
  for rule in "$SOURCE_DIR/.cursor/rules/"*.mdc; do
    [ -f "$rule" ] || continue
    cp "$rule" "$TARGET/.cursor/rules/$(basename "$rule")"
  done
else
  cat > "$TARGET/.cursor/rules/maestro-core.mdc" <<'CURSOREOF'
---
alwaysApply: true
---
# Maestro Framework — Core Rules

Read `MAESTRO.md` at the project root before responding to any delivery-related request.
Follow all rules in MAESTRO.md. Key rules:
- Save every substantive response as a numbered file in the current session folder
- Use flags (CONSISTENCY:, GAP:, UNCLEAR:) when appropriate
- On new chat: read HANDOFF.md, check .sessions/ for highest-numbered folder, greet user
- Output standard: lead with answer, no filler, tables for comparisons
CURSOREOF

  cat > "$TARGET/.cursor/rules/maestro-dispatch.mdc" <<'CURSOREOF'
---
alwaysApply: true
---
# Maestro Command Dispatch

When the user types a Maestro command in chat, load the corresponding file from `.maestro/commands/` and follow its protocol.

Commands: mae-explore (mex), mae-req (mrq), mae-design (mds), mae-plan (mpl), mae-do (mdo), mae-review (mrv), mae-init, sync, decide, status, md

Always read the command file before executing — do not guess the protocol.
CURSOREOF
fi

echo "  Created: .cursor/rules/ (core + dispatch)"

# Cursor slash commands (same pattern as Claude Code wrappers)
for cmd in "$TARGET/.maestro/commands/"mae-*.md; do
  [ -f "$cmd" ] || continue
  BASENAME="$(basename "$cmd")"
  CMDNAME="${BASENAME%.md}"
  cat > "$TARGET/.cursor/commands/$BASENAME" <<EOF
# $CMDNAME
Follow the protocol defined in \`.maestro/commands/$BASENAME\`.
Pass all user arguments through as-is.
EOF
done

for cmd in decide sync status md; do
  if [ -f "$TARGET/.maestro/commands/$cmd.md" ]; then
    cat > "$TARGET/.cursor/commands/$cmd.md" <<EOF
# $cmd
Follow the protocol defined in \`.maestro/commands/$cmd.md\`.
Pass all user arguments through as-is.
EOF
  fi
done

for pair in mex:mae-explore mrq:mae-req mds:mae-design mpl:mae-plan mdo:mae-do mrv:mae-review; do
  alias_name="${pair%%:*}"
  canonical="${pair##*:}"
  cat > "$TARGET/.cursor/commands/$alias_name.md" <<EOF
# $alias_name
Follow the protocol defined in \`.maestro/commands/$canonical.md\`.
Pass all user arguments through as-is.
EOF
done

echo "  Created: .cursor/commands/ (slash commands + aliases)"
fi

# ─────────────────────────────────────────────
# Copilot / Codex adapter
# ─────────────────────────────────────────────

if $SETUP_COPILOT || $SETUP_CODEX; then
section "Setting up Copilot / Codex"

mkdir -p "$TARGET/.github"

cat > "$TARGET/.github/copilot-instructions.md" <<'EOF'
# Maestro — AI-Assisted Delivery Framework

You are an AI delivery partner. Follow MAESTRO.md at the project root for all framework behavior, output standards, phases, and conventions.

## Quick Reference

**Output:** Lead with answer. No filler. Tables for comparisons. Save every substantive response as a numbered file in the current session folder.

**On new chat:** Read HANDOFF.md → check .sessions/ for highest-numbered folder → greet user → create session folder → begin work.

**Flags:** CONSISTENCY: (contradiction) | GAP: (missing info) | UNCLEAR: (ambiguous) | STALE: (outdated artifact) | DRIFT: (code ≠ DESIGN.md)

## Commands

When user types any of these, read the corresponding file and follow its full protocol:

| Command | Alias | File |
|---------|-------|------|
| mae-explore | mex | .maestro/commands/mae-explore.md |
| mae-req | mrq | .maestro/commands/mae-req.md |
| mae-design | mds | .maestro/commands/mae-design.md |
| mae-plan | mpl | .maestro/commands/mae-plan.md |
| mae-do | mdo | .maestro/commands/mae-do.md |
| mae-review | mrv | .maestro/commands/mae-review.md |
| mae-init | — | .maestro/commands/mae-init.md |
| status | — | .maestro/commands/status.md |
| decide | — | .maestro/commands/decide.md |
| sync | — | .maestro/commands/sync.md |
| md | — | .maestro/commands/md.md |

Always read the file before executing — do not guess the protocol.
EOF

echo "  Created: .github/copilot-instructions.md"
fi

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

# ─────────────────────────────────────────────
# maestro.toml (never overwrite)
# ─────────────────────────────────────────────

section "Creating config"

# Build ai_tools list for toml
AI_TOOLS_TOML=""
$SETUP_CLAUDE  && AI_TOOLS_TOML="${AI_TOOLS_TOML}\"claude\", "
$SETUP_CURSOR  && AI_TOOLS_TOML="${AI_TOOLS_TOML}\"cursor\", "
$SETUP_COPILOT && AI_TOOLS_TOML="${AI_TOOLS_TOML}\"copilot\", "
$SETUP_CODEX   && AI_TOOLS_TOML="${AI_TOOLS_TOML}\"codex\", "
AI_TOOLS_TOML="[${AI_TOOLS_TOML%, }]"

create_if_missing "$TARGET/maestro.toml" "[project]
name = \"$PROJECT_NAME\"
session_visibility = \"$SESSION_VISIBILITY\"
question_style = \"$QUESTION_STYLE\"
ai_tools = $AI_TOOLS_TOML

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

- **Framework:** Maestro (command prefix: `mae-`, aliases: `mex`/`mrq`/`mds`/`mpl`/`mdo`/`mrv`)
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
.DS_Store
EOF
    echo "  Created: .gitignore (.sessions/ gitignored)"
  else
    cat > "$TARGET/.gitignore" <<'EOF'
.DS_Store
# .sessions/ committed (change session_visibility in maestro.toml)
EOF
    echo "  Created: .gitignore (.sessions/ committed)"
  fi
else
  echo "  Exists:  .gitignore (preserved)"
fi

# ─────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────

ADAPTERS=""
$SETUP_CLAUDE  && ADAPTERS="${ADAPTERS}Claude Code, "
$SETUP_CURSOR  && ADAPTERS="${ADAPTERS}Cursor, "
$SETUP_COPILOT && ADAPTERS="${ADAPTERS}Copilot, "
$SETUP_CODEX   && ADAPTERS="${ADAPTERS}Codex, "
ADAPTERS="${ADAPTERS%, }"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║    Maestro installed successfully    ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "Project:    $PROJECT_NAME"
echo "Sessions:   $SESSION_VISIBILITY"
echo "Questions:  $QUESTION_STYLE"
echo "Adapters:   $ADAPTERS"
echo ""
echo "── Next steps ──────────────────────────"
echo "  1. Edit CLAUDE.md with your project details"
echo "  2. Run /mae-init to set up your profile (optional)"
echo "  3. Run /mae-explore to start"
echo ""
echo "── Commands ────────────────────────────"
echo "  /mae-explore (mex)   Build project understanding"
echo "  /mae-req     (mrq)   Formalize requirements"
echo "  /mae-design  (mds)   Create technical architecture"
echo "  /mae-plan    (mpl)   Create roadmap and tasks"
echo "  /mae-do      (mdo)   Execute tasks"
echo "  /mae-review  (mrv)   Review code and artifacts"
echo ""

# Clean up temp source dir if we downloaded it
if $_CLEANUP_SOURCE; then rm -rf "$SOURCE_DIR"; fi
