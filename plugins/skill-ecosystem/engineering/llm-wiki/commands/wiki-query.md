---
name: wiki-query
description: Query the maintained knowledge vault using its current governance and navigation. Read the smallest relevant evidence set, synthesize with provenance, and file back only durable knowledge when appropriate. Usage /wiki-query "<question>"
---

# /wiki-query

Ask the maintained knowledge base a question without assuming a particular filesystem layout.

## Usage

```text
/wiki-query "<your question>"
```

## What happens

1. **Resolve layout** — read the llm-wiki skill and target-vault governance.
2. **Navigate** — use the vault's current knowledge root and hubs before broader search.
3. **Read evidence** — inspect the smallest set of relevant concept, research, project, reference, or canonical notes.
4. **Synthesize** — answer directly while preserving provenance, qualifiers, and authority.
5. **Persist selectively** — write back only durable knowledge and route it using the target vault's existing structure.

## prefrontalsys/vault

Start from `knowledge/knowledge.md`, then the relevant file under `knowledge/hubs/`. Follow vault-root-relative Markdown links and search targeted paths when navigation is insufficient.

Do not expect `wiki/index.md`, `wiki/log.md`, or wikilink-only citations. Do not create `wiki/comparisons/` or `wiki/synthesis/` to save an answer.

If persistence is appropriate, route the result according to `references/prefrontalsys-vault-profile.md` and search for an existing destination first.

Protected canonical roots retain the authority and review controls defined by `_meta/knowledge-governance.md`.

## Standalone compatibility

For a standalone llm-wiki vault that already uses `wiki/index.md`, the bundled index-first search, wikilink citations, comparison/synthesis folders, and log workflow remain valid.

## Sub-agent

This command may dispatch `wiki-librarian`. The sub-agent must follow the same target-vault precedence rules.

## Skill references

- `engineering/llm-wiki/SKILL.md`
- `engineering/llm-wiki/references/query-workflow.md`
- `engineering/llm-wiki/references/prefrontalsys-vault-profile.md`
