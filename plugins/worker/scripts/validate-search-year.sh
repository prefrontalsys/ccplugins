#!/usr/bin/env bash
# validate-search-year.sh — PreToolUse hook for WebSearch
# Denies search queries containing a wrong year. Forces the model to use
# the current year instead of defaulting to training-data years.
#
# Mechanism: hard deny (permissionDecision: deny), not advisory.
# The tool call never executes — the model must rewrite the query.
set -euo pipefail

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null) || exit 0

# Only inspect WebSearch calls
[[ "$TOOL" == "WebSearch" ]] || exit 0

QUERY=$(echo "$INPUT" | jq -r '.tool_input.query // empty' 2>/dev/null) || exit 0
[[ -z "$QUERY" ]] && exit 0

CURRENT_YEAR=$(date +%Y)

# Check that the current year appears somewhere in the query.
# Other years (e.g. "2025 vs 2026") are fine as long as the current year is present.
if echo "$QUERY" | grep -qE "\b${CURRENT_YEAR}\b"; then
  exit 0
fi

# If no years appear at all, that's fine — not every search needs a year
# Filter out year-like numbers that follow RFC/ISO/PEP/etc. prefixes
STRIPPED=$(echo "$QUERY" | sed -E 's/(RFC|ISO|PEP|CVE|BIP|EIP)[- ]?[0-9]+(-[0-9]+)*//gi')
YEARS=$(echo "$STRIPPED" | grep -oE '\b20[0-9]{2}\b' || true)
[[ -z "$YEARS" ]] && exit 0

# Query contains year(s) but NOT the current year — deny
jq -n --arg reason "Search query contains year(s) ($YEARS) but not the current year ($CURRENT_YEAR). Add $CURRENT_YEAR to your query or remove the stale year." \
  '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":$reason}}'
exit 0
