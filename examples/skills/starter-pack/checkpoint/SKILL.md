---
name: checkpoint
description: Save a high-fidelity session checkpoint before compacting or stepping away. Use when the user says "checkpoint", "save progress", "save state", "handoff", "I'm running low on context", "before we compact", "/checkpoint", or when you are nearing the context limit mid-task. Writes a HANDOVER.md breadcrumb (state + next step + open decisions + file map) and commits, so a compaction or fresh session resumes losslessly.
---

# Checkpoint

Write a durable, high-fidelity breadcrumb so the next context window (after `/compact`, `/clear`, or `/resume`) picks up exactly where this one left off. This is the **manual, high-quality** save; the `PreCompact` hook (`~/.claude/hooks/pre-compact.sh`) is the **automatic fallback** that writes the same `HANDOVER.md` via Haiku when you don't run this. The `SessionStart` hook reads `HANDOVER.md` back on the next compact/resume.

## When to run
- Nearing the context limit mid-task (don't wait for auto-compact to fire at ~80%).
- At a natural boundary before `/compact` or `/clear`.
- Before stepping away from a long session.

## Steps
1. **Locate the project root** — git root (`git rev-parse --show-toplevel`) if in a repo, else cwd.
2. **Write `HANDOVER.md` at the root** (overwrite). Keep it tight and specific — paths and names, not vibes:
   - **Goal** — what we're working on (1–2 sentences).
   - **Done** — completed work this session (bullets).
   - **In progress** — what's actively being worked on and where it stands.
   - **Open decisions** — anything unresolved the user still needs to weigh in on.
   - **File → artifact map** — key files/folders touched and what each holds (include out-of-repo artifacts, e.g. `~/yt-notes/...`).
   - **Next step** — ONE concrete next action, not a list.
3. **Get work onto disk** — anything important living only in the chat, write it to its proper file now.
4. **Commit** (if in a repo) — stage and commit with `checkpoint: <short summary>`. Do NOT push; respect branch rules (the push-to-main hook blocks pushes anyway). Say so if there's nothing to commit.
5. **Tell the user it's safe to `/compact`** (or `/clear`), and that `SessionStart` will auto-surface `HANDOVER.md` on the next continuation.

## Notes
- Distill, don't dump. The value is the precise **next step** + **open decisions**, not a transcript.
- The freshness guard in `pre-compact.sh` preserves a `HANDOVER.md` written in the last 15 min, so running `/checkpoint` right before `/compact` won't get clobbered by the auto-summary.
- If a topic-scoped breadcrumb exists (e.g. a subdir `RESUME.md`), fold its live parts into the root `HANDOVER.md` so there's one canonical resume file.
