#!/usr/bin/env bash
#
# Claude Code Setup Guide - Installer
#
# Installs skills (and optionally hooks, templates, settings) into ~/.claude/
#
# Usage:
#   ./install.sh              Install starter pack (8 core skills)
#   ./install.sh --full       Install everything (all skills, hooks, templates, settings)
#   ./install.sh --force      Overwrite existing files without prompting
#   ./install.sh --full --force
#   ./install.sh --help       Show usage information
#

set -euo pipefail

# --- Configuration ---

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"

STARTER_PACK_SRC="$SCRIPT_DIR/examples/skills/starter-pack"
ADVANCED_SRC="$SCRIPT_DIR/examples/skills/advanced"
HOOKS_SRC="$SCRIPT_DIR/examples/hooks-examples.json"
SETTINGS_SRC="$SCRIPT_DIR/examples/settings.json"
PR_TEMPLATE_SRC="$SCRIPT_DIR/examples/PULL_REQUEST_TEMPLATE.md"

STARTER_SKILLS=(
    "session-start"
    "pre-implement"
    "harden"
    "tests"
    "debug"
    "git-workflow"
    "docs"
    "wrap-up"
)

FULL_INSTALL=false
FORCE=false

# --- Functions ---

usage() {
    cat <<'USAGE'
Claude Code Setup Guide - Installer

Usage:
    ./install.sh [options]

Options:
    --full      Install everything (all skills, hooks, templates, settings)
    --force     Overwrite existing files without prompting
    --help      Show this help message

Examples:
    ./install.sh              Install 8 starter-pack skills
    ./install.sh --full       Install all skills plus hooks, templates, settings
    ./install.sh --force      Reinstall starter pack, overwriting existing files
USAGE
}

log_ok() {
    echo "  [OK] $1"
}

log_warn() {
    echo "  [WARN] $1"
}

log_skip() {
    echo "  [SKIP] $1"
}

log_info() {
    echo "  [INFO] $1"
}

log_error() {
    echo "  [ERROR] $1"
}

check_prerequisites() {
    echo ""
    echo "Checking prerequisites..."
    echo ""

    local missing=0

    if command -v node &>/dev/null; then
        local node_version
        node_version="$(node --version)"
        log_ok "Node.js found ($node_version)"
    else
        log_error "Node.js not found. Install it from https://nodejs.org/"
        missing=1
    fi

    if command -v claude &>/dev/null; then
        log_ok "Claude CLI found"
    else
        log_error "Claude CLI not found. Install it with: npm install -g @anthropic-ai/claude-code"
        missing=1
    fi

    if [ "$missing" -eq 1 ]; then
        echo ""
        echo "Fix the issues above and re-run this script."
        exit 1
    fi

    echo ""
}

# Install a single skill from a subdirectory containing SKILL.md.
# Each skill lives at <src_dir>/<skill-name>/SKILL.md and gets installed
# to ~/.claude/skills/<skill-name>/SKILL.md.
# Arguments: $1 = skill subdirectory path (e.g. .../starter-pack/debug)
install_skill() {
    local skill_dir="$1"
    local skill_name
    skill_name="$(basename "$skill_dir")"
    local src_file="$skill_dir/SKILL.md"
    local dest_dir="$SKILLS_DIR/$skill_name"
    local dest_file="$dest_dir/SKILL.md"

    if [ ! -f "$src_file" ]; then
        log_warn "SKILL.md not found in $skill_dir"
        return 0
    fi

    if [ -f "$dest_file" ] && [ "$FORCE" = false ]; then
        log_skip "$skill_name/SKILL.md already exists (use --force to overwrite)"
        return 1
    fi

    mkdir -p "$dest_dir"
    cp "$src_file" "$dest_file"
    log_ok "$skill_name/SKILL.md"
    return 0
}

install_starter_pack() {
    echo "Installing starter pack skills..."
    echo ""

    mkdir -p "$SKILLS_DIR"

    if [ ! -d "$STARTER_PACK_SRC" ]; then
        log_error "Starter pack directory not found at: $STARTER_PACK_SRC"
        echo ""
        echo "Make sure you are running this script from the repository root."
        exit 1
    fi

    local installed=0
    local skipped=0

    for skill in "${STARTER_SKILLS[@]}"; do
        local skill_dir="$STARTER_PACK_SRC/$skill"
        if [ ! -d "$skill_dir" ]; then
            log_warn "Skill directory not found: $skill"
            continue
        fi

        if install_skill "$skill_dir"; then
            installed=$((installed + 1))
        else
            skipped=$((skipped + 1))
        fi
    done

    echo ""
    echo "Starter pack: $installed installed, $skipped skipped."
}

install_advanced_skills() {
    echo ""
    echo "Installing advanced skills..."
    echo ""

    if [ ! -d "$ADVANCED_SRC" ]; then
        log_warn "Advanced skills directory not found at: $ADVANCED_SRC"
        return 0
    fi

    local installed=0
    local skipped=0

    for skill_dir in "$ADVANCED_SRC"/*/; do
        [ -d "$skill_dir" ] || continue

        if install_skill "$skill_dir"; then
            installed=$((installed + 1))
        else
            skipped=$((skipped + 1))
        fi
    done

    if [ "$installed" -gt 0 ]; then
        log_ok "Installed $installed advanced skill(s)"
    fi
    if [ "$skipped" -gt 0 ]; then
        log_skip "Skipped $skipped existing advanced skill(s) (use --force to overwrite)"
    fi
}

install_hooks() {
    echo ""
    echo "Installing hooks..."
    echo ""

    if [ ! -f "$HOOKS_SRC" ]; then
        log_warn "Hooks file not found at: $HOOKS_SRC"
        return 0
    fi

    local settings_dest="$CLAUDE_DIR/settings.json"

    if [ -f "$settings_dest" ]; then
        # Check if the existing settings already have hooks defined
        if command -v jq &>/dev/null; then
            local has_hooks
            has_hooks="$(jq 'has("hooks")' "$settings_dest" 2>/dev/null || echo "false")"
            if [ "$has_hooks" = "true" ] && [ "$FORCE" = false ]; then
                log_skip "settings.json already contains hooks (use --force to overwrite)"
                log_info "Example hooks saved to $CLAUDE_DIR/hooks-examples.json for reference"
                cp "$HOOKS_SRC" "$CLAUDE_DIR/hooks-examples.json"
                return 0
            fi
        else
            log_warn "jq not found -- cannot safely merge hooks into existing settings.json"
            log_info "Example hooks saved to $CLAUDE_DIR/hooks-examples.json for reference"
            log_info "Manually merge hooks from hooks-examples.json into your settings.json"
            cp "$HOOKS_SRC" "$CLAUDE_DIR/hooks-examples.json"
            return 0
        fi

        # Merge hooks into existing settings.json
        local merged
        merged="$(jq -s '.[0] * {"hooks": .[1].hooks}' "$settings_dest" "$HOOKS_SRC" 2>/dev/null)" || {
            log_error "Failed to merge hooks into settings.json"
            log_info "Example hooks saved to $CLAUDE_DIR/hooks-examples.json for reference"
            cp "$HOOKS_SRC" "$CLAUDE_DIR/hooks-examples.json"
            return 0
        }

        echo "$merged" > "$settings_dest"
        log_ok "Merged hooks into existing settings.json"
    else
        # No existing settings.json -- create one with just the hooks
        cp "$HOOKS_SRC" "$settings_dest"
        log_ok "Created settings.json with hooks"
    fi
}

install_templates() {
    echo ""
    echo "Installing templates..."
    echo ""

    if [ ! -f "$PR_TEMPLATE_SRC" ]; then
        log_warn "PR template not found at: $PR_TEMPLATE_SRC"
        return 0
    fi

    local templates_dest="$CLAUDE_DIR/templates"
    mkdir -p "$templates_dest"

    local dest_file="$templates_dest/PULL_REQUEST_TEMPLATE.md"

    if [ -f "$dest_file" ] && [ "$FORCE" = false ]; then
        log_skip "PULL_REQUEST_TEMPLATE.md already exists (use --force to overwrite)"
        return 0
    fi

    cp "$PR_TEMPLATE_SRC" "$dest_file"
    log_ok "PULL_REQUEST_TEMPLATE.md"
}

install_settings() {
    echo ""
    echo "Installing settings..."
    echo ""

    if [ ! -f "$SETTINGS_SRC" ]; then
        log_warn "Example settings.json not found at: $SETTINGS_SRC"
        return 0
    fi

    local settings_dest="$CLAUDE_DIR/settings.json"

    if [ -f "$settings_dest" ] && [ "$FORCE" = false ]; then
        log_skip "settings.json already exists (use --force to overwrite)"
        log_info "Example saved to $CLAUDE_DIR/settings.example.json instead"
        cp "$SETTINGS_SRC" "$CLAUDE_DIR/settings.example.json"
    else
        cp "$SETTINGS_SRC" "$settings_dest"
        log_ok "settings.json"
    fi

    # Warn about skipDangerousModePermissionPrompt
    if command -v jq &>/dev/null; then
        local skip_dangerous
        skip_dangerous="$(jq -r '.skipDangerousModePermissionPrompt // false' "$SETTINGS_SRC" 2>/dev/null)"
        if [ "$skip_dangerous" = "true" ]; then
            echo ""
            log_warn "The installed settings.json has 'skipDangerousModePermissionPrompt' set to true."
            log_warn "This disables safety prompts for dangerous operations (file deletion, etc.)."
            log_warn "If you are new to Claude Code, consider setting it to false in:"
            log_warn "  $CLAUDE_DIR/settings.json"
        fi
    else
        echo ""
        log_warn "Could not check settings for risky options (jq not installed)."
        log_warn "Review $CLAUDE_DIR/settings.json and consider disabling"
        log_warn "'skipDangerousModePermissionPrompt' if you are new to Claude Code."
    fi
}

install_full() {
    install_advanced_skills
    install_hooks
    install_templates
    install_settings
}

print_success() {
    echo ""
    echo "============================================"
    echo "  Installation complete."
    echo "============================================"
    echo ""
    echo "  Skills installed to: $SKILLS_DIR"
    echo ""
    echo "  Next steps:"
    echo ""
    echo "    1. Open a terminal and run: claude"
    echo "    2. Type /session-start to verify skills are loaded"
    echo "    3. Read docs/01-getting-started.md for a walkthrough"
    echo ""

    if [ "$FULL_INSTALL" = false ]; then
        echo "  Want the full setup? Run:"
        echo ""
        echo "    ./install.sh --full"
        echo ""
    fi
}

# --- Parse Arguments ---

while [ $# -gt 0 ]; do
    case "$1" in
        --full)
            FULL_INSTALL=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "[ERROR] Unknown option: $1"
            echo ""
            usage
            exit 1
            ;;
    esac
done

# --- Main ---

echo ""
echo "Claude Code Setup Guide - Installer"
echo ""

if [ "$FULL_INSTALL" = true ]; then
    echo "Mode: Full install (all skills, hooks, templates, settings)"
else
    echo "Mode: Starter pack (8 core skills)"
fi

if [ "$FORCE" = true ]; then
    echo "Force: ON (existing files will be overwritten)"
fi

check_prerequisites
install_starter_pack

if [ "$FULL_INSTALL" = true ]; then
    install_full
fi

print_success
