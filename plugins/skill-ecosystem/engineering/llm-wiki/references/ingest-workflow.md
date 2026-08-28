# Ingest Workflow

Use this flow when the user runs `/wiki-ingest <source>` or asks to ingest a source into a maintained vault.

## 1. Resolve the target layout

Before writing, inspect the target vault's governance and structure.

For `prefrontalsys/vault`, read:

- `_meta/knowledge-governance.md`
- `knowledge/knowledge.md`
- `references/prefrontalsys-vault-profile.md` from this skill
- the relevant hub and adjacent notes for the subject area

If the vault already has a governed layout, do not initialize or create `raw/`, `wiki/`, `index.md`, or `log.md`.

Use the standalone workflow only when the vault already follows the plugin's `raw/` + `wiki/` layout or the user is explicitly initializing a new standalone llm-wiki vault.

## 2. Read the source

Accept a public URL, a file already present in the vault, or a user-supplied file available to the current tool environment.

For a public URL, the URL can remain the source of record. Do not require the user to copy it into the vault first. For copyrighted publications, do not reproduce the full source. Extract only the information needed for a durable reference note and downstream knowledge.

For PDFs and images, use the tool appropriate to the environment. Preserve source provenance and page or section pointers where useful.

## 3. Search before creating

Search the vault for:

- the exact source URL;
- the source title and obvious title variants;
- major concepts, entities, or projects discussed by the source;
- existing research or hub notes that already cover the topic.

If a source/reference note already exists, use merge/update mode rather than creating a duplicate.

## 4. Determine the smallest useful write set

For `prefrontalsys/vault`, route content as follows:

- source/report/article/paper reference → `knowledge/references/`
- reusable concept/framework/method → existing or new `knowledge/concepts/<domain>/`
- multi-source research or evolving thesis → `knowledge/research/<topic>/`
- project-specific durable knowledge → `knowledge/projects/`
- navigation → `knowledge/hubs/`
- unresolved intake → `inbox/`

A normal web-source ingest usually creates one reference note and may update one or more existing concept or research notes. There is no minimum number of files to touch.

Do not create entity pages merely because a person, organization, or product is mentioned. Create durable notes only when the entity itself is useful knowledge in the target vault.

## 5. Apply authorization rules

If the user explicitly asked to ingest, add, or save the source, that request authorizes normal non-destructive writes needed for ingestion. Do not ask for a second confirmation.

Stop and require explicit review only when the proposed write would:

- modify `retirement_planning_hub/**`, `career-work_knowledge_base/**`, or `personal_health_record/**` in `prefrontalsys/vault`;
- delete, move, rename, or replace existing content;
- overwrite a higher-authority claim;
- resolve a material contradiction by choosing one side without adequate evidence.

## 6. Write or update the source/reference note

For `prefrontalsys/vault`, write under `knowledge/references/` and follow the frontmatter of adjacent reference files. Preserve at least enough provenance to recover the original source. Use a concise, copyright-safe summary.

A useful source/reference note usually contains:

- what the source is and who produced it;
- why it matters to the vault;
- key claims or findings;
- methodology, sample, or evidence quality when relevant;
- caveats and limits;
- links to durable concepts, projects, research, or hubs;
- the original source URL or file provenance.

Do not create a raw copy of a public article or report merely for llm-wiki bookkeeping.

## 7. Integrate durable knowledge

For each genuinely reusable claim or concept:

1. Find the existing concept, research, or project note.
2. Add only the new evidence or distinction supplied by the source.
3. Preserve the existing note's terminology, status/lifecycle, and frontmatter conventions.
4. Add a root-relative Markdown link back to the source/reference note when appropriate.
5. Update navigation only if the new knowledge would otherwise be difficult to discover.

If no suitable concept exists, create one only when the concept is durable enough to deserve its own page. New substantive concept notes in `prefrontalsys/vault` must include a non-empty `type` field.

## 8. Handle contradictions explicitly

If the source conflicts with existing knowledge, preserve both positions and their provenance. Record the conflict in the smallest relevant note. Do not silently replace the older claim.

Protected or higher-authority claims require the review process defined by local governance before changing them.

## 9. Validate

Before reporting completion:

- verify there is no duplicate source note;
- verify local Markdown links resolve using the vault's convention;
- verify protected canonical paths were not touched unless explicitly authorized;
- verify new substantive concept notes meet CI frontmatter requirements;
- verify only necessary files changed;
- verify no obsolete `raw/` or `wiki/` hierarchy was introduced into a governed vault.

For a standalone llm-wiki vault, the bundled index, log, lint, and graph scripts may be used as originally designed. Do not assume those scripts are compatible with a governed vault.

## 10. Report completion

Report the source/reference note created or updated, any durable notes changed, any contradictions preserved, and any material limitation in the source. Do not propose arbitrary extra pages or source hunts unless they are necessary to complete the user's stated goal.
