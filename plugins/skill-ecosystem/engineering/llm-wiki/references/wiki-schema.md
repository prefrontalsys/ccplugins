# Wiki Schema

llm-wiki supports two layouts. The target vault decides which one applies.

## Precedence

For an existing vault, local governance and established structure are authoritative. Inspect the repository before writing. Do not create the standalone llm-wiki hierarchy inside a governed vault merely because this plugin ships templates for it.

When the target is `prefrontalsys/vault`, use `references/prefrontalsys-vault-profile.md`.

## Governed layout: prefrontalsys/vault

```text
<vault>/
├── knowledge/
│   ├── knowledge.md
│   ├── concepts/<domain>/
│   ├── references/
│   ├── research/<topic>/
│   ├── hubs/
│   └── projects/
├── inbox/
├── _meta/
├── retirement_planning_hub/
├── career-work_knowledge_base/
└── personal_health_record/
```

### Routing

- `knowledge/references/` stores durable source and reference notes.
- `knowledge/concepts/<domain>/` stores reusable ideas, methods, frameworks, and design principles.
- `knowledge/research/<topic>/` stores multi-source research and evolving synthesis.
- `knowledge/hubs/` stores navigation and topic hubs.
- `knowledge/projects/` stores project-scoped durable knowledge.
- `inbox/` is temporary intake when a destination cannot be resolved safely.

Do not introduce `raw/`, `wiki/`, `_inbox/`, `_agents/`, or `_archive/` into this vault unless current local governance explicitly defines them.

### Frontmatter

Follow adjacent files. Do not perform broad schema normalization during an ingest.

New substantive concept notes must include a non-empty `type` field to satisfy vault CI. Preserve the destination family’s existing `status`, `lifecycle`, `tags`, `sources`, provenance, confidence, and date conventions where applicable.

### Linking

Use vault-root-relative Markdown links, for example:

```markdown
[Structural Guardrails](knowledge/concepts/ai-systems/structural-guardrails.md)
```

Do not convert existing links to Obsidian wikilinks as a side effect of ingestion.

### Authority and protected content

Local governance defines authority. A new external source may add evidence or expose a conflict but must not silently overwrite a higher-authority claim.

The following roots are protected and require the review controls in `_meta/knowledge-governance.md`:

- `retirement_planning_hub/**`
- `career-work_knowledge_base/**`
- `personal_health_record/**`

Ordinary source ingestion should not modify these directories.

## Standalone llm-wiki layout

Use this layout only for a newly initialized llm-wiki vault or an existing vault that already follows it.

```text
<vault>/
├── raw/                        # immutable source files
│   ├── articles/*.md
│   ├── papers/*.pdf
│   ├── notes/*.md
│   └── assets/
├── wiki/
│   ├── index.md
│   ├── log.md
│   ├── entities/
│   ├── concepts/
│   ├── sources/
│   ├── comparisons/
│   ├── synthesis/
│   └── .templates/
├── CLAUDE.md
├── AGENTS.md
└── .cursorrules
```

For this standalone layout only:

1. `raw/` is immutable.
2. Maintained knowledge is written under `wiki/`.
3. Pages use YAML frontmatter expected by the bundled indexing and lint scripts.
4. `wiki/index.md` and `wiki/log.md` are maintained by the standalone workflow.

The bundled Python scripts target this layout unless their implementation explicitly says otherwise.

## General rules

Regardless of layout:

- Search for duplicates before creating a page.
- Preserve source provenance.
- Use the smallest useful write set. There is no universal minimum file-touch count.
- Preserve contradictions rather than silently resolving them.
- Do not copy copyrighted web publications into the vault in full. Prefer a source/reference note with a concise summary and source pointer.
- Touch navigation only when a new note materially improves discoverability.
- Let local governance define link syntax, frontmatter, status, lifecycle, and review gates.
