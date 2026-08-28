# Page Formats

Page format is a property of the target vault, not of llm-wiki. Inspect adjacent notes before creating or updating content.

## prefrontalsys/vault

When the target is `prefrontalsys/vault`, follow `references/prefrontalsys-vault-profile.md` and the frontmatter conventions of the destination directory. Preserve existing fields instead of normalizing unrelated notes.

### Source/reference note

Destination: `knowledge/references/<slug>.md`

Use a compact reference note that preserves provenance without copying a copyrighted source in full. A new note should normally include a non-empty `type` field plus the metadata supported by adjacent files.

```markdown
---
title: State of AI in Development 2026
type: reference
status: active
tags: [ai-agents, software-development, survey]
sources:
  - "https://example.com/report"
summary: Concise statement of what the source contributes to the vault.
created: 2026-08-28
updated: 2026-08-28
---

# State of AI in Development 2026

Short identification of the source, publisher, date, and scope.

## Key findings

- Durable finding with enough context to avoid overstating it.
- Another finding.

## Method and limits

Sample, methodology, vendor context, uncertainty, and other limits that affect interpretation.

## Why it matters here

Explain the source's relationship to existing concepts or research.

## Related

- [Existing Concept](knowledge/concepts/<domain>/<concept>.md)
```

If adjacent reference notes use a different established field set, follow the local pattern. Do not rewrite existing notes merely to add this template's fields.

### Concept note

Destination: `knowledge/concepts/<domain>/<slug>.md`

A new substantive concept note must have a non-empty `type` field. Prefer updating an existing concept when one already covers the idea.

```markdown
---
title: Agent Orchestration and Routing
type: concept
category: concepts
tags: [ai-systems, agents, orchestration]
sources:
  - "knowledge/references/example-source.md"
summary: Durable statement of the concept.
created: 2026-08-28
updated: 2026-08-28
---

# Agent Orchestration and Routing

Definition or core principle.

## Evidence and implications

Integrate durable evidence from sources without turning the page into a source-by-source transcript.

## Related

- [Related Concept](knowledge/concepts/<domain>/<related>.md)
```

### Research note

Destination: `knowledge/research/<topic>/<slug>.md`

Use for multi-source investigation, an evolving thesis, literature review, research agenda, or substantial synthesis. Preserve claim-level provenance and distinguish evidence from inference when that distinction matters.

### Hub note

Destination: `knowledge/hubs/<slug>.md`

Hubs are navigation. Add a note to a hub only when doing so materially improves discoverability. Do not use a hub as an ingest log.

### Project note

Destination: `knowledge/projects/<project>/...`

Use when the durable knowledge is meaningful primarily inside a project. Follow that project's existing organization and frontmatter.

## Link format for prefrontalsys/vault

Use vault-root-relative Markdown links:

```markdown
[Verification Outside the Reasoning Context](knowledge/concepts/ai-systems/verification-outside-reasoning-context.md)
```

Do not convert existing Markdown links to wikilinks as a side effect of ingestion.

## Standalone llm-wiki vaults

The original five page categories remain valid for standalone vaults initialized by this plugin:

- `wiki/entities/` for durable entities
- `wiki/concepts/` for concepts
- `wiki/sources/` for source summaries
- `wiki/comparisons/` for explicit comparisons
- `wiki/synthesis/` for high-level syntheses

Those pages use the standalone frontmatter expected by the bundled scripts, including `title`, `category`, `summary`, and `updated`. Wikilinks are appropriate when that standalone vault uses them.

Do not apply the standalone templates to a governed vault whose local schema differs.
