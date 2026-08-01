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

## Step 1.5: Harness Truth Check

Step 1 asks whether a file is too big. This asks whether it is lying, which is the failure
that actually bites: a "volatile state stays out of prose" rule can be written down and still
violated across half a dozen files. Discipline does not hold, so this part is mechanical.

This needs a linter you write once and keep at zero findings. Point it at every CLAUDE.md, every
SKILL.md, `~/.claude/references/`, and every project's memory layer:

```bash
python3 ~/.claude/scripts/harness-lint.py
```

Six checks, no judgment in any of them:

| Check | Catches | Scope |
|---|---|---|
| `dead-pointer` | a referenced path or `/skill-name` that does not resolve | all |
| `dead-wikilink` | a `[[link]]` in a memory file resolving to nothing | memory |
| `dead-section` | a quoted section name the named file does not have | all |
| `visibility` | a PUBLIC/PRIVATE claim that disagrees with `gh repo view` | CLAUDE.md |
| `stale-status` | a line restating something the sibling ROADMAP.md marks done | CLAUDE.md |
| `location` | a root CLAUDE.md outside the two documented exceptions | CLAUDE.md |

Exit 0 clean, 1 findings, 2 the linter itself broke. Treat exit 2 as a failed audit step, never
as a pass.

**This should normally report zero.** The same checks run on every write to a harness file via
the `PostToolUse` hook `~/.claude/hooks/harness-lint-check.sh`, which blocks. A non-zero count
here means drift arrived some way the hook cannot see: a file edited outside Claude Code, a
target deleted after the reference was written, or a new false-positive class. Findings in the
second category are the useful ones, since nothing else catches a reference broken by a change
somewhere else.

It says nothing about length, tone, or whether content still earns its place. Those need a human
read against `~/.claude/references/claude-md-templates.md`. **Exit 0 means "nothing checkably
false", not "this file is good."**

**Budget for exemptions from the start.** Every real setup has deliberate violations — an
Obsidian vault keeps its CLAUDE.md at the repo root because Obsidian cannot index dotfolders, a
CLAUDE.md that is only an `@AGENTS.md` shim stays beside what it imports — and lines describing a
former or external thing are history notes, not claims ("(was `contacts/`)"). A linter that fires
on these gets bypassed, and then it protects nothing. Fix the false-positive class, never the
finding.

Note that a public template repo full of placeholder paths (like this guide's `examples/`) is
itself an exemption case: those paths are fictional by design.

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

The `Source` column says which check raises the finding. Rows sourced from another skill record a standing decline of that skill's proposal, so the proposal is answered once here instead of every time it appears.

| Finding | Source | Decided by | Date | Re-open trigger |
|---|---|---|---|---|
| (example) `defaultMode: bypassPermissions` + `skipDangerousModePermissionPrompt` in settings.json | Step 3 | you | YYYY-MM-DD | Re-open if client work requires permission gating or this becomes a shared machine |
| (example) `SessionStart` hook that surfaces HANDOVER.md after a compact or resume | Step 3 | you | YYYY-MM-DD | Re-open if the hook's command string changes |
| (example) Proposal to replace `bypassPermissions` with auto mode, raised by the native `/doctor` check that audits the default permission mode | `/doctor` | you | YYYY-MM-DD | Re-open together with the `bypassPermissions` row above. Auto mode is the likely destination if that row's trigger ever fires, so do not disable auto mode at the settings level to silence the proposal |

Start this table empty. The rows above show the shape; replace them with your own decisions.

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
# All per-project settings.local.json files.
# find, not a bare glob: under zsh an unmatched glob aborts with "no matches found"
# instead of running zero times, so the clean case would read as an error. Verified
# 2026-07-28, after the last matching file was removed and the glob form started failing.
find ~/Documents/projects -maxdepth 3 -path '*/.claude/settings.local.json' 2>/dev/null | while read -r f; do
  echo "=== $f ==="
  jq '.permissions // empty' "$f" 2>/dev/null
done
```

Any file this finds is a flag: the baseline since 2026-07-11 is zero. A new `settings.local.json` means permission prompts are happening in that project and someone clicked "don't ask again". That is a signal to consolidate the rule deliberately (into project `settings.json` or the global allowlist), not to let per-project drift rebuild.

**The native `/doctor` writes to this same path.** Its check 9 aggregates denied read-only commands and proposes allow rules, and the destination it uses is exactly the file this sweep flags. Today that check is inert here: it harvests denials from permission prompts, and `bypassPermissions` produces none (verified 2026-07-28, 20 denials in the window, all `permission-rule` from blocking hooks, zero `user-rejected`). **Re-open trigger: `defaultMode` ever leaves `bypassPermissions`.** At that point check 9 gains fuel, and this baseline needs a rule for rules it wrote itself rather than a blanket flag.

**Interpreter and destructive wildcards are High severity, not Medium.** `python3:*`, `node:*`, `npx:*`, and `rm:*` put arbitrary execution or deletion behind one standing pre-approval. Check 9 refuses to propose that class at all, so anything of this shape arrived by a human clicking through a prompt. These also come back: a file carrying `python3:*` and `rm:*` once reappeared four days after the baseline reset that was supposed to clear it.

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

### Forked-skill upstream drift

Any skill you forked from someone else's repo drifts. The `/humanizer` skill here is a fork of `blader/humanizer`, which ships in roughly monthly bursts; three releases once went unnoticed until the next manual look.

Keep a pin file recording the upstream commit you last reviewed, and check it on every audit: fetch upstream, diff `SKILL.md` since the pin, and review each change take-or-skip before advancing the pin. Make advancing the pin a separate explicit flag — re-pinning on sight turns the check into a rubber stamp. A failed check (network, missing tools) is not evidence about upstream, so give it a distinct exit code. GitHub release-watch on the upstream repo is the primary signal; this step is the backstop for when that email gets buried.

### Duplicated-rule drift

Any rule file you keep in one canonical place and copy into several repos will drift. Pick the direction of truth once, script the copy, and give the script a `--check` mode that the audit runs. Exit non-zero listing the drifted repos. If a copy holds an improvement, port it back to the source first, then re-sync — never let the copy win silently.

**Skill usage counts come from transcripts** (proven 2026-07-08 — no logging hook needed). Two greps, because Skill-tool calls and user-typed slash commands are recorded differently:

```bash
# Skill tool invocations (last 90 days)
find ~/.claude/projects -name "*.jsonl" -mtime -90 -size +1k 2>/dev/null | \
  xargs grep -ho '"skill":"[a-zA-Z0-9_:.-]*"' 2>/dev/null | sort | uniq -c | sort -rn
# User-typed slash commands
find ~/.claude/projects -name "*.jsonl" -mtime -90 -size +1k 2>/dev/null | \
  xargs grep -ho '<command-name>/[a-zA-Z0-9_:.-]*' 2>/dev/null | sed 's|.*<command-name>||' | sort | uniq -c | sort -rn
```

**The colon in those character classes is load-bearing.** Skills delivered by a plugin are named `plugin:skill`, and a class without `:` cannot match one, so it returns zero for every plugin skill no matter how often it runs. Under the archive rule below, that made all of them permanent false candidates. Verified 2026-07-28: the old pattern found 0 namespaced skills over 90 days, the fixed pattern found 3. A probe that structurally cannot match reports absence, not evidence.

Skills with zero hits in both lists over 90 days are archive candidates — subject to the reference check above (a "dead" skill chained from a hook or another skill isn't dead; grep settings.json and other SKILL.md files before archiving).

### Plugins

A plugin bundles skills, commands, hooks, and MCP servers together, so an unused one costs listing entries plus a thing to keep authenticated and updated. `enabledPlugins` in settings is **not** an inventory: it records only what was enabled at user scope, and most installed plugins never appear there. Use the usage counter.

```bash
# Lifetime plugin usage, summed across marketplace keys
jq -r '.pluginUsage // {} | to_entries[] | "\(.key|split("@")[0])\t\(.value.usageCount // 0)"' ~/.claude.json 2>/dev/null | \
  awk -F'\t' '{n[$1]+=$2} END {for (p in n) printf "%6d  %s\n", n[p], p}' | sort -rn
```

**Sum across marketplace keys or the answer is wrong.** The same plugin is counted once per marketplace it was installed from, so a per-key read splits one plugin into two rows and makes the smaller one look abandoned. As of 2026-07-28 `slack` read 354 under one key and 13 under the other, against 367 combined.

**`usageCount` is a lifetime total, never windowed.** It answers "was this ever used", not "was this used recently". Window evidence comes from the Step 6 transcript grep above, where plugin skills appear as `plugin:skill`, which is the other reason the colon fix matters.

**`lastUsedAt` is not usage evidence.** It is seeded when the plugin is installed or enabled and refreshed on re-enable, so for a plugin sitting at zero it records arrival, not use.

A plugin at a lifetime zero is an archive candidate on the same terms as a skill. Disabling is reversible.

## Step 6.5: Memory Hygiene

Memory rots without maintenance — stale facts, orphaned files, and index drift quietly poison recall. Check every project memory dir plus learnings files:

```bash
# Index caps: MEMORY.md loads only its first 200 lines OR 25KB (whichever first)
for d in ~/.claude/projects/*/memory; do
  [ -f "$d/MEMORY.md" ] || continue
  echo "$(wc -l < "$d/MEMORY.md" | tr -d ' ') lines  $(wc -c < "$d/MEMORY.md" | tr -d ' ') bytes  $(basename $(dirname "$d"))"
done | sort -rn -k2

# Orphans: files no index line points to are invisible to recall.
# A redirect stub is NOT an orphan. MEMORY.md states that unlisted files are deliberate
# stubs whose content moved to brain/topics/ or a reference, and says not to re-index them.
# Without this exclusion the check reported all 21 stubs as orphans, and that false finding
# survived three audits (5 "orphans" on 07-11, 22 on 07-25) before anyone opened the files.
for d in ~/.claude/projects/*/memory; do
  [ -f "$d/MEMORY.md" ] || continue
  ( cd "$d" && for f in *.md; do [ "$f" = MEMORY.md ] && continue
      grep -q "$f" MEMORY.md && continue
      grep -qiE "moved to|absorbed into|redirect stub|→ *promoted to" "$f" && continue
      echo "ORPHAN $(basename $(dirname $PWD)): $f"; done )
done

# Oversized learnings.md files (consolidate past ~250 lines)
find ~/Documents/projects -maxdepth 2 -name "learnings.md" -exec wc -l {} \; 2>/dev/null | sort -rn | head -5

# Uncommitted memory drift
cd ~/.claude && git status --short projects/ | wc -l

# Memory belonging to a dead project (the demotion trigger). Match on the encoded dir name,
# which is the path with BOTH "/" and "_" turned into "-": a project dir named my_project
# encodes as ...-projects-my-project. Comparing against literal names reports every project
# with an underscore in it as an orphan.
python3 - <<'EOF'
from pathlib import Path
ws = Path.home()/"Documents"/"claude"; proj = Path.home()/".claude"/"projects"
enc = lambda s: s.replace("/", "-").replace("_", "-")
live = {enc(p.name) for p in ws.iterdir() if p.is_dir() and p.name != "_archive"}
arch = {enc(p.name) for p in (ws/"_archive").iterdir() if p.is_dir()} if (ws/"_archive").is_dir() else set()
for d in sorted(proj.iterdir()):
    files = list((d/"memory").glob("*.md")) if (d/"memory").is_dir() else []
    if not files: continue
    if any(d.name.endswith("-"+c) for c in live): continue
    hit = next((c for c in arch if d.name.endswith("-"+c)), None)
    print(f"  DEAD PROJECT MEMORY: {d.name} ({len(files)} files)"
          f"{' -> _archive/'+hit if hit else ' -> no project dir at all'}")
EOF
```

**Flags:** any MEMORY.md over 160 lines or 20KB (80% of the load cap); any orphans; duplicate section headers; learnings.md over 250 lines; a growing pile of uncommitted memory changes (wrap-up Step 6.5.4 should be catching these).

**Fix path:** run a consolidation pass — merge duplicates, index orphans, move fat content out of the index into topic files (verbatim — never summarize it away), convert relative dates to absolute, delete contradicted facts. Say "consolidate my memory files" to trigger the native dream pass.

**Dead-project memory is a separate fix, and it is not a delete.** Per the demotion rule in `~/.claude/references/memory-system.md`, a project moving to `_archive/` collapses its memory to a stub. Before collapsing, read the files: some hold cross-project knowledge that outlives the project and should be promoted to home memory or `brain/topics/` first. Deleting them wholesale loses that. The probe above is the live list, so do not restate its output here; naming specific projects in this file would go stale the moment they are collapsed. Get the user's call before collapsing any new one.

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
  hits=$(cd "$d" && git ls-files | grep -E '(^|/)(HANDOVER( [0-9]+| \([0-9]+\))?\.md|learnings( [0-9]+| \([0-9]+\))?\.md|brainstorms/)|\.claude/work-logs' )
  [ -n "$hits" ] && printf 'LEAK in %s:\n%s\n' "$d" "$hits"
done
```

Any hit is a **Critical** finding: remove the file from tracking, then decide whether git history needs scrubbing (it usually does if the file held session state or client names).

**Control-tested 2026-07-29, both directions.** A fixture repo under `~/Documents/projects/` with a public remote, holding `HANDOVER.md`, `docs/HANDOVER.md`, `learnings.md`, `brainstorms/`, and `.claude/work-logs/`: every one surfaced. Removed, and the probe went silent with a clean exit, so the empty case is covered too. Five decoys (`README.md`, `docs/handover-notes.md`, `learnings-format.md`, `docs/HANDOVER-template.md`, `CHANGELOG.md`) stayed silent in both runs. Note the fixture needs no push: `git ls-files` reads the index, so staging is enough and nothing is ever published.

**The regex was widened as a result.** The original used exact names and therefore missed cloud-sync conflict copies, so a tracked `HANDOVER 2.md` in a public repo read as clean. That is the same failure `learning_gitignore-conflict-copies-and-overbroad.md` recorded on 2026-07-25, when the gitignore block was globbed for this exact reason; this probe was not updated at the same time. The pattern now also matches ` 2` and ` (1)` suffixes, deliberately narrow rather than `HANDOVER.*\.md`, which would fire on legitimate template and format docs.

**Two known blind spots, both still open.** A public repo with no local clone is invisible, since the loop globs `~/Documents/projects/*/` (both public repos are cloned today, so this is latent). And a lowercase `handover.md` would not match; it cannot be tested on macOS, where the case-insensitive filesystem collapses it into `HANDOVER.md`, but a repo cloned on Linux could carry both.

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
# Substitute FIRED with a distinctive substring of the hook's echoed message.
# The example below measures a hook that suggests running pre-implement.
# 1. How often did it fire?
find ~/.claude/projects -name "*.jsonl" -mtime -90 -size +1k 2>/dev/null | \
  xargs grep -l 'FIRED' 2>/dev/null | wc -l
# 2. In how many of those same sessions was the suggested action taken?
find ~/.claude/projects -name "*.jsonl" -mtime -90 -size +1k 2>/dev/null | \
  xargs grep -l 'FIRED' 2>/dev/null | \
  xargs grep -l '"skill":"pre-implement"\|<command-name>/pre-implement' 2>/dev/null | wc -l
```

If the suggested action is delivered by a plugin, its name carries a colon (`plugin:skill`), so match that exact string rather than the bare name.

Session-level counting (grep -l, then compare file lists) beats raw hit counting: one session where the warning fired 5 times and the skill ran once is a conversion, not 20% of one.

This step used to hard-code the high-stakes planning nudge as its worked example. That hook was retired 2026-07-25 after firing in 71 sessions and converting in 5, which is this check doing its job, so the example is now a template rather than a pointer at something that no longer exists.

**Verdicts:**
- Fires often (10+ sessions), converts near zero: ceremony. Flag for deletion.
- Fires rarely: fine, leave it, low cost.
- Fires and converts: keep, it earns its process spawn.
- Blocking hooks are exempt from this check. They enforce rather than suggest, so "conversion" is built in. Audit those in Step 7 only.

## Step 8: Claude Code Version Check

```bash
claude --version 2>/dev/null
```

The report header needs that number. **Whether it is the newest available is not this step's job.** The native `/doctor` resolves the release channel and compares against the right endpoint for the install type, including the Homebrew case where the cask name picks the channel instead of settings. A second implementation here would drift against it silently.

What this step owns is the part `/doctor` does not do: read the [Claude Code changelog](https://docs.claude.com/en/docs/claude-code/changelog) and flag security-related entries since the last audit. The v2.1.90 deny-rule bypass fix (post-source-leak) is the canonical example of why version drift matters in a way `npm audit` doesn't cover.

**When the version moved since the last audit, re-read the `/doctor` rows** in the Accepted Exceptions Ledger and in the division of labor below. `/doctor` ships inside the binary, so its check numbering, skip conditions, and destinations can change with any release, and no local check can detect that. The changelog read is the only moment this setup would notice.

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
| Plugins installed | X | — | info |
| Plugins at lifetime zero use | X | 0 | archive candidates |
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

- **Don't trim CLAUDE.md blind.** HN user dataviz1000 benchmarked aggressive trimming across 30 coding tasks and found it *worsened* results. Before cutting >20% of any CLAUDE.md, run 3-5 representative tasks on both versions and compare. The golden rule from your CLAUDE.md applies: don't skip planning.
- **Don't trust deny rules for security.** They're unreliable. Use allowlist + revoke.
- **Don't delete stale skills on the first audit.** Archive to `_archive/`, re-audit next month, delete if still untouched.
- **Don't run this every session.** Output gets boring, findings feel routine, you'll start ignoring them. Monthly + triggered is the sweet spot.
- **Don't edit files during the audit.** This skill reports. The user decides and acts. (Exception: the `.last-setup-audit` timestamp file.)

## Division of labor with the native `/doctor`

`/doctor` is a preset skill compiled into the Claude Code binary, not an installed one, so it updates when Claude Code does and cannot be edited here. It optimizes the harness and applies fixes behind confirmation gates. This skill polices the harness and edits nothing. The overlap is smaller than the names suggest, because in most shared areas the two ask different questions of the same object.

| Area | `/doctor` asks | This skill asks |
|---|---|---|
| CLAUDE.md | Is it derivable from the code? Can it be lazy-loaded? | Is it too long? Is it checkably false? (Step 1.5) |
| Hooks | Does it block the loop? (timing from transcripts) | Can it hurt us? (Step 7) Does it convert? (Step 7.5) |
| Permissions | What should be added so prompts stop | What accumulated that should not have (Step 4) |
| MCP | Is it unused? | Is it in the right scope? (Step 5) |
| Extensions | Lifetime usage counters, current project | 90-day window, every project (Step 6) |
| Version | Is it current? | Did anything security-related ship? (Step 8) |

**Only `/doctor` covers**: installation health (duplicate installs, PATH, unparseable settings files), colliding agent definitions, hook timing, and migrating always-loaded content to lazy loading.

**Only this skill covers**: the CVE grep, hook command safety, memory hygiene, references orphans, public-repo meta-file leaks, harness-lint, and every cross-project sweep. `/doctor` edits project files in the current directory only, which is why the sweeps stay here.

**Standing declines** (see the Accepted Exceptions Ledger): its auto-mode proposal is answered there once. Its allow-rule proposal is inert while `defaultMode` is `bypassPermissions`, because there are no prompt denials to harvest.

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
