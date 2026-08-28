# Query Workflow

Use this flow when the user runs `/wiki-query <question>` or asks a question that should be answered from the maintained vault.

## 1. Resolve the target layout

Local vault governance and navigation take precedence over llm-wiki defaults.

For `prefrontalsys/vault`, begin with `knowledge/knowledge.md`, then read the relevant hub under `knowledge/hubs/` and the most relevant concept, research, project, or reference notes. Do not expect `wiki/index.md` to exist.

For a standalone llm-wiki vault that already uses `wiki/index.md`, the original index-first workflow remains valid.

## 2. Find the smallest relevant evidence set

Use existing navigation first. Follow root-relative Markdown links when they clearly lead to relevant evidence. Search the vault when navigation is insufficient or the topic is narrow.

Do not read the entire vault by default. Do not assume the bundled `wiki_search.py` script is compatible with a governed layout; use the search facilities available in the current environment unless the script has been verified for that vault.

## 3. Read evidence in context

Read enough of each selected note to preserve qualifiers, provenance, status, and authority. When a source/reference note points to an original source, distinguish what the vault states from what would require checking the source again.

Protected canonical domains remain higher-authority according to local governance.

## 4. Synthesize

Answer the user's question directly. Cite or link the vault notes that support material claims using the vault's current link convention.

For `prefrontalsys/vault`, preserve vault-root-relative Markdown links when creating durable notes. In chat, identify the supporting note paths or connector citations as appropriate to the environment.

Do not invent knowledge that is absent from the vault. If the question requires current external verification, retrieve that evidence explicitly rather than silently filling a gap.

## 5. File back only durable knowledge

Do not automatically create a page for every query. File an answer back only when the user requests persistence or when the result is clearly durable and the workflow permits the write.

For `prefrontalsys/vault`, route durable output according to `references/prefrontalsys-vault-profile.md`:

- reusable concept → `knowledge/concepts/<domain>/`
- multi-source research/synthesis → `knowledge/research/<topic>/`
- project-scoped knowledge → `knowledge/projects/`
- navigation → `knowledge/hubs/`
- unresolved intake → `inbox/`

Search for an existing destination before creating a new note. Touch only necessary files. Do not create `wiki/comparisons/`, `wiki/synthesis/`, `index.md`, or `log.md` in a governed vault merely to record a query.

## 6. Preserve authority and contradictions

If the query surfaces a contradiction, report it without silently changing either claim. Any write to a protected canonical domain must follow local review controls.

## Standalone compatibility

For standalone llm-wiki vaults, `wiki/index.md`, wikilink citations, `wiki_search.py`, comparison/synthesis pages, and `wiki/log.md` remain supported. Those conventions are not universal requirements for governed vaults.
