#!/usr/bin/env bash
# tests/docs-gate.test.sh — self-contained test suite for docs-gate.sh.
# No test framework: plain bash + jq, asserting exit codes and stderr text.
# Every test runs against an isolated temp state dir so nothing here ever
# touches the real ~/.claude/state/docs-gate.

set -u

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$HERE/../hooks-handlers/docs-gate.sh"
BASH_BIN="$(command -v bash)"

PASS=0
FAIL=0

fresh_state_dir() {
  local d
  d="$(mktemp -d "${TMPDIR:-/tmp}/docs-gate-test.XXXXXX")"
  printf '%s' "$d"
}

# run_hook <state_dir> <session_id> <tool_name> <bash_command_or_empty>
# Prints "<exit_code>|<stderr>" on stdout.
run_hook() {
  local state_dir="$1" session_id="$2" tool_name="$3" cmd="$4"
  local payload out err ec
  payload=$(jq -n --arg sid "$session_id" --arg tn "$tool_name" --arg cmd "$cmd" \
    '{session_id: $sid, hook_event_name: "PreToolUse", tool_name: $tn, tool_input: ({} + (if $cmd != "" then {command: $cmd} else {} end))}')
  err=$(mktemp)
  out=$(DOCS_GATE_STATE_DIR="$state_dir" \
        DOCS_GATE_CONFIG="$state_dir/config.json" \
        DOCS_GATE_OFF_FILE="$state_dir/OFF" \
        DOCS_GATE_SESSIONS_DIR="$state_dir/sessions" \
        DOCS_GATE_ERROR_LOG="$state_dir/error.log" \
        bash "$HOOK" <<<"$payload" 2>"$err")
  ec=$?
  printf '%s|%s' "$ec" "$(cat "$err")"
  rm -f "$err"
}

assert_eq() {
  local desc="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    PASS=$((PASS + 1))
    printf 'PASS: %s\n' "$desc"
  else
    FAIL=$((FAIL + 1))
    printf 'FAIL: %s (expected=%q actual=%q)\n' "$desc" "$expected" "$actual"
  fi
}

assert_contains() {
  local desc="$1" needle="$2" haystack="$3"
  case "$haystack" in
    *"$needle"*) PASS=$((PASS + 1)); printf 'PASS: %s\n' "$desc" ;;
    *) FAIL=$((FAIL + 1)); printf 'FAIL: %s (expected to contain %q, got %q)\n' "$desc" "$needle" "$haystack" ;;
  esac
}

# ── Test 1: risky calls under threshold are allowed ──────────────────────
{
  d=$(fresh_state_dir)
  sid="test-under-threshold"
  for i in 1 2 3; do
    result=$(run_hook "$d" "$sid" "Edit" "")
    ec="${result%%|*}"
    assert_eq "under-threshold risky call #$i is allowed" "0" "$ec"
  done
  rm -rf "$d"
}

# ── Test 2: risky calls over threshold are blocked ────────────────────────
{
  d=$(fresh_state_dir)
  sid="test-over-threshold"
  for i in 1 2 3; do
    run_hook "$d" "$sid" "Edit" "" >/dev/null
  done
  result=$(run_hook "$d" "$sid" "Edit" "")
  ec="${result%%|*}"
  err="${result#*|}"
  assert_eq "4th consecutive risky call is blocked" "2" "$ec"
  assert_contains "block message mentions consulting documentation" "documentation" "$err"
  assert_contains "block message mentions context7" "context7" "$err"
  rm -rf "$d"
}

# ── Test 3: a grounding call resets the counter ───────────────────────────
{
  d=$(fresh_state_dir)
  sid="test-grounding-reset"
  for i in 1 2 3; do
    run_hook "$d" "$sid" "Edit" "" >/dev/null
  done
  # Would block without a reset:
  result=$(run_hook "$d" "$sid" "WebFetch" "")
  ec="${result%%|*}"
  assert_eq "grounding call (WebFetch) itself is always allowed" "0" "$ec"

  # Counter should now be back to 0, so 3 more risky calls are allowed again.
  for i in 1 2 3; do
    result=$(run_hook "$d" "$sid" "Edit" "")
    ec="${result%%|*}"
    assert_eq "post-reset risky call #$i is allowed" "0" "$ec"
  done
  # And the 4th should block again.
  result=$(run_hook "$d" "$sid" "Edit" "")
  ec="${result%%|*}"
  assert_eq "post-reset 4th risky call blocks again" "2" "$ec"
  rm -rf "$d"
}

# ── Test 1b: risky Bash commands (the headline "debug attempt" path) ─────
{
  d=$(fresh_state_dir)
  sid="test-risky-bash-pattern"
  for i in 1 2 3; do
    result=$(run_hook "$d" "$sid" "Bash" "pytest tests/")
    ec="${result%%|*}"
    assert_eq "under-threshold risky Bash (pytest) call #$i is allowed" "0" "$ec"
  done
  result=$(run_hook "$d" "$sid" "Bash" "npm test")
  ec="${result%%|*}"
  err="${result#*|}"
  assert_eq "4th risky Bash call (npm test) blocks" "2" "$ec"
  assert_contains "Bash-triggered block message mentions documentation" "documentation" "$err"
  rm -rf "$d"
}

# ── Test 1c: neutral tools never increment or block ───────────────────────
{
  d=$(fresh_state_dir)
  sid="test-neutral-tools"
  for i in 1 2 3 4 5; do
    result=$(run_hook "$d" "$sid" "Read" "")
    ec="${result%%|*}"
    assert_eq "neutral Read call #$i never blocks" "0" "$ec"
  done
  # A neutral Bash command (no risky/grounding pattern match) behaves the same.
  for i in 1 2 3 4 5; do
    result=$(run_hook "$d" "$sid" "Bash" "ls -la")
    ec="${result%%|*}"
    assert_eq "neutral Bash call #$i never blocks" "0" "$ec"
  done
  rm -rf "$d"
}

# ── Test 1d: file paths containing risky substrings are NOT risky ────────
# Regression test for a real false positive hit during development: a plain
# file copy whose path contains "test"/"python3"/"error" as a substring
# must not classify as risky -- only the invoked command should.
{
  d=$(fresh_state_dir)
  sid="test-path-substring-false-positive"
  for i in 1 2 3 4 5; do
    result=$(run_hook "$d" "$sid" "Bash" "cp tests/docs-gate.test.sh /tmp/backup/docs-gate.test.sh")
    ec="${result%%|*}"
    assert_eq "cp of a *.test.sh path never blocks #$i" "0" "$ec"
  done
  result=$(run_hook "$d" "$sid" "Bash" "ls /usr/local/lib/python3.11/site-packages")
  ec="${result%%|*}"
  assert_eq "listing a python3.11 directory never blocks" "0" "$ec"
  result=$(run_hook "$d" "$sid" "Bash" "git log --oneline -- error-handling.md")
  ec="${result%%|*}"
  assert_eq "referencing an error-handling.md path never blocks" "0" "$ec"
  rm -rf "$d"
}

{
  d=$(fresh_state_dir)
  sid="test-path-substring-sanity-blocks"
  for i in 1 2 3 4; do
    run_hook "$d" "$sid" "Bash" "pytest tests/" >/dev/null
  done
  result=$(run_hook "$d" "$sid" "Bash" "pytest tests/")
  ec="${result%%|*}"
  assert_eq "sanity: 4 real pytest invocations do eventually block" "2" "$ec"
  rm -rf "$d"
}

# ── Test 3b: grounding via mcp__ context7/deepwiki tool names ────────────
{
  d=$(fresh_state_dir)
  sid="test-mcp-grounding"
  for i in 1 2 3; do
    run_hook "$d" "$sid" "Edit" "" >/dev/null
  done
  result=$(run_hook "$d" "$sid" "mcp__claude_ai_Context7__query-docs" "")
  ec="${result%%|*}"
  assert_eq "mcp context7 tool call resets counter" "0" "$ec"
  result=$(run_hook "$d" "$sid" "Edit" "")
  ec="${result%%|*}"
  assert_eq "risky call right after mcp grounding is allowed" "0" "$ec"
  rm -rf "$d"
}

# ── Test 3c: grounding via gh CLI through Bash ────────────────────────────
{
  d=$(fresh_state_dir)
  sid="test-gh-grounding"
  for i in 1 2 3; do
    run_hook "$d" "$sid" "Edit" "" >/dev/null
  done
  result=$(run_hook "$d" "$sid" "Bash" "gh issue view 42")
  ec="${result%%|*}"
  assert_eq "gh issue view via Bash resets counter" "0" "$ec"
  result=$(run_hook "$d" "$sid" "Edit" "")
  ec="${result%%|*}"
  assert_eq "risky call right after gh grounding is allowed" "0" "$ec"
  rm -rf "$d"
}

# ── Test 4: OFF kill-switch disables the hard block instantly ────────────
{
  d=$(fresh_state_dir)
  sid="test-off-switch"
  for i in 1 2 3 4; do
    run_hook "$d" "$sid" "Edit" "" >/dev/null
  done
  # Sanity: without the switch, a 5th call would block.
  result=$(run_hook "$d" "$sid" "Edit" "")
  ec="${result%%|*}"
  assert_eq "sanity: 5th risky call blocks before OFF is set" "2" "$ec"

  mkdir -p "$d"
  touch "$d/OFF"
  result=$(run_hook "$d" "$sid" "Edit" "")
  ec="${result%%|*}"
  assert_eq "risky call allowed once OFF file exists" "0" "$ec"
  rm -rf "$d"
}

# ── Test 5: malformed / missing state fails open ──────────────────────────
{
  d=$(fresh_state_dir)
  sid="test-corrupt-state"
  mkdir -p "$d/sessions"
  # Pre-seed a corrupt state file at the hashed path the hook will read.
  hash_src="
SCRIPT_DIR=\"$HERE/../hooks\"
source \"\$SCRIPT_DIR/lib/docs-gate-lib.sh\"
dg_hash_session_id '$sid'
"
  session_hash=$(bash -c "$hash_src")
  printf '{not valid json' > "$d/sessions/${session_hash}.json"
  result=$(run_hook "$d" "$sid" "Edit" "")
  ec="${result%%|*}"
  assert_eq "corrupt state file still allows (treated as counter 0)" "0" "$ec"
  rm -rf "$d"
}

{
  d=$(fresh_state_dir)
  sid="test-missing-state-dir"
  # sessions/ directory doesn't even exist yet.
  result=$(run_hook "$d" "$sid" "Edit" "")
  ec="${result%%|*}"
  assert_eq "missing sessions dir still allows" "0" "$ec"
  rm -rf "$d"
}

{
  d=$(fresh_state_dir)
  # Malformed JSON on stdin entirely.
  err=$(mktemp)
  out=$(DOCS_GATE_STATE_DIR="$d" \
        DOCS_GATE_CONFIG="$d/config.json" \
        DOCS_GATE_OFF_FILE="$d/OFF" \
        DOCS_GATE_SESSIONS_DIR="$d/sessions" \
        DOCS_GATE_ERROR_LOG="$d/error.log" \
        bash "$HOOK" <<<'not { valid json at all' 2>"$err")
  ec=$?
  assert_eq "malformed stdin JSON fails open" "0" "$ec"
  rm -f "$err"
  rm -rf "$d"
}

{
  d=$(fresh_state_dir)
  # Simulate jq missing while every other tool the script needs (dirname,
  # cat, mkdir, mv, rm, date, cut, tr, grep) is still on PATH -- isolates
  # "jq missing" from "PATH is generally broken".
  err=$(mktemp)
  payload='{"session_id":"x","hook_event_name":"PreToolUse","tool_name":"Edit","tool_input":{}}'
  fake_bin=$(mktemp -d "${TMPDIR:-/tmp}/docs-gate-nojq.XXXXXX")
  for tool in dirname cat mkdir mv rm date cut tr grep sed basename; do
    src=$(command -v "$tool" 2>/dev/null) && ln -s "$src" "$fake_bin/$tool"
  done
  out=$(DOCS_GATE_STATE_DIR="$d" PATH="$fake_bin" \
        "$BASH_BIN" "$HOOK" <<<"$payload" 2>"$err")
  ec=$?
  assert_eq "missing jq on PATH fails open" "0" "$ec"
  rm -f "$err"
  rm -rf "$d" "$fake_bin"
}

echo ""
echo "----------------------------------------"
echo "PASS: $PASS  FAIL: $FAIL"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
