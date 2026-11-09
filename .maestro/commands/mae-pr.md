# /mae-pr — Push the Branch and Open a Draft PR

The explicit outward step: pushes the current branch and opens a **draft** PR from the PR description. Runs only when the user types it.

**Artifact** (MAESTRO.md § Artifact Capture): the PR description in the session (`NN_pr-{milestone}.md`), plus a draft PR or a compare URL.

$ARGUMENTS — optional: milestone (`M05`); default: the milestone of the tasks committed on this branch

## Guard

If this was not typed by the user as `/mae-pr`, stop and say so. `/mae-do` and `/sync` only offer it.

## Behavior

1. **Check the branch.** On the default branch (`main`, `master`, or `origin/HEAD`) → stop: "`/mae-pr` never pushes {branch}." Uncommitted changes → list them and ask whether to continue without them.
2. **Description:** use the session's `NN_pr-{milestone}.md`; missing → write it first (MAESTRO.md § Git Policy, `pr = "markdown"`: title, summary, tasks with IDs and "done when", commits, how to test).
3. **Push the current branch only:** `git push -u origin {branch}`. Never force, never another branch, never tags.
4. **Open a draft PR** when `gh` is installed and the remote is GitHub: `gh pr create --draft --title "{title}" --body-file {description}`. Otherwise print the description and the compare URL (GitHub `…/compare/{base}...{branch}`; GitLab and Azure DevOps: their new-merge-request URL) for pasting.
5. **Report git actions:** "Pushed {branch} (N commits). Draft PR #{n}: {url}", or the fallback line.

## Rules

- Typing the command is the permission to push this branch, whatever `[git] push` says. Nothing else is loosened
- Never ready-for-review, never merge, never push the default branch

## Skip When

- `pr = "milestone"` already opened the draft PR at milestone completion
