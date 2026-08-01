# Hooks

> **Revision note (July 2026).** The live config this guide mirrors was audited against 90 days of real transcripts. Five of the warn-only reminder hooks below (commit reminder, deploy reminder, error-string suggestion, and two of the prompt-keyword nudges) fired for months with near-zero conversion: the reminders were read and ignored. They were removed from the live config and survive here as construction examples. The lesson travels with them: warn-only hooks need periodic effectiveness checks (message fired vs. suggestion followed), or they decay into noise the user learns to skip. Blocking hooks (force-push guard) and acting hooks (prose check, pre-compaction save) all survived the same audit.

## What Are Hooks?

Hooks are shell commands that execute automatically before or after Claude uses a tool, or when the user submits a prompt. They let you enforce rules, add reminders, and block dangerous operations without relying on Claude to remember every policy.

There are three hook types:

- **PreToolUse**: Runs before Claude executes a tool. Can block the tool call.
- **PostToolUse**: Runs after Claude executes a tool. Can inspect the result and provide feedback.
- **UserPromptSubmit**: Runs when the user submits a message. Can surface contextual reminders based on what the user typed.

Hooks run as shell commands on your machine. They are not prompts or AI instructions -- they are actual scripts that execute in your shell.

## Where Hooks Are Configured

Hooks live in your `settings.json` file under the `"hooks"` key. You can configure them at the global level (`~/.claude/settings.json`) or the project level (`{project}/.claude/settings.json`).

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "your shell command here"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "your shell command here"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "your shell command here"
          }
        ]
      }
    ]
  }
}
```

**Key fields:**

| Field | Purpose |
|-------|---------|
| `matcher` | The tool name to match (e.g., `"Bash"`, `"Write"`, `"Edit"`). The hook only runs when this tool is used. Not used for UserPromptSubmit. |
| `type` | Always `"command"` for shell hooks. |
| `command` | The shell command to execute. |

## Hook Input

Hooks receive a JSON object on **stdin**. Parse it with `jq`. There are no `$TOOL_INPUT` or `$USER_PROMPT` environment variables, and there never were. (Earlier versions of this guide claimed otherwise. Every example below has been corrected.)

| Hook | Field you want | Extract with |
|------|----------------|--------------|
| PreToolUse on Bash | the command about to run | `jq -r '.tool_input.command // ""'` |
| PostToolUse | the tool's result | `jq -r '.tool_response // ""'` |
| PostToolUse on Write/Edit | the file that was written | `jq -r '.tool_input.file_path // ""'` |
| UserPromptSubmit | the text the user typed | `jq -r '.prompt // ""'` |

Every payload also carries `session_id`, `transcript_path`, `cwd`, `permission_mode`, and `hook_event_name`. The environment variables Claude Code does set are `$CLAUDE_PROJECT_DIR`, `$CLAUDE_PLUGIN_ROOT`, `$CLAUDE_PLUGIN_DATA`, `$CLAUDE_EFFORT`, and `$CLAUDE_CODE_REMOTE`. Those carry context, not hook input.

Since stdin can only be read once, capture it first if you need more than one field:

```bash
input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // ""')
dir=$(echo "$input" | jq -r '.cwd // ""')
```

Full schemas: [hooks reference](https://code.claude.com/docs/en/hooks.md).

## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Pass. The tool call proceeds normally. |
| `2` | Block. The tool call is prevented from executing (PreToolUse only). |

Any output your hook prints to stdout is shown to Claude as feedback.

## Global vs Project-Level Hooks

**Global hooks** (`~/.claude/settings.json`) fire on every project. Use these for universal rules that always apply: blocking force pushes, reminding about docs before commits, detecting errors, surfacing workflow suggestions.

**Project-level hooks** (`{project}/.claude/settings.json`) fire only in that project. Use these for domain-specific rules: Firebase planning reminders in a Firebase project, specific linting in a particular codebase.

**Rule of thumb:** If a hook would be noisy in most projects (e.g., triggering on common words like "sync" or "state"), make it project-level.

---

## What `examples/hooks-examples.json` Actually Ships

**Read this before running `install.sh --full`.** That flag merges `hooks-examples.json` into your
`~/.claude/settings.json`. Most of its entries are not inline shell — they call scripts by path,
and **this repo does not ship those scripts**:

| Event | Command | Shipped here? |
|---|---|---|
| `PreToolUse` | inline force-push / push-to-main guard | Yes, inline |
| `PreToolUse` | `~/.claude/hooks/repo-visibility-guard.py` | No |
| `PostToolUse` | `~/.claude/hooks/humanizer-check.sh` | No |
| `PostToolUse` | `~/.claude/hooks/harness-lint-check.sh` | No |
| `PreCompact` | `~/.claude/hooks/pre-compact.sh` | No |
| `SessionStart` | `~/.claude/hooks/session-start.sh` | No |
| `SessionStart` | `~/.claude/hooks/audit-reminder.sh` | No |

A hook whose command is a path to a file that does not exist fails on every fire. After
`--full`, either write the scripts or delete the entries you have no script for. The inline
force-push guard is the one that works standalone.

What each absent script does in the config this guide mirrors, if you want to write your own:

- **`repo-visibility-guard.py`** — blocks writes of session/meta files (`HANDOVER.md`,
  `learnings.md`, work logs, brainstorms) into a repo whose GitHub remote is public.
- **`humanizer-check.sh`** — greps written prose against the `/humanizer` skill's
  `ban-list.txt` and blocks on a hit. The skill and the hook read the same list file, so there
  is no second copy to keep in sync.
- **`harness-lint-check.sh`** — runs a reference linter on every written `CLAUDE.md`,
  `SKILL.md`, or memory file and blocks on a dead path, skill name, or section reference.
  See `/setup-audit` Step 1.5.
- **`pre-compact.sh`** — archives the transcript and writes a HANDOVER.md summary before
  compaction, unless a manual `/checkpoint` is already fresh.
- **`session-start.sh`** — surfaces a recent HANDOVER.md after a compact or resume.
- **`audit-reminder.sh`** — nudges when `/setup-audit` last ran more than a month ago.

**The general lesson:** a hook that names a path is a dependency. Ship the script with the
config or the config is broken on arrival — this repo documented seven hooks with the wrong
input mechanism once, and every one of them failed silently for readers.

---

## Hook Examples

### 1. Commit Reminder (PreToolUse on Bash)

Watches for `git commit` or `git push` and reminds you to run `/harden`, `/test-gaps`, and `/docs-sync` first. Always exits 0 so it never blocks -- it only surfaces a reminder when staged files exist.

```json
{
  "matcher": "Bash",
  "hooks": [
    {
      "type": "command",
      "command": "cmd=$(jq -r '.tool_input.command // \"\"'); if echo \"$cmd\" | grep -qE 'git commit|git push'; then staged=$(git diff --cached --name-only 2>/dev/null); if [ -n \"$staged\" ]; then echo 'Reminder: Run /harden, /test-gaps, and /docs-sync before committing if you have not already.'; fi; fi; exit 0"
    }
  ]
}
```

### 2. Force Push Blocker (PreToolUse on Bash)

Blocks force pushes and direct pushes to main/master. Matches three patterns (`push main`, `push master`, `push --force/-f`) and exits 2 to prevent the command from running.

```json
{
  "matcher": "Bash",
  "hooks": [
    {
      "type": "command",
      "command": "cmd=$(jq -r '.tool_input.command // \"\"'); if echo \"$cmd\" | grep -qE 'git push.*(main|master)|git push -f|git push --force'; then echo 'Blocked: cannot push directly to main/master or force push. Use a feature branch and PR.'; exit 2; fi; exit 0"
    }
  ]
}
```

### 3. Deploy Gate (PreToolUse on Bash)

Catches deploy commands across common platforms and reminds you to run `/pre-ship` first. Exits 0 so it does not block -- it just surfaces the reminder.

```json
{
  "matcher": "Bash",
  "hooks": [
    {
      "type": "command",
      "command": "cmd=$(jq -r '.tool_input.command // \"\"'); if echo \"$cmd\" | grep -qiE 'vercel deploy|netlify deploy|firebase deploy|npm run deploy|fly deploy'; then echo 'Deploy detected. Run /pre-ship first if you have not already.'; fi; exit 0"
    }
  ]
}
```

### 4. Error Detection (PostToolUse on Bash)

Runs after a Bash command completes, scans the first 500 characters of output for error keywords, and suggests `/debug` if any are found. Always exits 0 since the command already ran.

```json
{
  "matcher": "Bash",
  "hooks": [
    {
      "type": "command",
      "command": "input=$(cat); result=$(echo \"$input\" | jq -r '.tool_response // \"\"' | head -c 500); if echo \"$result\" | grep -qiE 'error|failed|exception|FAILED'; then echo 'Error detected. Consider running /debug for systematic troubleshooting.'; fi; exit 0"
    }
  ]
}
```

### 5. High-Stakes Task Gate (UserPromptSubmit) -- measured, then removed

Scans the user's message for keywords related to payments, auth, or production data and reminds about planning skills. No matcher needed -- UserPromptSubmit hooks apply to all prompts.

**This one was measured and cut.** Across 90 days of transcripts it fired in 71 sessions and led to the suggested skill in 5, a 7% conversion rate. The regex matched `login`, `auth`, and `migration` as bare substrings, so it tripped on signing into a tool, on any Google auth question, and on any talk of moving files. It spent its credibility on false positives and had none left for the real payments task.

Keep it here as a construction example for the shape of a UserPromptSubmit hook. If you want the behavior, key it to something with more signal than prose keywords: a file path being edited, a dependency being added, a specific command being run. See [Measuring Whether a Warn-Only Hook Works](#measuring-whether-a-warn-only-hook-works) for the method that caught this.

```json
{
  "hooks": [
    {
      "type": "command",
      "command": "prompt=$(jq -r '.prompt // \"\"' | tr '[:upper:]' '[:lower:]'); if echo \"$prompt\" | grep -qE 'payment|billing|stripe|auth(entication)?|login|signup|password|prod(uction)?.?data|migration'; then echo 'High-stakes task detected. Consider running /pre-implement before coding.'; fi; exit 0"
    }
  ]
}
```

### 6. Unfamiliar Tech Gate (UserPromptSubmit)

Detects when the user signals unfamiliarity and suggests `/learn` first.

```json
{
  "hooks": [
    {
      "type": "command",
      "command": "prompt=$(jq -r '.prompt // \"\"' | tr '[:upper:]' '[:lower:]'); if echo \"$prompt\" | grep -qE 'never used|first time|unfamiliar|new to|don.t know how|haven.t worked with'; then echo 'Unfamiliar territory detected. Consider running /learn before implementing.'; fi; exit 0"
    }
  ]
}
```

### 7. Debug Loop Detection (UserPromptSubmit)

Catches frustration signals and suggests `/fresh-eyes` to break out of a debugging loop.

```json
{
  "hooks": [
    {
      "type": "command",
      "command": "prompt=$(jq -r '.prompt // \"\"' | tr '[:upper:]' '[:lower:]'); if echo \"$prompt\" | grep -qE 'still (not|broken|failing)|same error|tried everything|going in circles'; then echo 'Debugging loop detected. Consider running /fresh-eyes for a reset.'; fi; exit 0"
    }
  ]
}
```

---

## Measuring Whether a Warn-Only Hook Works

Blocking hooks prove their value every time they fire, because the thing they blocked did not happen. Warn-only hooks make no such promise. They print advice and exit 0, and whether anyone acts on that advice is an open question you have to go measure.

The measurement is worth doing, because a warn-only hook that never changes behavior is worse than no hook. It costs a process spawn on every matching event, and it teaches you to skim past hook output, which means the useful warnings get skipped alongside the useless ones.

Claude Code writes every session to a JSONL transcript under `~/.claude/projects/`. That is the data source. Two greps give you a conversion rate:

```bash
# 1. In how many sessions did the hook fire?
#    Use a distinctive substring of the message the hook echoes.
find ~/.claude/projects -name "*.jsonl" -mtime -90 -size +1k 2>/dev/null | \
  xargs grep -l 'High-stakes task detected' 2>/dev/null | wc -l

# 2. Of those same sessions, how many took the suggested action?
find ~/.claude/projects -name "*.jsonl" -mtime -90 -size +1k 2>/dev/null | \
  xargs grep -l 'High-stakes task detected' 2>/dev/null | \
  xargs grep -l '"skill":"pre-implement"\|<command-name>/pre-implement' 2>/dev/null | wc -l
```

Two details make this accurate:

**Count sessions, not hits.** Use `grep -l` and compare file lists. A session where the warning fired five times and the skill ran once is one conversion, not a 20% rate. Raw hit counting punishes chatty hooks for being chatty.

**Grep both invocation forms.** A skill invoked by the model appears as `"skill":"name"` in the transcript. A slash command the user typed appears as `<command-name>/name`. Miss either one and you undercount conversions.

### Reading the result

| Pattern | Verdict |
|---------|---------|
| Fires often, converts near zero | Ceremony. Delete it, or narrow the trigger until it fires only on the real case. |
| Fires rarely | Leave it. Low volume means low cost, and the occasional catch is free. |
| Fires and converts | It earns its process spawn. Keep it. |

Blocking hooks are exempt. They enforce instead of suggesting, so conversion is built in.

### A worked example

Recipe 5 below started as a keyword scan for payment, auth, and production-data work. Measured across 90 days of real transcripts, it fired in 71 sessions and converted in 5. That is 7%.

The failure was in the trigger, not the idea. The regex matched `login`, `auth`, and `migration` as bare substrings, so it tripped on any discussion of signing into a tool, any Google auth question, and any conversation about moving files. Most of what it caught was ordinary conversation that happened to contain one of its words. By the time a genuine payments task came along, the warning had been trained into background noise.

The hook was removed from the live config in July 2026. It survives below as a construction example, and as a reminder that a keyword regex over free-form prose is a weak trigger. If you want this behavior, key it to something with more signal: a file path being edited, a dependency being added, a specific command being run.

---

## How to Add Your Own Hooks

1. Open your settings file: `~/.claude/settings.json` (global) or `{project}/.claude/settings.json` (project-level).
2. Add or extend the `"hooks"` key with your PreToolUse, PostToolUse, or UserPromptSubmit configuration.
3. Write your shell command. Read the JSON payload from stdin and pull the field you need with `jq` (see [Hook Input](#hook-input) for the field names).
4. Choose your exit code: `0` to allow, `2` to block.
5. Print any message you want Claude to see.

## Common Hook Patterns

**Lint before commit:** Run your linter on staged files when `git commit` is detected. Exits 2 if linting fails.

```json
{
  "type": "command",
  "command": "cmd=$(jq -r '.tool_input.command // \"\"'); if echo \"$cmd\" | grep -qE 'git commit'; then npx lint-staged 2>&1 || exit 2; fi; exit 0"
}
```

**Protect files from edits:** Block writes to sensitive files like `.env` or `package-lock.json`.

```json
{
  "matcher": "Edit",
  "hooks": [
    {
      "type": "command",
      "command": "file=$(jq -r '.tool_input.file_path // \"\"'); if echo \"$file\" | grep -qE '\\.env$|package-lock\\.json$'; then echo \"Blocked: $file is a protected file.\"; exit 2; fi; exit 0"
    }
  ]
}
```

**Domain-specific reminder (project-level):** For a Firebase project, add a reminder that only fires in that project.

```json
{
  "hooks": [
    {
      "type": "command",
      "command": "prompt=$(jq -r '.prompt // \"\"' | tr '[:upper:]' '[:lower:]'); if echo \"$prompt\" | grep -qE 'firebase|firestore|realtime|sync|real-time|websocket|state.?manag'; then echo 'State/sync work detected. Consider running /pre-implement before coding.'; fi; exit 0"
    }
  ]
}
```
