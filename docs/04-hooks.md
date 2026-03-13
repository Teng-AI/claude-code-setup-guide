# Hooks

## What Are Hooks?

Hooks are shell commands that execute automatically before or after Claude uses a tool. They let you enforce rules, add reminders, and block dangerous operations without relying on Claude to remember every policy.

There are two hook types:

- **PreToolUse**: Runs before Claude executes a tool. Can block the tool call.
- **PostToolUse**: Runs after Claude executes a tool. Can inspect the result and provide feedback.

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
    ]
  }
}
```

**Key fields:**

| Field | Purpose |
|-------|---------|
| `matcher` | The tool name to match (e.g., `"Bash"`, `"Write"`, `"Edit"`). The hook only runs when this tool is used. |
| `type` | Always `"command"` for shell hooks. |
| `command` | The shell command to execute. |

## Environment Variables

| Variable | Available In | Contains |
|----------|-------------|----------|
| `$TOOL_INPUT` | PreToolUse, PostToolUse | JSON string with the tool's input parameters |
| `$TOOL_RESULT` | PostToolUse only | The tool's output/result |

## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Pass. The tool call proceeds normally. |
| `2` | Block. The tool call is prevented from executing (PreToolUse only). |

Any output your hook prints to stdout is shown to Claude as feedback.

---

## Hook Examples

### 1. Docs Reminder (PreToolUse on Bash)

Watches for `git commit` or `git push` and reminds you to run `/docs` first. Always exits 0 so it never blocks -- it only surfaces a reminder when staged files exist.

```json
{
  "matcher": "Bash",
  "hooks": [
    {
      "type": "command",
      "command": "cmd=$(echo \"$TOOL_INPUT\" | jq -r '.command // \"\"'); if echo \"$cmd\" | grep -qE 'git commit|git push'; then staged=$(git diff --cached --name-only 2>/dev/null); if [ -n \"$staged\" ]; then echo 'Reminder: Run /docs to sync documentation before committing'; fi; fi; exit 0"
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
      "command": "cmd=$(echo \"$TOOL_INPUT\" | jq -r '.command // \"\"'); if echo \"$cmd\" | grep -qE 'git push.*(main|master)|git push -f|git push --force'; then echo 'Blocked: cannot push directly to main/master or force push. Use a feature branch and PR.'; exit 2; fi; exit 0"
    }
  ]
}
```

### 3. Error Detection (PostToolUse on Bash)

Runs after a Bash command completes, scans the first 500 characters of output for error keywords, and suggests `/debug` if any are found. Always exits 0 since the command already ran.

```json
{
  "matcher": "Bash",
  "hooks": [
    {
      "type": "command",
      "command": "cmd=$(echo \"$TOOL_INPUT\" | jq -r '.command // \"\"'); result=$(echo \"$TOOL_RESULT\" | head -c 500); if echo \"$result\" | grep -qiE 'error|failed|exception|FAILED'; then echo 'Error detected. Consider running /debug for systematic troubleshooting.'; fi; exit 0"
    }
  ]
}
```

---

## How to Add Your Own Hooks

1. Open your settings file: `~/.claude/settings.json` (global) or `{project}/.claude/settings.json` (project-level).
2. Add or extend the `"hooks"` key with your PreToolUse or PostToolUse configuration.
3. Write your shell command. Use `$TOOL_INPUT` (parsed with `jq`) to inspect what Claude is about to do.
4. Choose your exit code: `0` to allow, `2` to block.
5. Print any message you want Claude to see.

## Common Hook Patterns

**Lint before commit:** Run your linter on staged files when `git commit` is detected. Exits 2 if linting fails.

```json
{
  "type": "command",
  "command": "cmd=$(echo \"$TOOL_INPUT\" | jq -r '.command // \"\"'); if echo \"$cmd\" | grep -qE 'git commit'; then npx lint-staged 2>&1 || exit 2; fi; exit 0"
}
```

**Protect files from edits:** Block writes to sensitive files like `.env` or `package-lock.json`.

```json
{
  "matcher": "Edit",
  "hooks": [
    {
      "type": "command",
      "command": "file=$(echo \"$TOOL_INPUT\" | jq -r '.file_path // \"\"'); if echo \"$file\" | grep -qE '\\.env$|package-lock\\.json$'; then echo \"Blocked: $file is a protected file.\"; exit 2; fi; exit 0"
    }
  ]
}
```
