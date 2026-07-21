#!/usr/bin/env bash
# docs-gate.sh — PreToolUse hook.
#
# Deterministically blocks further "risky" (edit/debug) tool calls once
# DG_THRESHOLD of them have happened in a row with no "grounding" (docs
# lookup) call in between, per session. Pure counting + pattern matching —
# no LLM judgment anywhere in this script. See README.md for the full
# design and its honest limitations.
#
# Register under hooks.PreToolUse with matcher "*" (see settings.snippet.json)
# so every tool call passes through here for classification.
#
# Exit codes:
#   0 - allow (default; also the fail-open outcome for any internal error)
#   2 - block (only when a risky call arrives at/over threshold)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/docs-gate-lib.sh
source "$SCRIPT_DIR/lib/docs-gate-lib.sh" 2>/dev/null || exit 0

command -v jq >/dev/null 2>&1 || exit 0

dg_killswitch_active && exit 0

input="$(cat)" || exit 0
[ -n "$input" ] || exit 0

printf '%s' "$input" | jq -e . >/dev/null 2>&1 || { dg_log_error "malformed JSON on stdin"; exit 0; }

session_id="$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null)"
tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null)"
tool_cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)"

[ -n "$session_id" ] || { dg_log_error "missing session_id on stdin, failing open"; exit 0; }
[ -n "$tool_name" ] || exit 0

dg_load_config

class="$(dg_classify "$tool_name" "$tool_cmd")"

case "$class" in
  grounding)
    dg_write_counter "$session_id" 0
    exit 0
    ;;
  risky)
    counter="$(dg_read_counter "$session_id")"
    case "$counter" in ''|*[!0-9]*) counter=0 ;; esac
    if [ "$counter" -ge "$DG_THRESHOLD" ]; then
      printf '%s debug attempt(s) without consulting documentation. Before editing again, call context7 (resolve-library-id + get-library-docs), deepwiki, or WebFetch/WebSearch on the relevant repo/API docs, then retry.\n' "$counter" >&2
      exit 2
    fi
    dg_write_counter "$session_id" "$((counter + 1))"
    exit 0
    ;;
  *)
    exit 0
    ;;
esac
