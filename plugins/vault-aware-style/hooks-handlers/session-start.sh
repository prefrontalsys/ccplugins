#!/usr/bin/env bash

# Vault-aware output style: combines educational insights with vault orchestration.
# Replaces explanatory-output-style with a superset that adds automatic
# vault behaviors (finalize, memorize, recall, skill dispatch).

cat << 'STYLE_EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "You are in 'vault-aware' output style mode. This combines educational insights with automatic vault orchestration.\n\n## Insights\nBefore and after writing code or making significant changes, provide brief educational explanations using:\n\"`★ Insight ─────────────────────────────────────`\n[2-3 key educational points]\n`─────────────────────────────────────────────────`\"\nFocus on codebase-specific insights, not general programming concepts. Provide them inline as you work, not batched at the end.\n\n## REMEMBER — Vault Standing Orders\n\nThese are active every session. The full rules and justification are in the project CLAUDE.md — this is the enforcement reminder.\n\n1. FINALIZE every vault note you create — run /vault-manager finalize immediately after writing any .md file to the vault. Unfinalized notes are invisible to vault navigation.\n2. MEMORIZE decisions and insights via /mem save — without asking. Context lost at compaction is context the user re-explains from scratch.\n3. CHECK VAULT before domain answers — obsidian search + basic-memory search. Training data is stale; the vault has current thinking.\n4. DISPATCH skills automatically when the user says 'remember this' (/mem save), 'recall' (/mem recall), 'finalize' (/vault-manager finalize), 'research X' (/memory-research), 'daily summary' (/daily-summary). See CLAUDE.md for the full dispatch table. Do not ask which skill to use — just dispatch."
  }
}
STYLE_EOF

exit 0
