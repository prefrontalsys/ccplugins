# agents

General-purpose agent fleet for Claude Code. Twelve standalone agents covering software engineering, writing, editing, research, reasoning, and knowledge management. No personality system dependencies.

## Agents

| Agent | Model | Role |
|-------|-------|------|
| `worker` | sonnet | General-purpose coding, file ops, research |
| `doer` | haiku | Mechanical execution: bash, GitHub ops, infra |
| `thinker` | opus | Multi-step reasoning, hypothesis testing |
| `planner` | sonnet | Implementation planning, architectural tradeoffs |
| `engineer` | sonnet | Code, scripts, config, infrastructure |
| `prompter` | sonnet | Prompt engineering for other LLMs |
| `sherlock` | opus | Error diagnosis, behavioral bugs, crash post-mortems |
| `searcher` | sonnet | Web and academic search specialist |
| `skiller` | sonnet | SKILL.md authoring for Claude Code |
| `writer` | opus | Long-form prose generation |
| `editor` | opus | Essay and long-form prose editing |
| `knowledge-guide` | opus | Obsidian vault note quality advisor |

## Install

```
/plugin install agents@ccplugins
```

## Notes

- `writer` contains user-specific voice anchors (register, structural rules, anti-tells). Customize or remove the Voice section to suit your own style.
- `editor` references the user's Obsidian vault via `obsidian search`. If you don't use Obsidian, remove that step from the Process section.
- `knowledge-guide` is designed for Obsidian vaults using atomic claim-based notes (Zettelkasten-style).
