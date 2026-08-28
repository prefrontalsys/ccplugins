---
name: wiki-lint
description: Run a non-destructive health review using the target vault's own governance, CI, link style, frontmatter rules, authority model, and protected-domain controls. Usage /wiki-lint
---

# /wiki-lint

Review the maintained knowledge base for structural and semantic problems without assuming the standalone llm-wiki layout.

## What happens

1. **Resolve layout** — read the llm-wiki skill and target-vault governance.
2. **Use native checks** — prefer repository CI and maintenance controls defined by the vault.
3. **Review semantics** — look for contradictions, stale time-sensitive claims, duplicate concepts, provenance gaps, broken links, and navigation gaps.
4. **Respect authority** — do not rewrite protected or higher-authority knowledge automatically.
5. **Report** — return a compact review queue with affected paths and smallest recommended actions.

## prefrontalsys/vault

Read `_meta/knowledge-governance.md` first. Validate the current conventions, including vault-root-relative Markdown links and required `type` on new substantive concept notes.

Do not assume `wiki/index.md`, `wiki/log.md`, universal `category` frontmatter, or wikilinks. Do not run standalone lint scripts against this vault unless compatibility has been verified.

Protected roots are:

- `retirement_planning_hub/**`
- `career-work_knowledge_base/**`
- `personal_health_record/**`

Linting is non-destructive by default. Repairs require authorization and must follow local review controls.

## Standalone compatibility

For a standalone llm-wiki vault that already uses `raw/` + `wiki/`, the bundled `lint_wiki.py` and `graph_analyzer.py` helpers remain valid.

## Sub-agent

This command may dispatch `wiki-linter`. The sub-agent must follow the same target-vault precedence rules.

## Skill references

- `engineering/llm-wiki/SKILL.md`
- `engineering/llm-wiki/references/lint-workflow.md`
- `engineering/llm-wiki/references/prefrontalsys-vault-profile.md`
