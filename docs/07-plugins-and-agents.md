# Plugins and Custom Agents

## Plugins

Plugins are third-party extensions that add capabilities beyond what Claude Code ships with out of the box. They can come from the community or from official sources, and they let you customize Claude's behavior without modifying your core setup.

### What They Do

A plugin hooks into Claude Code's runtime and adds new tools, behaviors, or automation patterns. For example, a plugin might give Claude the ability to iterate autonomously on a task, connect to an external service, or run specialized analysis.

### Where They Are Configured

Plugins are managed in your `settings.json` file under the `enabledPlugins` key:

```json
{
  "enabledPlugins": [
    "ralph-loop"
  ]
}
```

This file lives at `~/.claude/settings.json` for global configuration, or in `.claude/settings.json` at the project root for project-specific plugins.

### Managing Plugins

**Install a plugin** by adding its name to the `enabledPlugins` array in `settings.json`.

**Disable a plugin** by removing it from the array. The plugin's files remain on disk, but Claude Code will not load it.

**Blocklist a plugin** if you want to prevent it from being enabled, even if a project-level config tries to include it. Use the `blockedPlugins` key in your global `settings.json`:

```json
{
  "blockedPlugins": [
    "plugin-you-dont-trust"
  ]
}
```

### Example: ralph-loop

[`ralph-loop`](https://github.com/anthropics/claude-plugins-public/tree/main/plugins/ralph-loop) is an official Anthropic plugin that enables autonomous iteration -- Claude runs a task, evaluates the result, and loops back to refine its output without waiting for you to re-prompt.

---

## Custom Agents

Custom agents are specialized agent definitions that Claude Code can spawn as subagents. They live as `.md` files in `~/.claude/agents/` and define a focused persona with its own tools, instructions, and behavior.

### How They Work

When you invoke a custom agent, Claude Code reads the corresponding `.md` file and spawns a subagent that follows its instructions. The subagent has access to specific tools you declare, follows the behavioral rules you write, and returns results to the main conversation.

Each agent file contains:

- A description of the agent's purpose
- The tools the agent is allowed to use
- Behavioral instructions (approach, format, constraints)
- An optional model override

### Example Agents

**reddit-research** -- Searches Reddit discussions to gather community opinions, find real-world solutions, and understand sentiment around tools or approaches.

**prompt-generator-anthropic** -- Generates high-quality prompts using Anthropic's official metaprompt. Takes a rough description and returns a polished, structured prompt.

### Creating a Custom Agent

Create a `.md` file in `~/.claude/agents/`. The filename becomes the agent's identifier (e.g., `code-reviewer.md` creates the `code-reviewer` agent).

```markdown
# Code Reviewer

## Purpose
Review code changes for correctness, readability, and potential bugs.

## Tools
- Read (to examine source files)
- Grep (to search for patterns across the codebase)
- Bash (to run linters or tests)

## Instructions
- Focus on logic errors, not style preferences.
- Flag any function longer than 50 lines.
- Check that error cases are handled, not just the happy path.
- Return findings as a numbered list with file paths and line numbers.

## Model
(optional) claude-sonnet-4-20250514
```

| Section | Purpose |
|---------|---------|
| Purpose | One or two sentences describing what the agent does. Keeps it focused. |
| Tools | Which tools the agent can access. Restricting tools prevents scope creep. |
| Instructions | Behavioral rules. Be specific -- vague instructions produce vague results. |
| Model | Optional. Override the default model for different capability or cost profile. |

### When to Use Custom Agents vs. Skills

Skills and agents solve different problems.

**Skills** are structured workflows you invoke with a slash command. They run inside your current conversation and guide Claude through a specific process. You control the flow, and Claude follows the instructions step by step. Use skills for work that benefits from your input at each stage.

**Agents** are autonomous workers that run a task and return results. They are best for research, analysis, or specialized tasks where you can describe the work upfront and let the agent run without further guidance.

| Use Case | Reach For |
|----------|-----------|
| Planning a feature before implementation | Skill (`/pre-implement`) |
| Researching a library's community reputation | Agent (`reddit-research`) |
| Running a structured code review checklist | Skill (`/code-reviewer`) |
| Generating a prompt template from a rough idea | Agent (`prompt-generator-anthropic`) |
| Hardening error handling after a feature works | Skill (`/harden`) |
| Gathering data from multiple sources autonomously | Agent (custom) |
