#!/bin/bash
# install.sh — Install Maestro framework into a project
#
# Usage:
#   ./install.sh [target-directory]            # interactive setup
#   ./install.sh [target-directory] --quick    # skip prompts, defaults
#   ./install.sh [target-directory] --force    # overwrite framework files; project files and maestro.toml keys kept
#   ./install.sh [target-directory] --preconfigured  # read settings from env vars
#   curl -fsSL https://raw.githubusercontent.com/pjasielski/maestro/main/install.sh | bash
#
# To install from a specific branch:
#   MAESTRO_BRANCH=feat/my-branch bash -c 'curl -fsSL "https://raw.githubusercontent.com/pjasielski/maestro/$MAESTRO_BRANCH/install.sh" | bash'

set -e

_BRANCH_EXPLICIT=false
[ -n "${MAESTRO_BRANCH:-}" ] && _BRANCH_EXPLICIT=true
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

# Skills (the model may offer them). Every other protocol is a command.
SKILLS="mae-explore mae-specs mae-scope mae-idea"
SKILL_FILES="mae-explore/SKILL.md mae-specs/SKILL.md mae-specs/references/requirements.md mae-specs/references/design.md mae-specs/references/architecture.md mae-scope/SKILL.md mae-idea/SKILL.md"

_CLEANUP_SOURCE=false
# Local mode only from a framework checkout installing into another directory.
# An installed project also has MAESTRO.md + .maestro/commands/, so a script run
# inside its own target (the documented upgrade) must download instead.
if [ ! -f "$SCRIPT_DIR/MAESTRO.md" ] || [ ! -d "$SCRIPT_DIR/.maestro/commands" ] || [ "$SCRIPT_DIR" = "$TARGET" ]; then
  echo "Downloading framework files from branch: $MAESTRO_BRANCH"
  if [ "$MAESTRO_BRANCH" = "main" ] && ! $_BRANCH_EXPLICIT; then
    echo "  (To install from a different branch, set MAESTRO_BRANCH=<branch>)"
  fi
  SOURCE_DIR="$(mktemp -d)"
  _CLEANUP_SOURCE=true
  _DL_FAIL=0

  if ! curl -fsSL "$MAESTRO_URL/MAESTRO.md" -o "$SOURCE_DIR/MAESTRO.md"; then
    echo "ERROR: Failed to download MAESTRO.md — cannot continue." >&2
    rm -rf "$SOURCE_DIR"
    exit 1
  fi

  mkdir -p "$SOURCE_DIR/.maestro/commands"
  for _cmd in mae-requirements mae-design mae-architecture mae-req mae-poc mae-plan mae-do mae-review mae-init mae-help mae-run mae-yolo status decide sync md; do
    if ! curl -fsSL "$MAESTRO_URL/.maestro/commands/$_cmd.md" -o "$SOURCE_DIR/.maestro/commands/$_cmd.md" 2>/dev/null; then
      echo "  Warning: failed to download $_cmd.md" >&2
      _DL_FAIL=$((_DL_FAIL + 1))
    fi
  done

  for _sf in $SKILL_FILES; do
    mkdir -p "$SOURCE_DIR/.maestro/skills/$(dirname "$_sf")"
    if ! curl -fsSL "$MAESTRO_URL/.maestro/skills/$_sf" -o "$SOURCE_DIR/.maestro/skills/$_sf" 2>/dev/null; then
      echo "  Warning: failed to download skill file $_sf" >&2
      _DL_FAIL=$((_DL_FAIL + 1))
    fi
  done

  mkdir -p "$SOURCE_DIR/.maestro/templates"
  for _tmpl in requirements design architecture explore ideas poc task summary report review roadmap scope-delta issue; do
    if ! curl -fsSL "$MAESTRO_URL/.maestro/templates/$_tmpl.md" -o "$SOURCE_DIR/.maestro/templates/$_tmpl.md" 2>/dev/null; then
      echo "  Warning: failed to download template $_tmpl.md" >&2
      _DL_FAIL=$((_DL_FAIL + 1))
    fi
  done

  if [ "$_DL_FAIL" -gt 0 ]; then
    echo "  $_DL_FAIL file(s) failed to download." >&2
    if [ "$MAESTRO_BRANCH" = "main" ] && ! $_BRANCH_EXPLICIT; then
      echo "  This may be because the files have different names on 'main'." >&2
      echo "  If you meant to install from a different branch, re-run with:" >&2
      echo "    MAESTRO_BRANCH=<branch> bash -c 'curl -fsSL \"https://raw.githubusercontent.com/pjasielski/maestro/\$MAESTRO_BRANCH/install.sh\" | bash'" >&2
    fi
    echo "  Install will continue with available files."
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

mkdir -p "$TARGET/docs/00-reference"
mkdir -p "$TARGET/docs/01-explore"
mkdir -p "$TARGET/docs/02-specs"
mkdir -p "$TARGET/docs/03-plan/tasks"
mkdir -p "$TARGET/docs/04-implementation"
mkdir -p "$TARGET/docs/05-review"
mkdir -p "$TARGET/docs/06-test"
mkdir -p "$TARGET/docs/07-deploy"
mkdir -p "$TARGET/docs/08-maintenance/issues"
echo "  Created: docs/ (full structure)"
_LEGACY=""
for _d in 02-requirements 02-poc 03-design 04-plan; do
  [ -n "$(find "$TARGET/docs/$_d" -type f 2>/dev/null | head -1)" ] && _LEGACY="$_LEGACY $_d/"
done
[ -n "$_LEGACY" ] && echo "  Old layout found (docs/:$_LEGACY). In your agent, run /mae-init upgrade."
if [ ! -f "$TARGET/docs/00-reference/README.md" ]; then
  cat > "$TARGET/docs/00-reference/README.md" <<'REFEOF'
# Reference material

Source materials you did **not** write: client briefs, specifications, meeting
transcripts, exported tickets, API docs from a third party.

`/mae-explore` reads this folder first and treats it as **authoritative on
intent**. Where reference material conflicts with what the code implies, the
reference wins — code describes the current state, reference describes what was
asked for.

Maestro never edits files in here. Drop things in and leave them as delivered.
REFEOF
  echo "  Created: docs/00-reference/README.md"
fi


mkdir -p "$TARGET/.sessions"
mkdir -p "$TARGET/.maestro/templates"
mkdir -p "$TARGET/.maestro/commands"
echo "  Created: .sessions/, .maestro/commands/, .maestro/templates/"

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

for _s in $SKILLS; do
  [ -f "$SOURCE_DIR/.maestro/skills/$_s/SKILL.md" ] || continue
  rm -rf "$TARGET/.maestro/skills/$_s"
  mkdir -p "$TARGET/.maestro/skills"
  cp -R "$SOURCE_DIR/.maestro/skills/$_s" "$TARGET/.maestro/skills/$_s"
done
echo "  Copied: .maestro/skills/ ($SKILLS)"

# ─────────────────────────────────────────────
# Clean up deprecated files from earlier versions
# ─────────────────────────────────────────────

_MIGRATED=0
for _old in mae-prd.md mae-checkpoint.md mae-explore-lite.md mae-explore.md mae-scope.md mae-specs.md mae-idea.md; do
  if [ -f "$TARGET/.maestro/commands/$_old" ]; then
    rm "$TARGET/.maestro/commands/$_old"
    echo "  Removed: .maestro/commands/$_old (renamed, or now a skill)"
    _MIGRATED=$((_MIGRATED + 1))
  fi
done
for _old in prd.md sdd.md; do
  if [ -f "$TARGET/templates/$_old" ]; then
    rm "$TARGET/templates/$_old"
    echo "  Removed: templates/$_old (renamed)"
    _MIGRATED=$((_MIGRATED + 1))
  fi
done
for _old in mae-prd.md mae-checkpoint.md mae-explore-lite.md mae-explore.md mae-scope.md mae-specs.md mae-idea.md; do
  [ -f "$TARGET/.claude/commands/$_old" ] && rm "$TARGET/.claude/commands/$_old"
  [ -f "$TARGET/.cursor/commands/$_old" ] && rm "$TARGET/.cursor/commands/$_old"
done
if [ -d "$TARGET/templates" ]; then
  if [ -n "$(ls -A "$TARGET/templates/" 2>/dev/null)" ]; then
    cp "$TARGET/templates/"*.md "$TARGET/.maestro/templates/" 2>/dev/null || true
    echo "  Migrated: templates/ → .maestro/templates/"
  fi
  rm -rf "$TARGET/templates"
  _MIGRATED=$((_MIGRATED + 1))
fi
if [ -d "$TARGET/delivery" ]; then
  echo "  Note: delivery/ folder found — contents now belong in docs/"
  echo "        Move your files manually: mv delivery/* docs/"
  _MIGRATED=$((_MIGRATED + 1))
fi
if [ -d "$TARGET/sessions" ]; then
  echo "  Note: sessions/ folder found — renamed to .sessions/ in new version"
  echo "        Move your files manually: mv sessions/* .sessions/"
  _MIGRATED=$((_MIGRATED + 1))
fi
if [ -d "$TARGET/notes" ]; then
  echo "  Note: notes/ folder found — no longer used in new version"
  _MIGRATED=$((_MIGRATED + 1))
fi
# v0.5.0: design.md was the architecture template; it is now the visual system
if [ -f "$TARGET/.maestro/templates/design.md" ] && head -1 "$TARGET/.maestro/templates/design.md" | grep -q '^# DESIGN:'; then
  if [ ! -f "$TARGET/.maestro/templates/architecture.md" ]; then
    mv "$TARGET/.maestro/templates/design.md" "$TARGET/.maestro/templates/architecture.md"
    echo "  Renamed: .maestro/templates/design.md → architecture.md (design.md is now the visual system)"
  else
    rm "$TARGET/.maestro/templates/design.md"
    echo "  Removed: .maestro/templates/design.md (old architecture template; architecture.md exists)"
  fi
  _MIGRATED=$((_MIGRATED + 1))
fi
[ "$_MIGRATED" -eq 0 ] && echo "  No deprecated files found"

# ─────────────────────────────────────────────
# Copy templates (overwrite only with --force)
# ─────────────────────────────────────────────

section "Copying templates"

TMPL_NEW=0
TMPL_SKIP=0
TMPL_REPLACED=0
for tmpl in "$SOURCE_DIR/.maestro/templates/"*.md; do
  [ -f "$tmpl" ] || continue
  BASENAME="$(basename "$tmpl")"
  if [ -f "$TARGET/.maestro/templates/$BASENAME" ] && ! $FORCE_MODE; then
    TMPL_SKIP=$((TMPL_SKIP + 1))
  elif [ -f "$TARGET/.maestro/templates/$BASENAME" ]; then
    cp "$tmpl" "$TARGET/.maestro/templates/$BASENAME"
    TMPL_REPLACED=$((TMPL_REPLACED + 1))
  else
    cp "$tmpl" "$TARGET/.maestro/templates/$BASENAME"
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
  for pair in mex:mae-explore msp:mae-specs mrq:mae-requirements mds:mae-design mar:mae-architecture mpoc:mae-poc mpl:mae-plan mdo:mae-do mrv:mae-review msc:mae-scope; do
    alias_name="${pair%%:*}"
    canonical="${pair##*:}"
    proto=".maestro/commands/$canonical.md"
    [ -f "$TARGET/.maestro/skills/$canonical/SKILL.md" ] && proto=".maestro/skills/$canonical/SKILL.md"
    cat > "$TARGET/.claude/commands/$alias_name.md" <<EOF
# $alias_name
Follow the protocol defined in \`$proto\`.
Pass \$ARGUMENTS through as-is.
EOF
  done

  # Skills: copies, not links (portable). The skill answers /{name} itself.
  mkdir -p "$TARGET/.claude/skills"
  for _s in $SKILLS; do
    [ -d "$TARGET/.maestro/skills/$_s" ] || continue
    rm -rf "$TARGET/.claude/skills/$_s"
    cp -R "$TARGET/.maestro/skills/$_s" "$TARGET/.claude/skills/$_s"
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

Commands: mae-explore (mex), mae-idea, mae-specs (msp), mae-requirements (mrq), mae-design (mds), mae-architecture (mar), mae-poc (mpoc), mae-scope (msc), mae-plan (mpl), mae-do (mdo), mae-review (mrv), mae-init, mae-help, mae-run, mae-yolo, sync, decide, status, md. Old name: mae-req → mae-requirements

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

for pair in mex:mae-explore msp:mae-specs mrq:mae-requirements mds:mae-design mar:mae-architecture mpoc:mae-poc mpl:mae-plan mdo:mae-do mrv:mae-review msc:mae-scope; do
  alias_name="${pair%%:*}"
  canonical="${pair##*:}"
  proto=".maestro/commands/$canonical.md"
  [ -f "$TARGET/.maestro/skills/$canonical/SKILL.md" ] && proto=".maestro/skills/$canonical/SKILL.md"
  cat > "$TARGET/.cursor/commands/$alias_name.md" <<EOF
# $alias_name
Follow the protocol defined in \`$proto\`.
Pass all user arguments through as-is.
EOF
done

# Skills: slash-command pointers for Cursor
for _s in $SKILLS; do
  [ -f "$TARGET/.maestro/skills/$_s/SKILL.md" ] || continue
  cat > "$TARGET/.cursor/commands/$_s.md" <<EOF
# $_s
Follow the skill defined in \`.maestro/skills/$_s/SKILL.md\`.
Pass all user arguments through as-is.
EOF
done

echo "  Created: .cursor/commands/ (slash commands + aliases)"
fi

# Skills for Cursor and Codex (.agents/skills/)
if $SETUP_CURSOR || $SETUP_CODEX; then
  mkdir -p "$TARGET/.agents/skills"
  for _s in $SKILLS; do
    [ -d "$TARGET/.maestro/skills/$_s" ] || continue
    rm -rf "$TARGET/.agents/skills/$_s"
    cp -R "$TARGET/.maestro/skills/$_s" "$TARGET/.agents/skills/$_s"
  done
  echo "  Created: .agents/skills/ ($SKILLS)"
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

**Flags:** CONSISTENCY: (contradiction) | GAP: (missing info) | UNCLEAR: (ambiguous) | STALE: (outdated artifact) | DRIFT: (code ≠ ARCHITECTURE.md)

## Commands

When user types any of these, read the corresponding file and follow its full protocol:

| Command | Alias | File |
|---------|-------|------|
| mae-explore | mex | .maestro/skills/mae-explore/SKILL.md |
| mae-idea | — | .maestro/skills/mae-idea/SKILL.md |
| mae-specs | msp | .maestro/skills/mae-specs/SKILL.md |
| mae-requirements | mrq | .maestro/commands/mae-requirements.md |
| mae-design | mds | .maestro/commands/mae-design.md |
| mae-architecture | mar | .maestro/commands/mae-architecture.md |
| mae-poc | mpoc | .maestro/commands/mae-poc.md |
| mae-req (old name) | — | .maestro/commands/mae-req.md |
| mae-scope | msc | .maestro/skills/mae-scope/SKILL.md |
| mae-plan | mpl | .maestro/commands/mae-plan.md |
| mae-do | mdo | .maestro/commands/mae-do.md |
| mae-review | mrv | .maestro/commands/mae-review.md |
| mae-init | — | .maestro/commands/mae-init.md |
| mae-help | — | .maestro/commands/mae-help.md |
| mae-run | — | .maestro/commands/mae-run.md |
| mae-yolo | — | .maestro/commands/mae-yolo.md |
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

# Upgrades: add keys introduced since the project was installed. Existing keys
# are never changed. One line per key: section|key|line to insert under [section].
TOML_KEYS=(
  "project|name|name = \"$PROJECT_NAME\""
  "project|session_visibility|session_visibility = \"$SESSION_VISIBILITY\""
  "project|question_style|question_style = \"$QUESTION_STYLE\""
  "project|ai_tools|ai_tools = $AI_TOOLS_TOML"
)
toml_has_key() {  # file section key → 0 if key is set inside [section]
  awk -v sec="[$2]" -v key="$3" '
    /^[[:space:]]*\[/ { insec = ($0 ~ "^[[:space:]]*\\[" substr(sec, 2, length(sec)-2) "\\][[:space:]]*$") ; next }
    insec && $0 ~ "^[[:space:]]*" key "[[:space:]]*=" { found = 1 }
    END { exit found ? 0 : 1 }' "$1"
}
for _entry in "${TOML_KEYS[@]}"; do
  IFS='|' read -r _sec _key _line <<< "$_entry"
  toml_has_key "$TARGET/maestro.toml" "$_sec" "$_key" && continue
  if grep -q "^\[$_sec\]" "$TARGET/maestro.toml"; then
    awk -v hdr="[$_sec]" -v add="$_line" '{ print } $0 == hdr { print add }' "$TARGET/maestro.toml" > "$TARGET/maestro.toml.tmp" \
      && mv "$TARGET/maestro.toml.tmp" "$TARGET/maestro.toml"
  else
    printf '\n[%s]\n%s\n' "$_sec" "$_line" >> "$TARGET/maestro.toml"
  fi
  echo "  Added:   maestro.toml [$_sec] $_key"
done

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

- **Framework:** Maestro (command prefix: `mae-`, aliases: `mex`/`msp`/`mrq`/`mds`/`mar`/`mpoc`/`msc`/`mpl`/`mdo`/`mrv`)
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
sessions/
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
elif [ "$SESSION_VISIBILITY" = "gitignored" ]; then
  # Existing .gitignore: the chosen visibility must still be honored (append, idempotent)
  if grep -qE '^\.?sessions/' "$TARGET/.gitignore"; then
    echo "  Exists:  .gitignore (.sessions/ already ignored)"
  else
    cat >> "$TARGET/.gitignore" <<'EOF'

# Maestro: personal working artifacts (gitignored)
.sessions/
sessions/
EOF
    echo "  Updated: .gitignore (appended .sessions/)"
  fi
else
  if grep -qE '^\.?sessions/' "$TARGET/.gitignore"; then
    echo "  WARNING: session_visibility is 'committed' but .gitignore ignores .sessions/"
    echo "           Remove the .sessions/ line from .gitignore to commit sessions."
  else
    echo "  Exists:  .gitignore (preserved)"
  fi
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
echo "  1. Run /mae-help — it tells you what to run next, every time"
echo "  2. Edit CLAUDE.md with your project details"
echo "  3. Run /mae-init to set up your profile (optional)"
echo "  4. Put any client briefs / specs in docs/00-reference/"
echo "  5. Run /mae-explore to start"
echo ""
echo "── Commands ────────────────────────────"
echo "  /mae-explore (mex)   Build project understanding → EXPLORE.md"
echo "  /mae-idea            Park an idea in IDEAS.md"
echo "  /mae-specs   (msp)   Requirements, design (if UI), architecture — whatever is missing"
echo "  /mae-poc     (mpoc)  PoC spec: requirements + architecture + roadmap in one file"
echo "  /mae-scope   (msc)   Scope change: classify, impact analysis, apply"
echo "  /mae-plan    (mpl)   Create roadmap and tasks"
echo "  /mae-do      (mdo)   Execute tasks"
echo "  /mae-review  (mrv)   Review code and artifacts"
echo "  /mae-help            What should I run now? (/mae-help all for everything)"
echo ""

# Clean up temp source dir if we downloaded it
if $_CLEANUP_SOURCE; then rm -rf "$SOURCE_DIR"; fi
