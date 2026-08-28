---
name: wiki-ingest
description: Ingest a file or URL into the current maintained knowledge vault. Detect the target vault's governance and layout, deduplicate the source, create or update its reference note, integrate only durable knowledge, preserve contradictions and provenance, and touch only necessary files. Usage /wiki-ingest <source>
---

# /wiki-ingest

Ingest one source into the current maintained knowledge base.

## Usage

```text
/wiki-ingest <path-or-url>
/wiki-ingest https://example.com/report
/wiki-ingest path/to/source.pdf
```

## Layout selection

Read `engineering/llm-wiki/SKILL.md` first.

If the target is `prefrontalsys/vault`, use `engineering/llm-wiki/references/prefrontalsys-vault-profile.md`. Do not create `raw/`, `wiki/`, `index.md`, or `log.md` there.

Use the plugin's legacy `raw/` + `wiki/` behavior only for a standalone llm-wiki vault that already uses that structure or when the user explicitly initializes a new one.

## What happens

1. **Inspect** the target vault's governance, navigation, adjacent notes, and protected domains.
2. **Read** the URL or source file directly. A public URL does not need to be copied into the vault first.
3. **Deduplicate** by source URL/title and search for existing concepts or research covering the same ideas.
4. **Route** the source and durable knowledge using the current vault layout.
5. **Write** the smallest useful set of files. For `prefrontalsys/vault`, a normal web ingest usually creates or updates one note in `knowledge/references/` and may update relevant `knowledge/concepts/`, `knowledge/research/`, `knowledge/projects/`, or `knowledge/hubs/` notes.
6. **Validate** provenance, links, frontmatter, duplicate avoidance, protected paths, and the final diff.
7. **Report** the files created or changed and any material contradiction or source limitation.

## Authorization

An explicit request to ingest, add, or save a source authorizes normal non-destructive ingest writes. Do not require a second confirmation.

Stop for explicit review only if the ingest would modify a protected canonical domain, delete/move/replace content, overwrite a higher-authority claim, or resolve a material contradiction by choosing one side without adequate evidence.

## Rules for prefrontalsys/vault

- Source/reference notes go to `knowledge/references/`.
- Reusable concepts go to the relevant `knowledge/concepts/<domain>/` note, preferably an existing one.
- Multi-source research and synthesis go to `knowledge/research/<topic>/`.
- Project-scoped durable knowledge goes to `knowledge/projects/`.
- Hubs are navigation, not ingest logs.
- Use `inbox/` only when the destination cannot be resolved safely.
- Use vault-root-relative Markdown links.
- New substantive concepts must include a non-empty `type` field.
- Do not modify `retirement_planning_hub/**`, `career-work_knowledge_base/**`, or `personal_health_record/**` as an ordinary ingest side effect.
- Do not reproduce copyrighted web publications in full.
- There is no minimum file-touch count.

## Sub-agent

This command may dispatch the `wiki-ingestor` sub-agent. The sub-agent must follow the same target-vault precedence rules.

## Skill references

- `engineering/llm-wiki/SKILL.md`
- `engineering/llm-wiki/references/prefrontalsys-vault-profile.md`
- `engineering/llm-wiki/references/ingest-workflow.md`
