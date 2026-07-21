#!/usr/bin/env bash
# docs-gate-lib.sh — shared classification + state logic for docs-gate.sh.
# Sourced, never executed directly. Bash 3.2 compatible (no mapfile, no
# associative arrays, no ${var,,}) so it runs under macOS's stock /bin/bash.
#
# Every function here is written to fail open: on any internal error
# (missing jq, unwritable state dir, corrupt JSON) it returns a safe
# default (counter 0, "neutral" classification) rather than erroring out.
# The caller (docs-gate.sh) is responsible for the final exit code.

DG_PLUGIN_DEFAULT_STATE_DIR="${CLAUDE_PLUGIN_DATA:+$CLAUDE_PLUGIN_DATA/state}"
DG_STATE_DIR="${DOCS_GATE_STATE_DIR:-${DG_PLUGIN_DEFAULT_STATE_DIR:-$HOME/.claude/state/docs-gate}}"
DG_CONFIG_FILE="${DOCS_GATE_CONFIG:-$DG_STATE_DIR/config.json}"
DG_OFF_FILE="${DOCS_GATE_OFF_FILE:-$DG_STATE_DIR/OFF}"
DG_SESSIONS_DIR="${DOCS_GATE_SESSIONS_DIR:-$DG_STATE_DIR/sessions}"
DG_ERROR_LOG="${DOCS_GATE_ERROR_LOG:-$DG_STATE_DIR/error.log}"

DG_THRESHOLD=3
DG_RISKY_TOOLS=()
DG_RISKY_BASH_PATTERNS=()
DG_GROUNDING_TOOL_PATTERNS=()
DG_GROUNDING_BASH_PATTERNS=()

dg_log_error() {
  mkdir -p "$DG_STATE_DIR" 2>/dev/null
  printf '[%s] %s\n' "$(date '+%Y-%m-%dT%H:%M:%S' 2>/dev/null || printf unknown)" "$1" >> "$DG_ERROR_LOG" 2>/dev/null
  return 0
}

dg_killswitch_active() {
  [ -f "$DG_OFF_FILE" ]
}

# Prints a filesystem-safe token for a session_id. Prefers a real hash
# (sha256sum on Linux, shasum on macOS); falls back to character-stripping
# so a missing hash binary never blocks the gate.
dg_hash_session_id() {
  local sid="$1" h=""
  if command -v sha256sum >/dev/null 2>&1; then
    h=$(printf '%s' "$sid" | sha256sum 2>/dev/null | cut -d' ' -f1)
  elif command -v shasum >/dev/null 2>&1; then
    h=$(printf '%s' "$sid" | shasum -a 256 2>/dev/null | cut -d' ' -f1)
  fi
  if [ -z "$h" ]; then
    h=$(printf '%s' "$sid" | tr -c 'a-zA-Z0-9_-' '_')
  fi
  [ -n "$h" ] || h="unknown"
  printf '%s' "${h:0:32}"
}

dg_state_file() {
  printf '%s/%s.json' "$DG_SESSIONS_DIR" "$(dg_hash_session_id "$1")"
}

# Prints the current risky-streak counter for a session. Missing or
# corrupt state reads as 0 — never blocks on a bad read.
dg_read_counter() {
  local f c
  f=$(dg_state_file "$1")
  [ -f "$f" ] || { printf '0'; return 0; }
  c=$(jq -r '.counter // 0' "$f" 2>/dev/null)
  case "$c" in
    ''|*[!0-9]*) printf '0' ;;
    *) printf '%s' "$c" ;;
  esac
}

# Writes the counter atomically (tmp file + mv). Best-effort: a write
# failure is logged but never propagated as a blocking condition.
dg_write_counter() {
  local sid="$1" val="$2" f tmp
  case "$val" in ''|*[!0-9]*) val=0 ;; esac
  f=$(dg_state_file "$sid")
  mkdir -p "$DG_SESSIONS_DIR" 2>/dev/null || { dg_log_error "mkdir failed for $DG_SESSIONS_DIR"; return 1; }
  tmp="${f}.tmp.$$"
  if jq -n --argjson counter "$val" --arg updated "$(date -u '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || printf unknown)" \
      '{counter: $counter, updated: $updated}' > "$tmp" 2>/dev/null; then
    mv "$tmp" "$f" 2>/dev/null || { rm -f "$tmp" 2>/dev/null; dg_log_error "mv failed for $f"; return 1; }
  else
    rm -f "$tmp" 2>/dev/null
    dg_log_error "jq write failed for $f"
    return 1
  fi
  return 0
}

dg_set_defaults() {
  DG_THRESHOLD=3
  # MultiEdit is kept for compatibility with older Claude Code versions
  # that had a separate MultiEdit tool; current versions only emit Edit.
  DG_RISKY_TOOLS=("Edit" "MultiEdit" "Write")
  # Boundaries require start-of-string/whitespace/shell-operator on both
  # sides, not just a word-character transition -- this is what keeps a
  # path like "docs-gate.test.sh" from matching "test" (it's preceded by
  # "." on both sides, never whitespace/operator/start).
  DG_RISKY_BASH_PATTERNS=(
    '(^|[[:space:];&|(])test([[:space:];&|)]|$)'
    '(^|[[:space:];&|(])pytest([[:space:];&|)]|$)'
    '(^|[[:space:];&|(])npm[[:space:]]+(run|test)([[:space:];&|)]|$)'
    '(^|[[:space:];&|(])yarn[[:space:]]+(run|test)([[:space:];&|)]|$)'
    '(^|[[:space:];&|(])pnpm[[:space:]]+(run|test)([[:space:];&|)]|$)'
    '(^|[[:space:];&|(])go[[:space:]]+(run|test|build)([[:space:];&|)]|$)'
    '(^|[[:space:];&|(])python[0-9.]*([[:space:];&|)]|$)'
    '(^|[[:space:];&|(])node([[:space:];&|)]|$)'
    '(^|[[:space:];&|(])make([[:space:];&|)]|$)'
    '(^|[[:space:];&|(])cargo[[:space:]]+(run|test|build)([[:space:];&|)]|$)'
    '(^|[[:space:];&|(])debugger?([[:space:];&|)]|$)'
    '(^|[[:space:];&|(])docker[[:space:]]+(run|build|compose)([[:space:];&|)]|$)'
    '(^|[[:space:];&|(])traceback([[:space:];&|)]|$)'
    '(^|[[:space:];&|(])error([[:space:];&|)]|$)'
  )
  DG_GROUNDING_TOOL_PATTERNS=('^WebFetch$' '^WebSearch$' 'context7' 'deepwiki')
  DG_GROUNDING_BASH_PATTERNS=(
    '\bgh\b.*\bissue\b' '\bgh\b.*\bpr\b.*\bview\b' '\bgh\b.*\bapi\b'
    'curl.*docs\.' 'curl.*readthedocs' 'curl.*api\.github\.com'
  )
}

# Loads $DG_CONFIG_FILE over the built-in defaults. Any array present and
# non-empty in the config file replaces the corresponding default array;
# missing keys keep their default. A missing or invalid config file is a
# no-op (defaults stand) — this function never fails the caller.
dg_load_config() {
  dg_set_defaults
  [ -f "$DG_CONFIG_FILE" ] || return 0
  jq -e . "$DG_CONFIG_FILE" >/dev/null 2>&1 || { dg_log_error "config is not valid JSON, using defaults: $DG_CONFIG_FILE"; return 0; }

  local t line tmp_arr
  t=$(jq -r '.threshold // empty' "$DG_CONFIG_FILE" 2>/dev/null)
  case "$t" in ''|*[!0-9]*) : ;; *) DG_THRESHOLD="$t" ;; esac

  tmp_arr=()
  while IFS= read -r line; do [ -n "$line" ] && tmp_arr+=("$line"); done \
    < <(jq -r '.risky_tools[]?' "$DG_CONFIG_FILE" 2>/dev/null)
  [ "${#tmp_arr[@]}" -gt 0 ] && DG_RISKY_TOOLS=("${tmp_arr[@]}")

  tmp_arr=()
  while IFS= read -r line; do [ -n "$line" ] && tmp_arr+=("$line"); done \
    < <(jq -r '.risky_bash_patterns[]?' "$DG_CONFIG_FILE" 2>/dev/null)
  [ "${#tmp_arr[@]}" -gt 0 ] && DG_RISKY_BASH_PATTERNS=("${tmp_arr[@]}")

  tmp_arr=()
  while IFS= read -r line; do [ -n "$line" ] && tmp_arr+=("$line"); done \
    < <(jq -r '.grounding_tool_patterns[]?' "$DG_CONFIG_FILE" 2>/dev/null)
  [ "${#tmp_arr[@]}" -gt 0 ] && DG_GROUNDING_TOOL_PATTERNS=("${tmp_arr[@]}")

  tmp_arr=()
  while IFS= read -r line; do [ -n "$line" ] && tmp_arr+=("$line"); done \
    < <(jq -r '.grounding_bash_patterns[]?' "$DG_CONFIG_FILE" 2>/dev/null)
  [ "${#tmp_arr[@]}" -gt 0 ] && DG_GROUNDING_BASH_PATTERNS=("${tmp_arr[@]}")

  return 0
}

# dg_classify <tool_name> <bash_command>
# Echoes exactly one of: risky | grounding | neutral
#
# Precedence: grounding is checked before risky, so a Bash command that
# happens to match both (e.g. "gh issue view 1 && pytest") resets the
# counter rather than incrementing it. See README "Limitations".
dg_classify() {
  local tool_name="$1" cmd="$2" p

  for p in "${DG_GROUNDING_TOOL_PATTERNS[@]}"; do
    if printf '%s' "$tool_name" | grep -qiE -- "$p" 2>/dev/null; then
      printf 'grounding'; return 0
    fi
  done

  if [ "$tool_name" = "Bash" ] && [ -n "$cmd" ]; then
    for p in "${DG_GROUNDING_BASH_PATTERNS[@]}"; do
      if printf '%s' "$cmd" | grep -qiE -- "$p" 2>/dev/null; then
        printf 'grounding'; return 0
      fi
    done
  fi

  for p in "${DG_RISKY_TOOLS[@]}"; do
    if [ "$tool_name" = "$p" ]; then
      printf 'risky'; return 0
    fi
  done

  if [ "$tool_name" = "Bash" ] && [ -n "$cmd" ]; then
    for p in "${DG_RISKY_BASH_PATTERNS[@]}"; do
      if printf '%s' "$cmd" | grep -qiE -- "$p" 2>/dev/null; then
        printf 'risky'; return 0
      fi
    done
  fi

  printf 'neutral'
}
