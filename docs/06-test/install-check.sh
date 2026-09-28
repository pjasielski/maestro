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

echo ""
if [ "$FAILS" -eq 0 ]; then echo "All install checks passed."; else echo "$FAILS check(s) failed."; exit 1; fi
