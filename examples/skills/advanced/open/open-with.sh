#!/usr/bin/env bash
# Open a file in an EXTERNAL app. THIS IS THE FALLBACK, NOT THE DEFAULT.
#
# The default is to stay inside Claude Code: SendUserFile puts the file in the
# side panel and the user never leaves the session. See SKILL.md. Only reach for
# this script when the file genuinely needs another application, or when the user
# names one.
#
# Do NOT add a branch that runs `open -a Claude`. That launches Claude chat,
# which is a different surface from Claude Code and not what was asked for.
#
#   open-with.sh --editor <file>   the editor already in use
#   open-with.sh --default <file>  the system default app
#   open-with.sh --which           print the editor that would be used
set -euo pipefail

EDITORS=("Cursor" "Visual Studio Code" "Zed" "Sublime Text" "BBEdit" "Nova" "TextMate" "Xcode")

# The editor most recently in use.
#
# NOT the frontmost app: when Claude Code opens a file the frontmost app is
# Claude itself, so `lsappinfo front` returns "Claude" every time. The trap is
# invisible if you test detection by hand in a terminal.
#
# `lsappinfo visibleProcessList` returns apps in FRONT-TO-BACK z-order, so the
# first known editor in that list is the one last worked in. Follows a switch
# from Cursor to anything else with no list to maintain.
current_editor() {
  local asn name e
  for asn in $(lsappinfo visibleProcessList 2>/dev/null); do
    name=$(lsappinfo info -only name "$asn" 2>/dev/null | sed 's/.*"LSDisplayName"="//; s/"$//')
    [ -n "$name" ] || continue
    for e in "${EDITORS[@]}"; do
      [ "$name" = "$e" ] && { printf '%s' "$e"; return 0; }
    done
  done
  for e in "${EDITORS[@]}"; do
    pgrep -qf "/Applications/$e.app" && { printf '%s' "$e"; return 0; }
  done
  return 1
}

case "${1:-}" in
  --which)
    current_editor && echo " (editor in use)" || echo "no editor running"
    exit 0 ;;
  --default)
    shift; [ -e "${1:-}" ] || { echo "no such file: ${1:-}" >&2; exit 66; }
    open "$1"; echo "opened $(basename "$1") in the system default app"; exit 0 ;;
  --editor)
    shift; [ -e "${1:-}" ] || { echo "no such file: ${1:-}" >&2; exit 66; }
    if app=$(current_editor); then
      open -a "$app" "$1"; echo "opened $(basename "$1") in $app"
    else
      open "$1"; echo "opened $(basename "$1") in the system default app (no editor running)"
    fi
    exit 0 ;;
esac

echo "usage: open-with.sh --editor <file> | --default <file> | --which" >&2
echo "  (the default path is SendUserFile, inside Claude Code - see SKILL.md)" >&2
exit 64
