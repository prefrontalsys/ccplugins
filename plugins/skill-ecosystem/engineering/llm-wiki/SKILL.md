---
name: llm-wiki
description: Use when building or maintaining a persistent personal knowledge base (second brain) in Obsidian where an LLM incrementally ingests sources, updates durable knowledge, maintains cross-references, and keeps synthesis current. Triggers include "second brain", "Obsidian wiki", "personal knowledge management", "ingest this paper/article/book", "build a research wiki", "compound knowledge", "Memex", or whenever the user wants knowledge to accumulate across sessions instead of being re-derived by RAG on every query.
context: fork
version: 1.1.0
author: claude-code-skills
license: MIT
tags: [knowledge-management, obsidian, second-brain, pkm, rag-alternative, wiki, karpathy, memex]
compatible_tools: [claude-code, codex-cli, cursor, antigravity, opencode, gemini-cli]
---

# LLM Wiki — Persistent Knowledge for Obsidian

Inspired by Andrej Karpathy's LLM Wiki pattern ([gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)). This skill turns an agent into a disciplined knowledge-base maintainer that incrementally integrates sources into a persistent, interlinked Obsidian vault.

## Core principle

Most LLM+docs workflows are retrieval-augmented generation (RAG): retrieve fragments at query time, synthesize from scratch, then discard the synthesis. The wiki is compounding: sources are integrated into durable notes, relationships, contradictions, and syntheses that remain available for later work.

> Obsidian is the authoring interface. The vault is the knowledge system. The agent must follow the vault's governance.

## Precedence rule

**Existing vault governance overrides this skill's default layout.**

Before any write to an existing vault:

1. Read repository or vault instructions and governance files.
2. Inspect the current directory structure and adjacent notes.
3. Search for an existing note that already represents the source or concept.
4. Use the established paths, frontmatter, link style, and review controls.

Do not create `raw/`, `wiki/`, `index.md`, `log.md`, or any other llm-wiki default artifact inside an existing governed vault unless local instructions already define or explicitly request it.

When the target is `prefrontalsys/vault`, read and follow `references/prefrontalsys-vault-profile.md`. That profile is authoritative for llm-wiki path routing in that vault.

## Two operating modes

### Governed existing vault

Use this mode when the target already has a knowledge architecture or governance policy. The skill adapts to that structure.

For `prefrontalsys/vault`, durable secondary knowledge lives under:

```text
knowledge/
├── knowledge.md
├── concepts/<domain>/
├── references/
├── research/<topic>/
├── hubs/
└── projects/
inbox/
_meta/
```

In this mode:

- external source notes normally go to `knowledge/references/`;
- durable concepts normally go to `knowledge/concepts/<domain>/`;
- multi-source research and synthesis go to `knowledge/research/<topic>/`;
- navigation belongs in `knowledge/hubs/`;
- project-scoped durable knowledge belongs in `knowledge/projects/`;
- unresolved intake may go to `inbox/`;
- protected canonical domains remain subject to local review controls.

Use the smallest useful write set. There is no minimum page-touch count.

### Standalone llm-wiki vault

Use this mode only when initializing a new standalone vault with this plugin or when an existing vault already uses this layout:

```text
vault/
├── raw/                    # immutable source files
├── wiki/                   # maintained knowledge base
│   ├── index.md
│   ├── log.md
│   ├── entities/
│   ├── concepts/
│   ├── sources/
│   ├── comparisons/
│   └── synthesis/
├── CLAUDE.md
└── AGENTS.md
```

The bundled Python scripts and starter templates primarily target this standalone layout.

## When to use

Use llm-wiki for knowledge expected to accumulate across sessions: research, source ingestion, durable concepts, project knowledge, book companions, competitive analysis, meeting-derived knowledge, and evolving syntheses.

Do not use it for one-shot Q&A over a fixed document, transient calculations, or content the user does not want persisted.

## Core operations

### 1. Ingest

Read a source, identify its durable contribution, search for overlap, then integrate only what improves the vault.

For an explicit request such as “ingest this,” “add this to the vault,” or “save this source,” the user has authorized normal non-destructive ingest writes. Do not ask for a second confirmation unless the change would:

- modify a protected canonical domain;
- delete, move, or replace existing content;
- overwrite a higher-authority claim;
- resolve a material contradiction by choosing one side without sufficient evidence.

For a governed vault, a normal web ingest often creates one reference note and updates zero or more existing concepts, research notes, or hubs. Do not manufacture extra pages to meet a quota.

See `references/ingest-workflow.md`.

### 2. Query

Start from the vault's navigation and existing structure. In `prefrontalsys/vault`, read `knowledge/knowledge.md`, relevant hubs, and targeted notes. Search semantically or textually when navigation is insufficient. Synthesize from the evidence already in the vault and cite the relevant notes.

Only file an answer back when it adds durable knowledge. Use the existing structure rather than creating a generic `wiki/` destination.

See `references/query-workflow.md`.

### 3. Lint

Use the vault's own validation and maintenance controls first. For `prefrontalsys/vault`, `_meta/knowledge-governance.md` and repository CI define the relevant checks. Surface broken links, duplicates, stale claims, contradictions, orphans, and governance violations without automatically rewriting canonical material.

The bundled lint scripts are suitable for standalone llm-wiki vaults and must not be assumed compatible with a governed layout.

See `references/lint-workflow.md`.

## Source handling

A source of record does not need to be copied into the vault.

For public web sources, preserve the URL and enough provenance to recover the source. Store a copyright-safe summary, key claims, evidence or methodology notes when useful, caveats, and connections. Do not copy a copyrighted article, report, paper, or book into the vault in full.

For a user-supplied file already present in the vault or conversation, treat that original as source evidence. Do not move, rename, edit, duplicate, or archive it unless the user asks or local governance requires it.

## Knowledge routing for prefrontalsys/vault

Use `references/prefrontalsys-vault-profile.md` for the full profile. The short routing rule is:

- source/report/article/paper reference → `knowledge/references/`
- reusable concept/framework/method → existing or new `knowledge/concepts/<domain>/`
- multi-source research or evolving thesis → `knowledge/research/<topic>/`
- navigation → `knowledge/hubs/`
- project-specific durable knowledge → `knowledge/projects/`
- unresolved intake → `inbox/`

Search before creating. Prefer updating an existing concept over creating a near-duplicate.

## Frontmatter and links

Local conventions take precedence. Preserve the frontmatter style of adjacent files and do not normalize unrelated notes during an ingest.

For `prefrontalsys/vault`:

- new substantive concept notes must have a non-empty `type` field as required by vault CI;
- use vault-root-relative Markdown links;
- preserve provenance for imported or derived claims;
- use the current lifecycle/status conventions of the destination note family.

Do not convert the vault to Obsidian wikilinks merely because standalone llm-wiki examples use them.

## Contradictions and authority

A new source may add evidence or surface a conflict. It must not silently overwrite higher-authority knowledge.

When claims conflict:

1. preserve both claims and their provenance;
2. record the disagreement in the smallest relevant note;
3. distinguish extracted facts from inference when the local note family does so;
4. require explicit review before changing protected canonical knowledge.

## Protected domains in prefrontalsys/vault

The following roots are protected by local governance:

- `retirement_planning_hub/**`
- `career-work_knowledge_base/**`
- `personal_health_record/**`

Do not modify them as a side effect of ordinary external-source ingestion.

## Slash commands

| Command | Purpose |
|---|---|
| `/wiki-init` | Bootstrap a new standalone llm-wiki vault |
| `/wiki-ingest <source>` | Ingest a file or URL into the current vault using local governance |
| `/wiki-query <question>` | Query the maintained knowledge base |
| `/wiki-lint` | Run layout-appropriate health checks |
| `/wiki-log` | Show the standalone llm-wiki log when that layout exists |

## Sub-agents

| Agent | When dispatched |
|---|---|
| `wiki-ingestor` | Integrates one source using the target vault's current layout |
| `wiki-linter` | Runs a non-destructive health review |
| `wiki-librarian` | Answers queries from maintained knowledge |

## Python tools

The scripts under `scripts/` are standard-library helpers for the standalone llm-wiki layout. Do not run a script that assumes `wiki/` or `raw/` against a governed vault unless it has first been verified against that layout.

## Completion criteria

An llm-wiki operation succeeds when:

- local governance was followed;
- no obsolete hierarchy was introduced into an existing vault;
- the source or knowledge is represented once, without avoidable duplication;
- durable claims were integrated only where they materially improve existing notes;
- provenance is sufficient to recover the evidence;
- links resolve using the vault's current convention;
- protected content is unchanged unless explicitly authorized;
- only necessary files were touched.

## Reference docs

- `references/prefrontalsys-vault-profile.md` — governed profile for `prefrontalsys/vault`
- `references/wiki-schema.md` — layout precedence and standalone schema
- `references/page-formats.md` — governed-vault and standalone note patterns
- `references/ingest-workflow.md` — ingestion workflow
- `references/query-workflow.md` — query workflow
- `references/lint-workflow.md` — health-check workflow
- `references/obsidian-setup.md` — Obsidian setup
- `references/cross-tool-setup.md` — cross-tool setup
- `references/memex-principles.md` — compounding-knowledge rationale

## Iron rule

**Never force the plugin's default filesystem layout onto an existing governed vault. Local governance is the schema.**
