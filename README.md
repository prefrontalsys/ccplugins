# ccplugins

Custom Claude Code plugins by prefrontalsys.

## Plugins

| Plugin | Description |
|--------|-------------|
| `agents` | General-purpose agent fleet — worker, doer, thinker, planner, engineer, prompter, sherlock, searcher, skiller, writer, editor, knowledge-guide |
| `thinking-partner` | Always-on thinking partner output style with Insight and Notable blocks |
| `vault-aware-style` | Vault-aware output style with automatic vault orchestration |
| `prose-style` | Prose-first output style for longform writing |
| `docs-gate` | `PreToolUse` hook that hard-blocks further edit/debug tool calls after N consecutive attempts with no documentation lookup in between — pure counting and pattern matching, no LLM judgment |

## Install

```
/plugin install agents@ccplugins
/plugin install thinking-partner@ccplugins
/plugin install docs-gate@ccplugins
```
