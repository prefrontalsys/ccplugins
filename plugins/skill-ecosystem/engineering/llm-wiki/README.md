# llm-wiki

> Persistent, compounding knowledge for Obsidian and agent workflows.

Inspired by [Andrej Karpathy's LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f), this plugin turns an agent into a disciplined knowledge-base maintainer. Sources are integrated into durable notes, cross-references, contradictions, and synthesis instead of being rediscovered from scratch on every query.

## Operating modes

llm-wiki supports two modes.

### Governed existing vault

If the target already has a knowledge architecture or governance policy, **the vault's local rules are authoritative**. The skill inspects the current structure, searches for existing notes, and routes new knowledge into the established destinations. It does not create `raw/`, `wiki/`, `index.md`, or `log.md` merely because the standalone templates use them.

For `prefrontalsys/vault`, the maintained secondary-knowledge structure is:

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

The profile is documented in `references/prefrontalsys-vault-profile.md`. It also preserves the vault's protected canonical domains, provenance rules, vault-root-relative Markdown links, and GitHub validation controls.

### Standalone llm-wiki vault

For a newly initialized research vault, the original plugin structure remains supported:

```text
<vault>/
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

## Core operations

**Ingest** reads a URL or file, deduplicates it, creates or updates a source/reference note, integrates only durable knowledge, preserves contradictions and provenance, and touches only necessary files.

**Query** uses the target vault's current navigation and search facilities, reads the smallest relevant evidence set, and synthesizes an answer without inventing missing knowledge. Durable answers can be filed back into the existing structure.

**Lint** uses native repository validation and governance first. Standalone lint and graph scripts remain available for standalone vaults.

## Commands

| Command | Purpose |
|---|---|
| `/wiki-init` | Bootstrap a new standalone llm-wiki vault |
| `/wiki-ingest <source>` | Ingest a file or URL using target-vault governance |
| `/wiki-query <question>` | Query maintained knowledge using current navigation |
| `/wiki-lint` | Run layout-appropriate health checks |
| `/wiki-log` | Show a log only when the target layout defines one |

## Sub-agents

- `wiki-ingestor` integrates one source using the current vault layout.
- `wiki-librarian` answers questions from maintained knowledge.
- `wiki-linter` runs a non-destructive health review.

## Standalone quick start

```bash
python scripts/init_vault.py --path ~/vaults/research --topic "LLM interpretability" --tool all
open -a Obsidian ~/vaults/research
cp ~/Downloads/paper.pdf ~/vaults/research/raw/papers/
cd ~/vaults/research
# then in the agent CLI:
# /wiki-ingest raw/papers/paper.pdf
```

Do not run this initialization workflow inside an existing governed vault.

## Design rules

- Local governance overrides plugin defaults.
- Search before creating a note.
- Use the smallest useful write set. There is no minimum page-touch count.
- Preserve source provenance and conflicting claims.
- Do not copy copyrighted web publications into the vault in full.
- Do not rewrite frontmatter or links merely to normalize them to a generic llm-wiki schema.
- Do not modify protected canonical knowledge as an incidental ingest or lint side effect.

## Cross-tool compatibility

The standalone scripts are Python standard-library tools. Loader files differ by environment (`CLAUDE.md`, `AGENTS.md`, or `.cursorrules`). In governed-vault mode, repository-local instructions remain authoritative regardless of the agent loader.

## Key references

- `SKILL.md` — master behavior and precedence rules
- `references/prefrontalsys-vault-profile.md` — governed profile for `prefrontalsys/vault`
- `references/wiki-schema.md` — governed and standalone layouts
- `references/page-formats.md` — note patterns
- `references/ingest-workflow.md` — ingestion workflow
- `references/query-workflow.md` — query workflow
- `references/lint-workflow.md` — health-check workflow

## Status

**v1.1.0** — adds governed-vault mode and an explicit `prefrontalsys/vault` profile while retaining standalone `raw/` + `wiki/` compatibility.

## License

MIT.
