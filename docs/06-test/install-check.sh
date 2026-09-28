#!/bin/bash
# install-check.sh — installer acceptance checks, offline, against the working tree.
#
#   docs/06-test/install-check.sh
#
# 1. Parity: a clone-mode install and a download-mode install (the curl path,
#    served from file://) produce identical trees.
# 2. Pointers: every `.maestro/…` file named by an installed adapter, MAESTRO.md,
#    command or skill exists in the installed project.
# 3. Fail closed: a download with one file missing exits non-zero and leaves the
#    target without MAESTRO.md.
# 4. No Git: an install outside a repository writes commit = "never".
# 5. AGENTS.md: an existing file keeps its content; a re-run replaces only the
#    Maestro block.
# 6. Upgrade: a v0.4.0-shaped project keeps its keys, notes and docs and gets
#    the new commands, skills, templates and adapters; a plain re-run changes
#    nothing of the user's.

set -u
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
FAILS=0
fail() { echo "FAIL: $*"; FAILS=$((FAILS + 1)); }
pass() { echo "ok:   $*"; }

# Download mode needs the script outside a checkout; files come from file://.
mkdir -p "$WORK/bin"
cp "$REPO/install.sh" "$WORK/bin/install.sh"
download_install() {  # target [url]
  MAESTRO_URL="${2:-file://$REPO}" bash "$WORK/bin/install.sh" "$1" --quick
}

# Same basename for both targets: the project name is written into files.
mkdir -p "$WORK/clone/proj" "$WORK/download/proj"
git -C "$WORK/clone/proj" init -q
git -C "$WORK/download/proj" init -q

# 1. Parity
bash "$REPO/install.sh" "$WORK/clone/proj" --quick > "$WORK/clone.log" 2>&1 \
  || fail "clone-mode install exited non-zero (log: $(tail -3 "$WORK/clone.log"))"
download_install "$WORK/download/proj" > "$WORK/download.log" 2>&1 \
  || fail "download-mode install exited non-zero (log: $(tail -3 "$WORK/download.log"))"
if diff -r -x .git "$WORK/clone/proj" "$WORK/download/proj" > "$WORK/diff.txt"; then
  pass "clone and download installs are identical"
else
  fail "clone and download installs differ:"; sed 's/^/      /' "$WORK/diff.txt"
fi

# 2. Pointers
P="$WORK/clone/proj"
MISSING=$(cd "$P" && grep -rhoE '\.maestro/[A-Za-z0-9_./-]+\.md' \
    MAESTRO.md AGENTS.md .claude .cursor .github .agents .maestro 2>/dev/null \
  | sort -u | while read -r f; do [ -f "$f" ] || echo "$f"; done)
if [ -z "$MISSING" ]; then pass "every .maestro/ pointer resolves"
else fail "dangling pointers:"; echo "$MISSING" | sed 's/^/      /'; fi
for f in AGENTS.md .github/copilot-instructions.md .cursor/rules/maestro-dispatch.mdc .claude/skills/mae-explore/SKILL.md .agents/skills/mae-specs/references/design.md; do
  [ -f "$P/$f" ] || fail "missing $f"
done

# 3. Fail closed
SRC="$WORK/partial-src"
mkdir -p "$SRC"
cp -R "$REPO/MAESTRO.md" "$REPO/.maestro" "$REPO/.cursor" "$SRC/"
rm "$SRC/.maestro/templates/task.md"
mkdir -p "$WORK/partial/proj"
if download_install "$WORK/partial/proj" "file://$SRC" > "$WORK/partial.log" 2>&1; then
  fail "partial download exited 0"
elif [ -f "$WORK/partial/proj/MAESTRO.md" ]; then
  fail "partial download wrote MAESTRO.md into the target"
elif grep -q "installed successfully" "$WORK/partial.log"; then
  fail "partial download printed the success banner"
else
  pass "partial download fails closed"
fi

# 4. No Git
mkdir -p "$WORK/nogit/proj"
bash "$REPO/install.sh" "$WORK/nogit/proj" --quick > "$WORK/nogit.log" 2>&1
if grep -q '^commit = "never"' "$WORK/nogit/proj/maestro.toml" 2>/dev/null; then
  pass "no Git repository → commit = \"never\""
else
  fail "no Git repository did not set commit = \"never\""
fi

# 5. AGENTS.md merge
mkdir -p "$WORK/agents/proj"
git -C "$WORK/agents/proj" init -q
printf '# Team rules\n\nUse tabs.\n' > "$WORK/agents/proj/AGENTS.md"
bash "$REPO/install.sh" "$WORK/agents/proj" --quick > /dev/null 2>&1
bash "$REPO/install.sh" "$WORK/agents/proj" --force > /dev/null 2>&1
A="$WORK/agents/proj/AGENTS.md"
if grep -q 'Use tabs.' "$A" && [ "$(grep -c 'maestro:start' "$A")" = 1 ]; then
  pass "AGENTS.md: user content kept, one Maestro block after a re-run"
else
  fail "AGENTS.md merge: user content lost or block duplicated"
fi

# 6. Upgrade a v0.4.0-shaped project (download mode, --force), then re-run
U="$WORK/upgrade/proj"
mkdir -p "$U/docs/04-plan" "$U/.maestro/commands" "$U/.maestro/templates" "$U/.github"
git -C "$U" init -q
printf '[project]\nname = "proj"\nsession_visibility = "gitignored"\nquestion_style = "sync"\nai_tools = ["claude", "copilot", "codex"]\n' > "$U/maestro.toml"
echo "# MAESTRO v0.4" > "$U/MAESTRO.md"
printf '# HANDOFF\nmy notes\n' > "$U/HANDOFF.md"
echo x > "$U/docs/04-plan/ROADMAP.md"
echo old > "$U/.maestro/commands/mae-explore.md"
printf '# DESIGN: {name}\n' > "$U/.maestro/templates/design.md"
printf '# Maestro — AI-Assisted Delivery Framework\n\nold generated\n' > "$U/.github/copilot-instructions.md"
MAESTRO_URL="file://$REPO" bash "$WORK/bin/install.sh" "$U" --force > "$WORK/upgrade.log" 2>&1 \
  || fail "upgrade exited non-zero"
UP_OK=true
grep -q 'Old layout found' "$WORK/upgrade.log"                  || { fail "upgrade: no legacy-layout hint"; UP_OK=false; }
grep -q 'question_style = "sync"' "$U/maestro.toml"             || { fail "upgrade: existing toml key changed"; UP_OK=false; }
grep -q '^\[git\]' "$U/maestro.toml"                            || { fail "upgrade: [git] not appended"; UP_OK=false; }
grep -q 'my notes' "$U/HANDOFF.md"                              || { fail "upgrade: HANDOFF.md changed"; UP_OK=false; }
[ -f "$U/docs/04-plan/ROADMAP.md" ]                             || { fail "upgrade: installer moved user docs"; UP_OK=false; }
[ ! -f "$U/.maestro/commands/mae-explore.md" ]                  || { fail "upgrade: old command copy kept"; UP_OK=false; }
[ -f "$U/.maestro/skills/mae-explore/SKILL.md" ]                || { fail "upgrade: skill not installed"; UP_OK=false; }
grep -q '^# ARCHITECTURE\|^# DESIGN: {name}' "$U/.maestro/templates/architecture.md" 2>/dev/null || { fail "upgrade: old design.md not migrated"; UP_OK=false; }
grep -q 'old generated' "$U/.github/copilot-instructions.md"    && { fail "upgrade: pre-0.5.0 Copilot file not replaced"; UP_OK=false; }
[ -f "$U/AGENTS.md" ]                                           || { fail "upgrade: AGENTS.md missing (codex in ai_tools)"; UP_OK=false; }
$UP_OK && pass "v0.4.0-shaped project upgraded: keys, notes and docs kept; commands, skills, templates, adapters migrated"
cp "$U/maestro.toml" "$WORK/toml.before"
MAESTRO_URL="file://$REPO" bash "$WORK/bin/install.sh" "$U" > /dev/null 2>&1 || fail "re-run exited non-zero"
if diff -q "$WORK/toml.before" "$U/maestro.toml" > /dev/null && [ "$(grep -c 'maestro:start' "$U/AGENTS.md")" = 1 ] && grep -q 'my notes' "$U/HANDOFF.md"; then
  pass "re-run without --force changes nothing of the user's"
else
  fail "re-run changed maestro.toml, HANDOFF.md or duplicated the AGENTS.md block"
fi

echo ""
if [ "$FAILS" -eq 0 ]; then echo "All install checks passed."; else echo "$FAILS check(s) failed."; exit 1; fi
