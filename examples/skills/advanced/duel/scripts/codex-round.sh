#!/usr/bin/env bash
# Run one /duel round for the Codex analyst.
# Usage: codex-round.sh <arena-dir> <round0|swap|final> <A|B>
# Writes <arena>/<round>-<label>.md and a log beside the arena; exits non-zero on a stub.
set -euo pipefail

arena="${1:?arena dir}"; round="${2:?round0|swap|final}"; me="${3:?A|B}"
case "$round" in round0|swap|final) ;; *) echo "round must be round0, swap or final" >&2; exit 2;; esac
case "$me" in A) other=B ;; B) other=A ;; *) echo "label must be A or B" >&2; exit 2;; esac
arena="$(cd "$arena" && pwd)"
out="$arena/$round-$me.md"
log="$(dirname "$arena")/codex-$round.log"

case "$round" in
  round0) task="Do round0 exactly as rounds.md describes." ;;
  swap)   task="Read round0-$me.md (your own round0) and round0-$other.md (the other analyst's). Do the swap round exactly as rounds.md describes." ;;
  final)  task="Read swap-$me.md (your revised proposal), owner.md and facts-checked.md if present. Do the final round exactly as rounds.md describes." ;;
esac

prompt="You are Analyst $me. Read packet.md, evidence.md (if present) and rounds.md in this folder. $task Use only files in this folder: don't browse the web and don't open any file outside it. Don't write files. Reply with only your markdown answer, complete, as your final message."

codex exec -s read-only --skip-git-repo-check --ephemeral -C "$arena" \
  -c model_reasoning_effort="high" -o "$out" - <<<"$prompt" >"$log" 2>&1 || {
  echo "codex exec failed; see $log (usage limit or login?)" >&2; tail -5 "$log" >&2; exit 1; }

bytes=$(wc -c <"$out" | tr -d ' ')
if [ "$bytes" -lt 1500 ]; then
  echo "STUB: $out is $bytes bytes. Check $log before trusting this round." >&2
  exit 1
fi
echo "ok: $out ($bytes bytes)"
