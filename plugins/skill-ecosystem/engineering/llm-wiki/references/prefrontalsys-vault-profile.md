# prefrontalsys/vault profile

This profile applies when the target repository is `prefrontalsys/vault`. It overrides generic llm-wiki examples that assume a standalone `raw/` + `wiki/` layout.

## Authority

Before changing the vault, read the local governance that applies to the target content. At minimum inspect:

- `_meta/knowledge-governance.md`
- `knowledge/knowledge.md`
- the relevant hub under `knowledge/hubs/`
- adjacent notes in the intended destination

Local vault governance and existing conventions take precedence over this skill. Do not create or restore obsolete llm-wiki folders merely to satisfy a generic example.

## Current knowledge layout

```text
<vault>/
├── knowledge/
│   ├── knowledge.md              # knowledge navigation root
│   ├── concepts/<domain>/        # durable concepts and frameworks
│   ├── references/               # source/reference notes
│   ├── research/<topic>/         # multi-source research and synthesis
│   ├── hubs/                     # navigation and topic hubs
│   └── projects/                 # project-scoped durable knowledge
├── inbox/                        # unresolved or temporary intake
├── _meta/                        # governance and maintenance metadata
├── retirement_planning_hub/      # protected canonical domain
├── career-work_knowledge_base/   # protected canonical domain
└── personal_health_record/       # protected canonical domain
```

For this vault, do not write to `raw/`, `wiki/`, `_inbox/`, `_agents/`, or `_archive/` unless a current vault policy explicitly introduces that path.

## Routing rules

Route a durable external article, report, paper, book, or other source to `knowledge/references/`. Create a concise source/reference note with provenance and a link to the original source. Do not copy a copyrighted web page or publication into the vault in full.

Route a durable reusable idea, method, framework, or design principle to the most relevant domain under `knowledge/concepts/`. Search existing concepts first and update an existing note when the new source provides evidence for an existing concept.

Route multi-source investigation, literature review, evolving thesis, or substantial synthesis to `knowledge/research/<topic>/`. Route project-specific material to `knowledge/projects/`. Update a hub only when the new material improves navigation. Use `inbox/` only when the destination cannot be resolved safely from current context.

## Ingest behavior

An explicit request such as “ingest this,” “add this to the vault,” or “save this source” authorizes the normal non-destructive ingest write set. Do not ask for a second confirmation unless the proposed change touches a protected canonical domain, deletes or moves content, changes a higher-authority claim, or presents a material unresolved contradiction.

Before writing:

1. Read the source.
2. Search the vault for the source URL/title and its major concepts.
3. Identify the smallest useful write set.
4. Check adjacent notes for frontmatter and organization conventions.

A normal web-source ingest usually creates one reference note and updates zero or more existing concept, research, or hub notes. There is no minimum file-touch count.

## Source handling

For a public URL, keep the URL as the source of record and store a copyright-safe summary, key claims, methodology or evidence notes when relevant, caveats, and connections. Record the access or ingest date when the local note family supports it.

For a user-supplied file already present in the vault or conversation, treat the original as source evidence. Do not move, rename, edit, duplicate, or archive it unless the user asks or local governance requires that action.

Preserve provenance. Follow the frontmatter conventions of adjacent files. New substantive concept notes must include a non-empty `type` field as required by vault CI. Do not normalize unrelated existing frontmatter during an ingest.

## Links and contradictions

Use vault-root-relative Markdown links, matching the vault's current convention, for example:

```markdown
[Agent Orchestration and Routing](knowledge/concepts/ai-systems/agent-orchestration-and-routing.md)
```

Do not convert existing Markdown links to wikilinks merely for llm-wiki compatibility.

When a source conflicts with existing knowledge, preserve both claims and their provenance. Flag the conflict in the smallest relevant note. Do not silently overwrite a higher-authority or protected claim.

## Protected domains

Changes under these paths require the review controls defined by `_meta/knowledge-governance.md`:

- `retirement_planning_hub/**`
- `career-work_knowledge_base/**`
- `personal_health_record/**`

External source ingestion should normally add supporting knowledge outside these protected roots unless the user explicitly requests a canonical-domain change.

## Completion criteria

An ingest is complete when:

- the source is represented once, without duplicate notes;
- durable claims are integrated only where they materially improve existing knowledge;
- provenance is sufficient to recover the original source;
- links resolve using vault-root-relative paths;
- protected canonical content is unchanged unless explicitly authorized;
- no obsolete `raw/` or `wiki/` hierarchy was introduced.
