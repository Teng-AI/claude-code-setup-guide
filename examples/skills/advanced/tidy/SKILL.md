---
name: tidy
description: Refactor a folder of docs/knowledge — audit for drift, then consolidate and reorganize, preserving all content and git history. Use when the user says "tidy this folder", "/tidy", "refactor these docs", "this folder's a mess", "consolidate these docs/notes", "clean up and reorganize this folder", "deep sweep this folder", "reorganize this directory", or points at a folder of markdown/research/notes and wants it de-duplicated, restructured, or cleaned up. Audits for duplication, orphaned/unlinked files, broken links, stale content, and structural problems; proposes a plan; executes only with approval; verifies links after. For DOCS/knowledge folders — NOT source code.
allowed-tools: [Read, Write, Edit, Grep, Glob, Bash, Agent, AskUserQuestion]
argument-hint: [folder-path]
---

# Tidy — refactor a doc/knowledge folder

Audit a folder of documentation/notes for drift, propose a reorganization, execute it **preserving every piece of context and git history**, then verify nothing broke. This is the docs analog of code refactoring.

**Scope:** markdown, research, notes, knowledge bases. NOT source code, not Claude config (`/setup-audit`), not docs-vs-code sync (that lives in `/wrap-up` Step 11). If pointed at a code folder, say so and redirect.

**The golden rule:** never lose context. Files get *merged and folded*, never silently dropped. Everything runs through git so it's recoverable.

## Steps

### 1. Scope + inventory
- Resolve the target folder (the `$ARGUMENTS` path, or ask if none given). Confirm it's inside a git repo — if not, warn that moves/deletes won't be recoverable and ask before proceeding.
- List every file (path, size, modified date, type). Note the entry point if one exists (`README.md` or similar).
- Run the mechanical check to get a baseline: `python3 ~/.claude/skills/tidy/scripts/check_docs.py <folder>` — reports broken links + orphan files (no inbound links). Keep the output; you'll re-run it at the end.

### 2. Deep audit (offload to a subagent)
Spawn ONE subagent (Agent tool, `general-purpose`) to read the docs and return a **prioritized, read-only findings report** — keep the heavy reads out of the main context. Have it check all six drift modes:
1. **Duplication / overlap** — the same fact or section restated across files that should instead summarize-and-link.
2. **Orphans** — files nothing links to (cross-check the script's output with judgment: is it genuinely unreferenced, or load-bearing-but-unlinked?).
3. **Broken links** — every relative link resolves.
4. **Stale content** — claims that contradict current reality (status says "in progress" for done work, old counts, dead next-steps).
5. **Structural issues** — missing hub/index, too flat (many loose files) or too nested, misgrouped files, evidence mixed with canonical docs.
6. **Naming inconsistency** — clashing or unclear filenames, two files with the same H1 title.

Each finding: file + location + what's wrong + a one-line suggested fix.

### 3. Propose a plan (STOP for approval)
Synthesize the findings into a concrete reorganization plan. For each action state the **rationale** and **which links change**:
- **Merge** A + B → keep one, fold the other's unique content in.
- **Move** X → subfolder (and why that grouping).
- **Delete** W — only *after* folding its unique content into V.
- **Rename** for consistency.
- **Create/refresh** the folder's hub (`README.md`) + a source-of-truth map.

Present it as a before/after sketch. **Do not execute yet.** This is the user's review gate. Use AskUserQuestion if there are real choices (which name, merge vs keep, what owns a fact).

### 4. Execute (only on approval)
- Confirm any destructive op explicitly before running it.
- **Fold before delete:** read the target, fold its unique content into the survivor, *then* `git rm`. Never delete content that isn't preserved elsewhere.
- Use `git mv` for moves/renames (preserves history).
- **Fix every link** — inbound (other files pointing in) AND internal (the moved file's own relative links shift, e.g. `foo.md` → `../foo.md`).
- Establish/refresh the hub: a `README.md` that's the single entry point, with a doc-map table (domain → canonical doc) so each fact has one home.

### 5. Verify + report
- Re-run `check_docs.py <folder>` — it MUST come back clean (links resolve, no new orphans).
- Grep for stray references to any renamed/deleted file — must be zero.
- Show the before/after file tree and a short changelog (merged / moved / deleted / renamed).
- Offer to commit (don't auto-commit unless asked). Use a clear message listing the structural changes.

## Principles it enforces (the embedded convention)

- **Preserve all context** — merge/fold, never silently drop. Git is the safety net.
- **One hub per folder** — a `README.md` entry point; every file reachable from it (directly or transitively).
- **One source of truth per fact** — assign each domain to one canonical doc; everywhere else summarizes and links, never restates.
- **Layer the docs** — *canonical* (the working truth) vs *evidence* (raw/source material, may live outside the repo with a pointer) vs *tracker* (points to canonical, doesn't restate) vs *decisions* (one register).
- **Status header per doc** — `> Status / owner / date` so staleness is visible.
- **Verify links after every move** — a moved file's relative links and all inbound links both shift.

## Gotchas

- **Don't delete a file because it "looks unused."** Read it first. If it has unique content, fold that into the survivor before removing it. The orphan check flags *no-inbound-links*; that's a prompt to investigate, not a license to delete.
- **A move breaks links in two directions.** When you move `foo.md` into `sub/`, fix (a) everything that linked to `foo.md`, and (b) `foo.md`'s own links to peers, which now need `../`. Re-run the checker — don't eyeball it.
- **Merging is not concatenation.** When folding A into B, de-duplicate — drop A's sections that just restate B, keep only what's genuinely new. The point is *less* total content, not more.
- **Don't restate in the hub what the canonical doc owns.** The hub summarizes and links. If you copy the roadmap into the hub, you've created the next drift.
- **Confirm before destructive ops, even mid-run.** Approval of the plan is not blanket approval to delete the wrong thing — if reality differs from the plan, stop and surface it.
- **Shell builtins (`dirname`, `sed`) may be blocked in restricted sandboxes.** Use the python checker for link/orphan validation, not a bash one-liner.
- **Hard counts drift; prefer "a library of X" over "5 X".** When a summary/derived doc states a count ("5 title formulas") of something a canonical doc enumerates, the count goes stale the moment the canonical source grows. Reword to drop the number ("a library of title formulas") rather than chasing the count across files — a count mismatch between a summary and its source is a recurring drift mode, not a one-off.

## Rationalizations to reject

- *"The links probably still work after the move"* — run `check_docs.py` and confirm. Moves silently break relative paths.
- *"This file is small/old, just delete it"* — small ≠ contentless. Fold first, then delete.
- *"I'll consolidate the structure but skip re-reading the files"* — you can't merge what you haven't read; you'll drop unique content.
- *"Two docs covering the same topic is fine"* — that's the drift. Pick one canonical owner; make the other link.

## Completeness check

- [ ] `check_docs.py` returns clean (all links resolve, no new orphans)
- [ ] Zero stray references to any renamed/deleted file (grep confirms)
- [ ] Every deleted file's unique content was folded into a survivor (no context lost)
- [ ] The folder has one hub (`README.md`) and every file is reachable from it
- [ ] Before/after tree + changelog shown to the user
