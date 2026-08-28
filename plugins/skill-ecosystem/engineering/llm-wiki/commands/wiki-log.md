---
name: wiki-log
description: Show the llm-wiki operation log when the target vault defines one. Standalone llm-wiki vaults use wiki/log.md; governed vaults use their own repository history and maintenance controls instead of creating a synthetic log. Usage /wiki-log
---

# /wiki-log

Show recent llm-wiki activity using the logging mechanism defined by the target vault.

## Governed vaults

Do not create `wiki/log.md` solely to support this command.

For `prefrontalsys/vault`, Git history, pull requests, issues, and the maintenance controls described in `_meta/knowledge-governance.md` are the authoritative operational record. If the user asks for recent knowledge changes, inspect those sources or the relevant file history rather than introducing a parallel append-only log.

## Standalone llm-wiki vaults

If the target already uses the standalone `raw/` + `wiki/` layout, `wiki/log.md` remains supported. Show recent standardized entries from that file and use the bundled append-log helper when the standalone workflow calls for it.

## Rule

Logging follows local governance. A helper command must not create a new source of operational truth in an existing governed vault.

## Skill reference

- `engineering/llm-wiki/SKILL.md`
