#!/usr/bin/env bash
# export-setup.sh — Copies sanitized config from ~/.claude/ into examples/
# Run this whenever your setup changes to keep the guide in sync.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
EXAMPLES_DIR="$REPO_DIR/examples"
CLAUDE_DIR="$HOME/.claude"

echo "Exporting Claude Code setup to $EXAMPLES_DIR..."

# --- 1. CLAUDE.md (sanitized) ---
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
  # Copy CLAUDE.md. Add sed expressions to strip personal info if sharing publicly.
  # Example: sed -e 's/Your Name/[YOUR NAME]/g' "$CLAUDE_DIR/CLAUDE.md" > "$EXAMPLES_DIR/CLAUDE.md"
  cp "$CLAUDE_DIR/CLAUDE.md" "$EXAMPLES_DIR/CLAUDE.md"
  echo "  ✓ CLAUDE.md (sanitized)"
else
  echo "  ✗ CLAUDE.md not found"
fi

# --- 2. settings.json (sanitized) ---
if [ -f "$CLAUDE_DIR/settings.json" ]; then
  # Copy settings, remove plugin-specific entries
  cat "$CLAUDE_DIR/settings.json" | \
    jq 'del(.enabledPlugins)' > "$EXAMPLES_DIR/settings.json"
  echo "  ✓ settings.json (sanitized, plugins removed)"
else
  echo "  ✗ settings.json not found"
fi

# --- 3. settings.local.json ---
if [ -f "$CLAUDE_DIR/settings.local.json" ]; then
  cp "$CLAUDE_DIR/settings.local.json" "$EXAMPLES_DIR/settings.local.json"
  echo "  ✓ settings.local.json"
else
  echo "  ✗ settings.local.json not found"
fi

# --- 4. PR template ---
if [ -f "$CLAUDE_DIR/templates/PULL_REQUEST_TEMPLATE.md" ]; then
  cp "$CLAUDE_DIR/templates/PULL_REQUEST_TEMPLATE.md" "$EXAMPLES_DIR/PULL_REQUEST_TEMPLATE.md"
  echo "  ✓ PULL_REQUEST_TEMPLATE.md"
else
  echo "  ✗ PR template not found"
fi

# --- 5. Hooks (extract from settings.json) ---
if [ -f "$CLAUDE_DIR/settings.json" ]; then
  jq '{ hooks: .hooks }' "$CLAUDE_DIR/settings.json" > "$EXAMPLES_DIR/hooks-examples.json"
  echo "  ✓ hooks-examples.json"
fi

# --- 6. Skills ---
# Note: Some skills referenced in the guide (tests, debug, docs, wrap-up, learn,
# refactor, fresh-eyes, onboard, pre-mortem) are guide-only examples in examples/skills/
# and are not exported from the user's config.
STARTER_SKILLS=(session-start pre-implement harden git-workflow)
ADVANCED_SKILLS=(pre-ship code-reviewer comprehend architecture-review security-check performance-audit design-review debug-firebase ralph-prep roadmap skill-creator prompt-refiner humanizer nextjs-deploy website-qa doc-write project-scaffolding business-thought-partner)

for skill in "${STARTER_SKILLS[@]}"; do
  src="$CLAUDE_DIR/skills/$skill/SKILL.md"
  dest="$EXAMPLES_DIR/skills/starter-pack/$skill/SKILL.md"
  if [ -f "$src" ]; then
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    echo "  ✓ starter-pack/$skill"
  fi
done

for skill in "${ADVANCED_SKILLS[@]}"; do
  src="$CLAUDE_DIR/skills/$skill/SKILL.md"
  dest="$EXAMPLES_DIR/skills/advanced/$skill/SKILL.md"
  if [ -f "$src" ]; then
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    echo "  ✓ advanced/$skill"
  fi
done

# --- 7. Diff summary for changelog ---
echo ""
echo "Export complete at $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "Skills on disk: $(ls -d "$CLAUDE_DIR/skills"/*/SKILL.md 2>/dev/null | wc -l | tr -d ' ')"
echo "Skills exported: $(find "$EXAMPLES_DIR/skills" -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')"
echo ""
echo "To update CHANGELOG.md, run:"
echo "  cd $REPO_DIR && git diff --stat"
