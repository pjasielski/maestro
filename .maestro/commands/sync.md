# Sync — End-of-Session Save

Batch-update canonical project files based on accumulated decisions and progress. Also captures a checkpoint (state snapshot with delta summary).

## Behavior

1. **Read session state:**
   - Current session's `_summary.md`
   - `DECISIONS.md` — identify entries not yet reflected in canonical files
   - `HANDOFF.md` for current state
   - `docs/03-plan/ROADMAP.md` for task/milestone status
   - `docs/03-plan/tasks/` for task status changes

2. **Update HANDOFF.md:**
   - Current phase, status, recent changes
   - Architecture decisions table (if new decisions affect architecture)
   - Draft changes, show to user for review, apply only what is approved

3. **Update ROADMAP.md status:**
   - Reconcile Status column with completed work
   - Mark items ✅ done, 🔄 in progress, or ⏳ blocked based on session activity
   - Show proposed status changes for review

4. **Update DECISIONS.md:**
   - Append any confirmed decisions from the session not yet recorded
   - Find all `✓` confirmed decisions in `_summary.md` not yet marked `[synced]`

5. **Reconcile delivery artifacts (if decisions affect them):**
   - REQUIREMENTS.md, ARCHITECTURE.md — flag if decisions invalidate content
   - OPEN_QUESTIONS.md — resolve questions answered during session

6. **Capture checkpoint (state snapshot):**
   - Count decisions by status, open questions, task statuses
   - Compare against prior sync (if exists) — produce delta summary:
     ```
     Since last sync: +2 decisions confirmed, +3 tasks done, -1 question resolved
     ```
   - Append to `_summary.md`

7. **Mark synced decisions** in `_summary.md` (append `[synced]` to ✓ items)

8. **Update WORKLOG.md** — append entry logging the sync activity

9. **Running processes:** for each entry in `_summary.md` § Running Processes, check whether the pid is still alive; report orphans with their stop command, and mark stopped ones

10. **Git report** (MAESTRO.md § Git Policy): current branch, unpushed commits. A milestone completed this session with `pr` ≠ `off` and no PR description yet → write it. Push only if `push = "milestone"`; never otherwise

## Rules

- **Every edit to canonical files requires review** — show diff, wait for approval
- Group related changes for review efficiency
- If a decision contradicts an existing canonical entry, flag the conflict explicitly
- Never auto-apply changes to docs/ artifacts
