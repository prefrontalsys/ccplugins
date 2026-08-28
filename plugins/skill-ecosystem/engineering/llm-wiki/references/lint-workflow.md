# Lint Workflow

Use this workflow for non-destructive knowledge-base health checks. The target vault's own validation and governance controls take precedence over the bundled standalone llm-wiki scripts.

## 1. Resolve the target layout

For `prefrontalsys/vault`, read `_meta/knowledge-governance.md` before running or proposing changes. Repository CI and the weekly health workflow already define important structural checks and review boundaries.

Do not assume the vault has `wiki/index.md`, `wiki/log.md`, `category` frontmatter on every note, or Obsidian wikilinks.

For a standalone llm-wiki vault that already uses `raw/` + `wiki/`, the bundled lint and graph scripts remain appropriate.

## 2. Mechanical checks

For a governed vault, prefer the repository's native validation. Check the concerns that local policy defines, including:

- parseable YAML frontmatter where frontmatter is expected;
- required `type` on new substantive concept notes;
- broken local Markdown links;
- duplicate or conflicting durable notes;
- high-confidence secret patterns and sensitive-data warnings;
- protected-domain changes that lack the required review controls;
- draft and inbox queues where local maintenance tracks them.

Do not automatically rewrite notes to make them conform to a generic llm-wiki schema.

## 3. Semantic checks

Review targeted knowledge for:

### Contradictions

When two notes or sources materially disagree, preserve both claims and provenance. Report the conflict. Do not choose a side or rewrite higher-authority content without sufficient evidence and the required approval.

### Stale claims

Distinguish a genuinely time-sensitive claim from an older but still valid conceptual note. Suggest verification when freshness matters. Do not change a claim solely because its `updated` date is old.

### Duplicate concepts

Identify near-duplicate concepts, references, or research notes before creating new ones. Recommend merge or consolidation only when authority and provenance can be preserved.

### Link gaps

Use the vault's actual link convention. In `prefrontalsys/vault`, validate vault-root-relative Markdown links. Do not convert files to wikilinks as a lint side effect.

### Navigation gaps

Check whether durable notes are reachable from an appropriate hub when navigation would materially benefit. Do not add every note to every hub.

### Provenance gaps

Flag durable claims whose source cannot be recovered or whose extracted versus inferred status is materially unclear.

## 4. Protected domains

For `prefrontalsys/vault`, do not automatically modify:

- `retirement_planning_hub/**`
- `career-work_knowledge_base/**`
- `personal_health_record/**`

Follow the approval controls in `_meta/knowledge-governance.md` for any legitimate protected-domain change.

## 5. Report

Return a compact review queue containing the issue, affected path, severity or consequence, and the smallest recommended action. Separate findings from changes actually applied.

A lint run is non-destructive by default. Apply repairs only when authorized and when local governance permits them.

## Standalone compatibility

For standalone llm-wiki vaults, the original helpers remain supported:

```text
python scripts/lint_wiki.py --vault .
python scripts/graph_analyzer.py --vault .
```

Those scripts may check standalone-specific concepts such as `wiki/index.md`, `wiki/log.md`, wikilinks, `category` frontmatter, and graph components. Do not run them against a governed vault until compatibility has been verified.
