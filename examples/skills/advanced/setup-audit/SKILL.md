---
name: setup-audit
description: Periodic Claude Code setup audit. Reviews CLAUDE.md bloat, settings.json security (CVE attack patterns, deprecated flags), accumulated permissions, MCP/skill inventory, hook safety, and version drift. Use when user says "audit my setup", "review my Claude Code config", "setup audit", "check my CLAUDE.md", for monthly maintenance, after Claude Code version bumps, or before a client handoff.
---

# Claude Code Setup Audit

A periodic health check for your Claude Code environment, not your codebase. Catches token bloat, accumulated drift, and security exposure that a normal code review will not see.

This skill checks Claude Code config only. Code health belongs in a normal code review or refactor pass, not here.

**Read-only by default.** This skill analyzes and reports. It does not edit `settings.json`, CLAUDE.md, or any skill files. The user reviews findings and acts.

## When to Use

- Monthly maintenance (default cadence)
- After each Claude Code version bump — CVEs are version-specific
- Before a client handoff (leaked secrets would be a very bad day)
- After clicking "Yes, don't ask again" repeatedly across a week of work
- When Claude starts "ignoring" a CLAUDE.md rule (usually a symptom of bloat)
- After installing any community skill, plugin, or MCP server (supply-chain check)

## Step 0: Cadence Check

Run this first. If the last audit was recent and no trigger happened, confirm the user actually wants to re-run.

```bash
LAST=~/.claude/.last-setup-audit
if [ -f "$LAST" ]; then
  LAST_DATE=$(cat "$LAST")
  DAYS=$(( ($(date +%s) - $(date -j -f "%Y-%m-%d" "$LAST_DATE" +%s 2>/dev/null)) / 86400 ))
  echo "Last audit: $LAST_DATE ($DAYS days ago)"
else
  echo "Last audit: never"
fi
```

At the end of the audit, write today's date:

```bash
date +%Y-%m-%d > ~/.claude/.last-setup-audit
```

## Step 1: CLAUDE.md Bloat Check

The #1 token hog. Cem Karaca's writeup documents a CLAUDE.md that grew to 1,207 lines / ~42,000 tokens, eating 40% of context before any work started.

```bash
# Line counts for every CLAUDE.md loaded this session
find ~/.claude -name "CLAUDE.md" 2>/dev/null | xargs wc -l 2>/dev/null
find . -name "CLAUDE.md" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | xargs wc -l 2>/dev/null

# Rough token estimate (1 token ≈ 4 chars)
find ~/.claude -name "CLAUDE.md" -exec wc -c {} \; 2>/dev/null | awk '{printf "~%d tokens: %s\n", $1/4, $2}'
```

**Thresholds:**
| File | Flag if over |
|---|---|
| `~/.claude/CLAUDE.md` (user global) | 150 lines |
| `.claude/CLAUDE.md` (project) | 100 lines |
| Total across all loaded files | 300 lines / ~12k tokens |

Also check `@references/` files imported by CLAUDE.md — they count toward the total.

## Step 2: The Six Questions (Rule Audit)

For every rule or section in each loaded CLAUDE.md, ask Jarod Taylor's six questions:

1. **Is this already default behavior?** Claude already writes clean code and tries not to apologize. Cut rules that state the obvious.
2. **Does it conflict with another rule?** Look for pairs like "be concise" + "always explain your reasoning."
3. **Is it redundant/duplicate?** Same rule phrased three ways is still one rule.
4. **Is it a bandaid fix?** A rule added because Claude did something bad *once*, now living forever in the context tax. Classic example: "don't use emojis" after one over-emoji response.
5. **Is it too vague to be actionable?** "Be more natural," "write clean code," "think carefully" — these don't guide behavior.
6. **Is it stale?** References a tool, path, skill, or framework that no longer exists.

Tag each rule as one of:
- **Universal** — applies everywhere → keep
- **Task-specific** — only matters for certain tasks → move to a skill
- **Deep-dive** — reference material → move to `references/` and `@`-import on demand
- **Obsolete** — cut it

Karaca's post-audit ratio was 15% universal, 60% task-specific, 15% deep-dive, 10% obsolete. If the user's ratio skews heavily task-specific, the fix is migrating to skills, not trimming prose.

## Step 3: settings.json Security Grep

Check Point Research documented specific attack vectors in `.claude/settings.json` (CVE-2025-59536, CVE-2026-21852). Grep for them:

```bash
for f in ~/.claude/settings.json ~/.claude/settings.local.json .claude/settings.json .claude/settings.local.json .mcp.json; do
  [ -f "$f" ] || continue
  echo "=== $f ==="
  grep -nE 'enableAllProjectMcpServers|ANTHROPIC_BASE_URL|dangerouslySkipPermissions|autoAllowBashIfSandboxed|SessionStart|skipDangerousModePermissionPrompt|--dangerously-skip-permissions' "$f" 2>/dev/null
done
```

**Red flags:**

| Pattern | Why it matters |
|---|---|
| `enableAllProjectMcpServers: true` | Auto-enables MCP servers before the trust warning fires |
| `ANTHROPIC_BASE_URL` in env | Can exfiltrate API key via plaintext Authorization header |
| `dangerouslySkipPermissions: true` / `--dangerously-skip-permissions` | Disables guardrails |
| `autoAllowBashIfSandboxed: true` | Auto-allows bash when sandboxed |
| `SessionStart` hook with `startup` matcher | Executes on project open, bypasses trust dialogs |
| `skipDangerousModePermissionPrompt: true` | Deprecated legacy flag — migrate to the newer permission modes |

**Also check:**
- `statusLine.command` — a malicious one could exfiltrate data. Verify the script path points to a file you wrote.
- `env` keys containing API tokens — prefer shell profile over committing them to settings.json.

**Before flagging anything from this step, consult the Accepted Exceptions Ledger below.** A finding that matches a ledger row is reported as "accepted (ledger)" in the report, not as an open finding.

### Accepted Exceptions Ledger

Findings the user has reviewed and accepted on purpose. The security greps in this step (and Steps 4 and 7) check hits against this table first. Report matches as "accepted (ledger)" with the decision date. Do NOT re-litigate them every audit.

| Finding | Decided by | Date | Re-open trigger |
|---|---|---|---|
| (example) `defaultMode: bypassPermissions` + `skipDangerousModePermissionPrompt` in settings.json | you | YYYY-MM-DD | Re-open if client work requires permission gating or this becomes a shared machine |

**Ledger maintenance rules:**
- Only the human adds or removes rows. The audit may propose a row when the user dismisses the same finding twice, but never writes one itself.
- Each audit, check every row's re-open trigger against current state. If a trigger condition now holds, the exception is void: report it as an open finding again.
- Once per quarter (any audit where the newest ledger date is 90+ days old), prompt: "Ledger review due: N accepted exceptions on file. Still valid?" and list the rows.

## Step 4: Permissions Drift

Accumulated "Yes, don't ask again" rules build up invisibly. Backslash's line: *"after a month, you may have dozens of invisible allow rules you never explicitly configured."*

```bash
for f in ~/.claude/settings.json .claude/settings.json .claude/settings.local.json; do
  [ -f "$f" ] || continue
  echo "=== $f allow rules ==="
  jq '.permissions.allow // empty' "$f" 2>/dev/null
done
```

For each entry:
- Do you remember adding it?
- Is it still needed?
- Is it over-broad? `Bash(curl:*)` is broader than `Bash(curl https://api.github.com/*)`.

**Per-project sweep.** Do not stop at cwd and global. Scan every project:

```bash
# All per-project settings.local.json files (all were deleted 2026-07-11)
for f in ~/Documents/projects/*/.claude/settings.local.json; do
  [ -f "$f" ] || continue
  echo "=== $f ==="
  jq '.permissions // empty' "$f" 2>/dev/null
done
```

Any file this finds is a flag: the baseline since 2026-07-11 is zero. A new `settings.local.json` means permission prompts are happening in that project and someone clicked "don't ask again". That is a signal to consolidate the rule deliberately (into project `settings.json` or the global allowlist), not to let per-project drift rebuild.

**Known issue:** deny rules are unreliable (anthropics/claude-code#18160). Do not treat `settings.json` deny lists as a security boundary — they may not be honored for Read/Write tools. Use allowlist + explicit revoke.

## Step 5: MCP Server Inventory

```bash
for f in ~/.claude/settings.json .mcp.json; do
  [ -f "$f" ] || continue
  echo "=== $f MCP servers ==="
  jq '.mcpServers // empty | keys' "$f" 2>/dev/null
done
```

**Context cost is mostly solved.** Current Claude Code builds defer MCP tool schemas via ToolSearch, so a long server list no longer eats context up front. Do not spend audit time counting tool-definition tokens.

**The check that still matters is scope placement.** For each server, ask: does it belong where it lives?
- **User scope** (`~/.claude/settings.json` or `~/.claude.json`) is for servers used across most projects (e.g. a meeting-notes server).
- **Project scope** (`.mcp.json` in one repo) is for servers only that project needs (e.g. a client's Notion integration).

Flag user-scope servers that only one project actually uses (move to that project's `.mcp.json`) and project-scope servers duplicated across several repos (promote to user scope). Still prune anything unused in the last 30 days.

## Step 6: Skill Inventory + Staleness

```bash
# Count skills
echo "User skills: $(ls ~/.claude/skills/ 2>/dev/null | wc -l)"
echo "Project skills: $(ls .claude/skills/ 2>/dev/null | wc -l)"

# Skills not touched in 90 days
find ~/.claude/skills -name "SKILL.md" -mtime +90 2>/dev/null
find .claude/skills -name "SKILL.md" -mtime +90 2>/dev/null
```

For each stale skill, ask:
- Does it overlap with another skill? (Two "debug" skills is a smell.)
- Is it referenced in CLAUDE.md or chained from another skill?
- Was it a one-off experiment?

**Archive before delete.** Move to `~/.claude/skills/_archive/` so the description no longer loads at session start but the skill is recoverable. Delete only after a second audit confirms it stayed untouched.

**Skill usage counts come from transcripts** (proven 2026-07-08 — no logging hook needed). Two greps, because Skill-tool calls and user-typed slash commands are recorded differently:

```bash
# Skill tool invocations (last 90 days)
find ~/.claude/projects -name "*.jsonl" -mtime -90 -size +1k 2>/dev/null | \
  xargs grep -ho '"skill":"[a-zA-Z0-9_-]*"' 2>/dev/null | sort | uniq -c | sort -rn
# User-typed slash commands
find ~/.claude/projects -name "*.jsonl" -mtime -90 -size +1k 2>/dev/null | \
  xargs grep -ho '<command-name>/[a-zA-Z0-9_-]*' 2>/dev/null | sed 's|.*<command-name>||' | sort | uniq -c | sort -rn
```

Skills with zero hits in both lists over 90 days are archive candidates — subject to the reference check above (a "dead" skill chained from a hook or another skill isn't dead; grep settings.json and other SKILL.md files before archiving).

## Step 6.5: Memory Hygiene

Memory rots without maintenance — stale facts, orphaned files, and index drift quietly poison recall. Check every project memory dir plus learnings files:

```bash
# Index caps: MEMORY.md loads only its first 200 lines OR 25KB (whichever first)
for d in ~/.claude/projects/*/memory; do
  [ -f "$d/MEMORY.md" ] || continue
  echo "$(wc -l < "$d/MEMORY.md" | tr -d ' ') lines  $(wc -c < "$d/MEMORY.md" | tr -d ' ') bytes  $(basename $(dirname "$d"))"
done | sort -rn -k2

# Orphans: files no index line points to are invisible to recall
for d in ~/.claude/projects/*/memory; do
  [ -f "$d/MEMORY.md" ] || continue
  ( cd "$d" && for f in *.md; do [ "$f" = MEMORY.md ] && continue
      grep -q "$f" MEMORY.md || echo "ORPHAN $(basename $(dirname $PWD)): $f"; done )
done

# Oversized learnings.md files (consolidate past ~250 lines)
find ~/Documents/projects -maxdepth 2 -name "learnings.md" -exec wc -l {} \; 2>/dev/null | sort -rn | head -5

# Uncommitted memory drift
cd ~/.claude && git status --short projects/ | wc -l
```

**Flags:** any MEMORY.md over 160 lines or 20KB (80% of the load cap); any orphans; duplicate section headers; learnings.md over 250 lines; a growing pile of uncommitted memory changes (wrap-up Step 6.5.4 should be catching these).

**Fix path:** run a consolidation pass — merge duplicates, index orphans, move fat content out of the index into topic files (verbatim — never summarize it away), convert relative dates to absolute, delete contradicted facts. Use `/consolidate-memory` if available, or say "consolidate my memory files" to trigger the native dream pass.

## Step 6.6: References Orphan Check

Every file in `~/.claude/references/` costs attention when someone scans the directory, and an unreferenced one is invisible at runtime: nothing loads it. Each file (excluding `_archive/`) should be reachable from `~/.claude/CLAUDE.md` (via `@references/` import or a lazy-load mention) or from a skill.

```bash
for f in ~/.claude/references/*.md; do
  name=$(basename "$f")
  hits=$(grep -rl "references/$name" ~/.claude/CLAUDE.md ~/.claude/skills/*/SKILL.md 2>/dev/null | wc -l | tr -d ' ')
  [ "$hits" = "0" ] && echo "ORPHAN: $name"
done
```

For each orphan: either add a pointer where it belongs (CLAUDE.md References section or the skill that uses it) or move it to `references/_archive/`. An orphaned reference file is documentation nobody can find.

## Step 6.7: Artifact Growth + Public-Repo Leak Check

Hooks and sessions generate files that grow silently. Three checks:

**1. Compaction archives.** `pre-compact.sh` copies the raw transcript to `<project>/.claude/compaction-archives/` on every compaction, with a 30-day retention sweep inside the hook. Verify the retention is holding:

```bash
# Total size across projects (warn above 200MB)
du -shc ~/Documents/projects/*/.claude/compaction-archives 2>/dev/null | tail -1
# Anything older than 30 days means the retention sweep is not running
find ~/Documents/projects/*/.claude/compaction-archives -name 'transcript-*.jsonl' -mtime +30 2>/dev/null
```

**2. Session transcript store.** Report only, no threshold: this is Claude Code's own data, useful for the transcript greps in Steps 6 and 7.5.

```bash
du -sh ~/.claude/projects/ 2>/dev/null
```

**3. Public-repo meta-file leak.** Living ops files (HANDOVER.md, learnings.md, work logs, brainstorms) publish in-flight state and must never be tracked in a public repo. The 2026-07-11 audit found two live leaks this way. For each repo whose GitHub remote is public:

```bash
for d in ~/Documents/projects/*/; do
  [ -d "$d/.git" ] || continue
  repo=$(cd "$d" && gh repo view --json visibility -q .visibility 2>/dev/null)
  [ "$repo" = "PUBLIC" ] || continue
  hits=$(cd "$d" && git ls-files | grep -E '(^|/)(HANDOVER\.md|learnings\.md|brainstorms/)|\.claude/work-logs' )
  [ -n "$hits" ] && printf 'LEAK in %s:\n%s\n' "$d" "$hits"
done
```

Any hit is a **Critical** finding: remove the file from tracking, then decide whether git history needs scrubbing (it usually does if the file held session state or client names).

## Step 7: Hook Safety Review

Hooks run arbitrary commands at well-known lifecycle events. Audit every hook:

```bash
for f in ~/.claude/settings.json .claude/settings.json; do
  [ -f "$f" ] || continue
  echo "=== $f hooks ==="
  jq '.hooks // empty' "$f" 2>/dev/null
done
```

**Red flags in hook command strings:**
- `curl ... | bash` or `wget ... | sh` (remote code execution)
- `eval` with any unvalidated variable
- stdin JSON fields (`.tool_input.command`, `.prompt`, `.tool_response`) piped into a shell without quoting
- Writes to `~/.ssh`, `~/.gnupg`, `~/.aws`, or any credential path
- Any command line containing `API_KEY`, `TOKEN`, `PASSWORD`, `SECRET` (leaks via process list)

Tim McAllister's framing: hooks are "pattern-matching shell scripts, not a security boundary." Useful speed bumps, but not a substitute for not running untrusted code.

## Step 7.5: Hook Effectiveness (Warn-Only Conversion)

Safety asks "can this hook hurt us?" Effectiveness asks "does this hook do anything?" A warn-only hook that fires constantly and never changes behavior is ceremony: it costs a process spawn per event and trains everyone to ignore hook output. The 2026-07-11 audit found 6 such hooks and deleted 5; this check keeps them from creeping back.

For each **non-blocking** hook in settings.json (echoes advice and exits 0, rather than exit 2 or a `"decision":"block"`), measure conversion from recent transcripts:

1. **Fires:** grep the hook's message text in recent session transcripts.
2. **Conversions:** grep for the skill or action the message suggests being invoked afterward.

```bash
# Example, for the high-stakes UserPromptSubmit warning that suggests /pre-implement:
# 1. How often did it fire? (use a distinctive substring of the hook's echoed message)
find ~/.claude/projects -name "*.jsonl" -mtime -90 -size +1k 2>/dev/null | \
  xargs grep -l 'High-stakes task detected' 2>/dev/null | wc -l
# 2. In how many of those same sessions was the suggested action taken?
find ~/.claude/projects -name "*.jsonl" -mtime -90 -size +1k 2>/dev/null | \
  xargs grep -l 'High-stakes task detected' 2>/dev/null | \
  xargs grep -l '"skill":"pre-implement"\|<command-name>/pre-implement' 2>/dev/null | wc -l
```

Session-level counting (grep -l, then compare file lists) beats raw hit counting: one session where the warning fired 5 times and the skill ran once is a conversion, not 20% of one.

**Verdicts:**
- Fires often (10+ sessions), converts near zero: ceremony. Flag for deletion.
- Fires rarely: fine, leave it, low cost.
- Fires and converts: keep, it earns its process spawn.
- Blocking hooks are exempt from this check. They enforce rather than suggest, so "conversion" is built in. Audit those in Step 7 only.

## Step 8: Claude Code Version Check

```bash
claude --version 2>/dev/null
```

Compare against the [Claude Code changelog](https://docs.claude.com/en/docs/claude-code/changelog). Flag any security-related entries since the last audit. The v2.1.90 deny-rule bypass fix (post-source-leak) is the canonical example of why version drift matters in a way `npm audit` doesn't cover.

Also suggest the user run `/doctor` in their next session if the built-in diagnostic hasn't run recently.

## Output Format

Produce a report with two cuts: **buckets** (sam-illingworth's taxonomy) and **priority** (Critical / High / Medium).

```markdown
## Claude Code Setup Audit

**Date:** YYYY-MM-DD
**Days since last audit:** X
**Claude Code version:** X.Y.Z
**Overall:** Clean / Drift detected / Action required

### Findings by Bucket

**Adopt** — new best practices to add:
- [specific item]

**Improve** — existing things to sharpen:
- [specific item + file:line]

**Remove** — cut for token or clarity wins:
- [specific item + file:line]

**Security** — anything from Step 3, 4, 6.7, 7:
- [specific item]

**Accepted (ledger)** — matched a row in the Accepted Exceptions Ledger; no action unless a re-open trigger fired:
- [finding + ledger date]

**Parked** — noted but not acting on now:
- [specific item + why]

### Findings by Priority

**Critical** (now — security or broken setup):
1. [action]

**High** (this week — drift or bloat affecting quality):
1. [action]

**Medium** (this month — polish):
1. [action]

### Stats

| Check | Value | Threshold | Status |
|---|---|---|---|
| User CLAUDE.md lines | X | 150 | ok / flag |
| Project CLAUDE.md lines | X | 100 | ok / flag |
| Total allow rules | X | — | review |
| MCP servers | X | 5 | ok / flag |
| User skills | X | — | info |
| Stale skills (>90d) | X | — | review |
| Skills unused 90d (transcript grep) | X | — | archive candidates |
| Largest MEMORY.md | X bytes | 20KB (80% of cap) | ok / consolidate |
| Memory orphans | X | 0 | ok / flag |
| learnings.md over 250 lines | X | 0 | ok / consolidate |
| Uncommitted memory changes | X | ~0 | ok / flag |
| Hooks flagged | X | 0 | ok / flag |
| Warn-only hooks with near-zero conversion | X | 0 | ok / delete |
| Per-project settings.local.json files | X | 0 | ok / consolidate |
| References orphans | X | 0 | ok / flag |
| Compaction archives total size | X MB | 200MB | ok / flag |
| ~/.claude/projects/ total size | X | — | info |
| Public-repo meta-file leaks | X | 0 | ok / CRITICAL |
| Ledger exceptions on file | X | — | review quarterly |
| CVE patterns found | X | 0 | ok / flag |
```

After producing the report, write the timestamp:

```bash
date +%Y-%m-%d > ~/.claude/.last-setup-audit
```

## Anti-patterns

- **Don't trim CLAUDE.md blind.** HN user dataviz1000 benchmarked aggressive trimming across 30 coding tasks and found it *worsened* results. Before cutting >20% of any CLAUDE.md, run 3-5 representative tasks on both versions and compare. The golden rule applies: don't skip planning.
- **Don't trust deny rules for security.** They're unreliable. Use allowlist + revoke.
- **Don't delete stale skills on the first audit.** Archive to `_archive/`, re-audit next month, delete if still untouched.
- **Don't run this every session.** Output gets boring, findings feel routine, you'll start ignoring them. Monthly + triggered is the sweet spot.
- **Don't edit files during the audit.** This skill reports. The user decides and acts. (Exception: the `.last-setup-audit` timestamp file.)

## Integration with Other Skills

| This skill found | Run next |
|---|---|
| Codebase tech debt noticed during audit | Note it in that project's ROADMAP.md; handle in a code session |
| CLAUDE.md rule is vague or a bandaid | Rewrite inline, or flag via `/compound` |
| Stale skills | Manual archive (not automated) |
| CVE pattern matched | Stop and fix before continuing the session |
| Skill inventory growing fast | `/compound` to dedupe learnings feeding skill creation |

## Sources

- Cem Karaca, "My CLAUDE.md Was Eating 42,000 Tokens Per Conversation"
- Jarod Taylor, CLAUDE-CODE-SETUP-AUDIT gist (six questions)
- sam-illingworth/audit-setup (bucket taxonomy)
- Check Point Research, CVE-2025-59536 and CVE-2026-21852
- Tim McAllister, "Hardening Claude Code" (hook safety)
- Druce.ai, "Speedrunning the Claude Code learning curve" (MCP 10% threshold, context 50% degradation)
- anthropics/claude-code#18160 (deny rules unreliable)
- Backslash, "Claude Code security best practices" (permissions drift)
