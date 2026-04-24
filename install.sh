#!/bin/bash
# install.sh — Install Maestro framework into a project
# Usage: ./install.sh [target-directory]
#        curl -fsSL https://raw.githubusercontent.com/pjasielski/maestro/main/install.sh | bash

set -e

# Determine source and target directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-.}"
TARGET="$(cd "$TARGET" && pwd)"

echo "=== Maestro Framework Installer ==="
echo "Installing into: $TARGET"
echo ""

# --- Create folder structure ---
echo "Creating folders..."
mkdir -p "$TARGET/delivery/01-explore"
mkdir -p "$TARGET/delivery/02-prd"
mkdir -p "$TARGET/delivery/03-design"
mkdir -p "$TARGET/delivery/04-plan/tasks"
mkdir -p "$TARGET/sessions"
mkdir -p "$TARGET/notes"
mkdir -p "$TARGET/templates"
mkdir -p "$TARGET/.claude/commands"

# --- Copy framework files ---
echo "Copying framework files..."
cp "$SCRIPT_DIR/MAESTRO.md" "$TARGET/MAESTRO.md"
echo "  Copied: MAESTRO.md"

# Copy command files (flat mae-*.md + utility commands)
for cmd in "$SCRIPT_DIR/.claude/commands/"*.md; do
  [ -f "$cmd" ] || continue
  BASENAME="$(basename "$cmd")"
  cp "$cmd" "$TARGET/.claude/commands/$BASENAME"
  echo "  Copied: .claude/commands/$BASENAME"
done

# Copy templates
for tmpl in "$SCRIPT_DIR/templates/"*.md; do
  [ -f "$tmpl" ] || continue
  BASENAME="$(basename "$tmpl")"
  cp "$tmpl" "$TARGET/templates/$BASENAME"
  echo "  Copied: templates/$BASENAME"
done

# --- Create tracking files (only if they don't exist) ---
echo ""
echo "Creating tracking files..."

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

PROJECT_NAME="$(basename "$TARGET")"
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

# --- Create maestro.toml ---
create_if_missing "$TARGET/maestro.toml" "[project]
name = \"$PROJECT_NAME\"
mode = \"solo\""

# --- Create or update CLAUDE.md ---
if [ ! -f "$TARGET/CLAUDE.md" ]; then
  cat > "$TARGET/CLAUDE.md" << 'CLAUDEEOF'
# CLAUDE.md

## Framework Instructions

See `MAESTRO.md` for all delivery framework behavior, commands, output standards, and conventions. MAESTRO.md is the canonical framework reference.

## Project

- **Framework:** Maestro (command prefix: `mae-`)
- **What this is:** {describe your project}
- **Current phase:** exploration
- **Stack:** {your tech stack}
- **Language:** Code and documentation in English
CLAUDEEOF
  echo "  Created: CLAUDE.md"
else
  if ! grep -q "MAESTRO.md" "$TARGET/CLAUDE.md"; then
    cat >> "$TARGET/CLAUDE.md" << 'APPENDEOF'

## Framework Instructions

See `MAESTRO.md` for all delivery framework behavior, commands, output standards, and conventions.
APPENDEOF
    echo "  Updated: CLAUDE.md (added MAESTRO.md reference)"
  else
    echo "  Exists:  CLAUDE.md (already references MAESTRO.md)"
  fi
fi

# --- Summary ---
echo ""
echo "=== Installation complete ==="
echo ""
echo "Next steps:"
echo "  1. Edit CLAUDE.md with your project details"
echo "  2. Start a new Claude Code conversation"
echo "  3. Run /mae-explore to begin exploring your project"
echo ""
echo "Commands available:"
echo "  /mae-init          Initialize framework (if not using install.sh)"
echo "  /mae-explore       Build project understanding"
echo "  /mae-prd           Formalize requirements"
echo "  /mae-design        Create technical architecture"
echo "  /mae-plan          Break design into tasks"
echo "  /mae-do            Execute tasks"
echo "  /mae-review        Review code and artifacts"
echo "  /mae-checkpoint    Save project state snapshot"
echo "  /status            View project status"
