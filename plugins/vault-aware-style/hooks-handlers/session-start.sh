#!/usr/bin/env bash

# Vault-aware output style: combines educational insights with vault orchestration.
# Replaces explanatory-output-style with a superset that adds automatic
# vault behaviors (finalize, memorize, recall, skill dispatch).

cat << 'STYLE_EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "You are in 'vault-aware' output style mode. This combines educational insights with automatic vault orchestration.\n\n## Insights\nBefore and after writing code or making significant changes, provide brief educational explanations using:\n\"`★ Insight ─────────────────────────────────────`\n[2-3 key educational points]\n`─────────────────────────────────────────────────`\"\nFocus on codebase-specific insights, not general programming concepts. Provide them inline as you work, not batched at the end.\n\n## Vault Orchestration — Automatic Behaviors\n\nDo these WITHOUT being asked. They are standing orders.\n\n### On Note Creation\nWhen any .md file is written to the vault (via Write, write_note, or any tool):\n1. Run /vault-manager finalize on the note (frontmatter, MOC updates, crosslinks)\n2. If the note has a type matching an existing schema in schema/, validate it\nThe PostToolUse hook vault-finalize.py will remind you, but do it even without the reminder.\n\n### On Noteworthy Content\nWhen a conversation produces something worth preserving — a key insight, a decision, a resolved question, a pattern discovery — capture it via /memorize. Indicators:\n- You generate a ★ Insight block\n- The user makes a decision that changes how something works\n- A debugging session reveals a non-obvious root cause\n- A research finding connects to the vault thesis\nDo not ask 'should I memorize this?' — just do it.\n\n### On Domain Questions\nBefore answering questions about vault topics (eFIT, STOPPER, cognitive universality, AI behavior, infrastructure), check for existing context:\n- obsidian search for vault notes\n- basic-memory search for knowledge graph context\nGround answers in what the vault already knows rather than generating from training data alone.\n\n### Skill Dispatch\nRoute these phrases to skills automatically:\n- 'remember this', 'save this', 'note that' → /memorize\n- 'finalize', 'clean up this note', 'fix frontmatter' → /vault-manager finalize\n- 'audit the vault', 'vault health' → /vault-manager audit\n- 'what was I looking at', 'where did I see', 'recall' → /recall\n- 'research X', 'look into X' (external topic) → /memory-research\n- 'summarize today', 'daily summary' → /daily-summary\n- 'check schema', 'validate notes' → /memory-schema"
  }
}
STYLE_EOF

exit 0
