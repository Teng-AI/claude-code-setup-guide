# Settings

Claude Code uses two settings files, both stored in `~/.claude/`:

| File | Purpose | Commit to git? |
|------|---------|-----------------|
| `settings.json` | Global settings: model, hooks, feature flags | Yes (safe to share) |
| `settings.local.json` | Personal overrides: permissions, local preferences | No (gitignored) |

The split exists so you can share your general configuration while keeping permission grants and personal preferences private.

---

## settings.json Reference

| Setting | Type | What it does | Starter? |
|---------|------|-------------|----------|
| `model` | string | Which Claude model to use. Aliases like `"opus"` (deepest reasoning) or `"sonnet"` (faster) track the latest version so you are not pinning a dated model ID. | Yes |
| `alwaysThinkingEnabled` | boolean | Forces extended thinking on every response. Reduces errors on complex tasks at the cost of longer responses. | Yes |
| `effortLevel` | string | How much reasoning effort to spend per response (e.g. `"high"`, `"xhigh"`). Pairs with `alwaysThinkingEnabled`. | No |
| `hooks` | object | Run shell commands before/after Claude uses a tool. See [Hooks](04-hooks.md). | No |
| `statusLine` | object | A shell command whose output renders as the terminal status line (current dir, branch, model). | No |
| `autoUpdatesChannel` | string | Release channel: `"latest"` (stable), `"beta"` (pre-release), `"disabled"` (manual). | No |
| `skipDangerousModePermissionPrompt` | boolean | Skip confirmation before potentially destructive commands. **This is the single biggest quality-of-life setting** -- once you trust your allow/deny lists, flipping this to `true` eliminates most approval prompts and lets you work uninterrupted. Start with `false`, switch to `true` after a few sessions, and re-check the decision whenever the machine or the stakes change (a `/setup-audit` run will ask). | No |
| `inputNeededNotifEnabled` / `agentPushNotifEnabled` | boolean | System notifications when Claude needs input or a background agent finishes. Useful once you run longer autonomous tasks. | No |
| `voiceEnabled` | boolean | Enables voice input for speaking to Claude instead of typing. | No |

Settings marked "Starter? Yes" are the only two you need when first setting up. Add others as you discover what you need.

Example minimal `settings.json`:

```json
{
  "model": "opus",
  "alwaysThinkingEnabled": true
}
```

See [`../examples/settings.json`](../examples/settings.json) for the full live example, including the hook wiring.

---

## settings.local.json: Permissions

This file controls what Claude can do without asking you first. Do not commit it to version control -- permission grants are personal.

### Structure

```json
{
  "permissions": {
    "allow": [
      "Bash(claude)",
      "WebFetch(domain:docs.anthropic.com)"
    ],
    "deny": []
  }
}
```

- **allow:** Tool patterns Claude can use without confirmation.
- **deny:** Tool patterns Claude is never allowed to use. Deny takes precedence over allow.

### Permission Patterns

Patterns follow the format `ToolName(constraint)`:

| Pattern | Effect |
|---------|--------|
| `"Read"` | Allow all uses of that tool |
| `"Bash(claude)"` | Allow bash commands containing "claude" |
| `"WebFetch(domain:docs.anthropic.com)"` | Allow fetches from a specific domain |
| `"Bash(npm *)"` | Allow any bash command starting with `npm` |

### Example: Balanced Permission Set

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git log *)",
      "Bash(npm test)",
      "Bash(npm run lint)",
      "WebFetch(domain:docs.anthropic.com)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force *)"
    ]
  }
}
```

This lets Claude read files, search code, check git status, run tests, and fetch Anthropic docs freely. Force-push and recursive delete are blocked entirely. Everything else requires confirmation.

Start with a minimal allow list and expand as you build trust.

