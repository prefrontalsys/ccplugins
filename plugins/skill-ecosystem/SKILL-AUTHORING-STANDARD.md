# Plugin & Skill Authoring Standard

**Normative source:** https://code.claude.com/docs/en/plugins-reference.md
**Last verified against cc-docs:** 2026-04-16

This standard describes how plugins in this repository are structured. It is grounded in the Claude Code plugin specification, not in conventions invented by prior contributors. Where this document disagrees with cc-docs, cc-docs wins — please update this file.

---

## 1. Core principle: one skill, one plugin

Every skill in this repository is a standalone plugin with its own `.claude-plugin/plugin.json` manifest. There are **no bundle plugins** — a plugin never groups unrelated sub-skills under a shared namespace, because CC has no mechanism for plugins to share a command namespace.

A plugin's namespace for commands, agents, and skill invocation is exactly its `plugin.json` `name` field. That name is also the `plugin-name:*` prefix users see.

---

## 2. File layout

```
plugin-root/
├── .claude-plugin/
│   └── plugin.json            # required manifest (see §3)
├── SKILL.md                   # the skill itself (see §4)
├── agents/                    # optional: sub-agents (see §5)
│   └── <agent-name>.md
├── commands/                  # optional: slash commands (see §6)
│   └── <command-name>.md
├── scripts/                   # optional: Python/shell helpers called by the skill
├── references/                # optional: prompt templates, domain docs
└── README.md                  # optional but recommended
```

CC auto-discovers `SKILL.md` at the plugin root, `agents/*.md`, and `commands/*.md`. You do not need to set `skills`, `agents`, or `commands` fields in `plugin.json` unless you relocate those directories.

---

## 3. `plugin.json`

Per cc-docs, **only `name` is required**. Everything else is optional metadata.

### Minimum valid manifest

```json
{
  "name": "my-plugin"
}
```

### Recommended manifest (what every plugin in this repo uses)

```json
{
  "name": "my-plugin",
  "description": "One-sentence statement of what this plugin does and when to use it.",
  "version": "1.0.0",
  "license": "MIT"
}
```

### Full schema

| Field         | Type                  | Required | Notes                                                                              |
|:--------------|:----------------------|:---------|:-----------------------------------------------------------------------------------|
| `name`        | string                | yes      | kebab-case, no spaces. Becomes the command namespace prefix.                       |
| `version`     | string                | no       | SemVer. Authoritative if also set in marketplace entry.                            |
| `description` | string                | no       | Discovery hint. Keep it short; SKILL.md description is what CC uses at runtime.    |
| `author`      | object                | no       | `{name, email?, url?}`                                                             |
| `homepage`    | string                | no       | Docs URL.                                                                          |
| `repository`  | string                | no       | Source URL.                                                                        |
| `license`     | string                | no       | SPDX identifier.                                                                   |
| `keywords`    | array of strings      | no       | Discovery tags.                                                                    |
| `skills`      | string \| array       | no       | Override default `SKILL.md`/`skills/` discovery. Rarely needed.                    |
| `commands`    | string \| array       | no       | Override default `commands/` discovery.                                            |
| `agents`      | string \| array       | no       | Override default `agents/` discovery.                                              |
| `hooks`       | string \| array \| object | no   | Hook config path, or inline.                                                       |
| `mcpServers`  | string                | no       | Path to `.mcp.json`, or inline.                                                    |
| `outputStyles`| string                | no       | Path to styles dir.                                                                |
| `lspServers`  | string                | no       | Path to `.lsp.json`.                                                               |

### The `skills` field

The spec default (when the field is omitted) is the `skills/` subdirectory at the plugin root. The spec also allows overriding that default with a relative path or an array of paths.

**Known loader pitfall**: `"skills": "./"` (string form pointing at plugin root) is rejected by the current CC loader as a path escape, even though the spec documents that `"skills": ["./"]` (array form pointing at plugin root) is a valid pattern for plugins whose root directory contains `SKILL.md` directly. This is a loader/spec inconsistency — use the array form OR one of the patterns below.

Three valid layouts:

**Layout A — single SKILL.md at plugin root, no `skills/` subdir**
- Either omit the `skills` field (CC will auto-discover the root `SKILL.md`), or
- Set `"skills": ["./"]` (explicit array form — documented in spec, accepted by loader)

**Layout B — sub-skills directory**
```
plugin/
├── .claude-plugin/plugin.json
└── skills/
    ├── variant-a/SKILL.md
    └── variant-b/SKILL.md
```
Either omit `skills` (default scan of `skills/`) or set `"skills": "./skills/"` explicitly.

**Layout C — explicit multi-location array**
```json
"skills": ["./skills/", "./extras/"]
```
Use when skills live in multiple directories. Per spec: *"To keep the default directory and add more paths for skills, commands, agents, or output styles, include the default in your array."*

**Repo convention**: Layout A (omit the field) is the common case; Layout B (`"./skills/"`) is used when a plugin has multiple variant skills. Neither string `"./"` nor array `["./"]` should be used in new plugins — they're ambiguous between "default location" and "root override" to readers.

---

## 4. `SKILL.md`

Per cc-docs, **only `description` is recommended** in frontmatter; nothing is strictly required (name defaults to directory name).

### Minimum valid SKILL.md

```markdown
---
description: What this skill does and when to invoke it.
---

# Skill Name

Instructions for the model go here.
```

### Recommended frontmatter

```markdown
---
name: skill-name
description: What this skill does. Front-load the key trigger phrases — CC truncates at 1,536 characters combined with when_to_use in the skill listing.
when_to_use: Additional trigger phrases and example invocations. (optional)
allowed-tools: Read Grep Bash  (optional — restricts which tools the skill may use)
---
```

### Valid frontmatter fields

| Field                      | Required    | Notes                                                                                                                |
|:---------------------------|:------------|:---------------------------------------------------------------------------------------------------------------------|
| `name`                     | no          | lowercase, digits, hyphens. Max 64 chars. Defaults to directory name.                                                |
| `description`              | recommended | Truncated at 1,536 chars combined with `when_to_use`. Put the load-bearing phrase first.                             |
| `when_to_use`              | no          | Extra triggers. Shown in listing alongside description.                                                              |
| `argument-hint`            | no          | Autocomplete hint (e.g. `[issue-number]`).                                                                           |
| `disable-model-invocation` | no          | If `true`, model cannot auto-invoke; only explicit `/skill-name`.                                                    |
| `user-invocable`           | no          | Set to `false` to hide from the `/` menu. Use for background knowledge users shouldn't invoke directly. Default: `true`. |
| `allowed-tools`            | no          | Tools Claude can use without asking permission while this skill is active. Accepts a space-separated string OR a YAML list. Does not restrict which tools are available; tools not listed still obey your permission settings. |
| `model`                    | no          | Model to use while this skill is active.                                                                             |
| `effort`                   | no          | Effort level while this skill is active. Overrides session effort. Options: `low`, `medium`, `high`, `max` (Opus 4.6 only). |
| `context`                  | no          | Set to `fork` to run in a forked subagent context.                                                                   |

### Fields this repo does NOT use (not spec)

- `license` — belongs in `plugin.json`, not `SKILL.md`
- `metadata` block with `version`/`author`/etc. — not a spec field
- Multiline block scalar (`description: |`) — spec expects a one-line string

---

## 5. Agents (`agents/<name>.md`)

Per cc-docs, agents **require `name` and `description`** in frontmatter.

### Minimum valid agent file

```markdown
---
name: my-agent
description: When Claude should delegate to this subagent.
---

You are a <role>. Your job is to <task>. ...
```

### Recommended agent frontmatter

```markdown
---
name: my-agent
description: Concrete delegation trigger, e.g. "Spawn when the user asks to review a PR or says 'audit this diff'."
tools: Read, Bash, Grep, Glob
model: sonnet
---
```

### Valid fields

| Field             | Required | Notes                                                                                                                  |
|:------------------|:---------|:-----------------------------------------------------------------------------------------------------------------------|
| `name`            | yes      | kebab-case unique identifier.                                                                                          |
| `description`     | yes      | When CC should delegate to this agent.                                                                                 |
| `tools`           | no       | Comma-separated allow-list; inherits all if omitted.                                                                   |
| `disallowedTools` | no       | Tools to deny from inherited set.                                                                                      |
| `model`           | no       | `sonnet`, `opus`, `haiku`, specific model ID, or `inherit`. Defaults to `inherit`.                                     |
| `permissionMode`  | no       | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan`.                                           |
| `maxTurns`        | no       | Maximum agentic turns before the subagent stops.                                                                       |
| `skills`          | no       | Skills to load into the subagent's context at startup. Full content is injected, not just made invocable.              |
| `mcpServers`      | no       | MCP servers available to this subagent. Each entry is either a named reference or an inline server config.             |
| `hooks`           | no       | Lifecycle hooks scoped to this subagent.                                                                               |
| `memory`          | no       | Persistent memory scope: `user`, `project`, or `local`. Enables cross-session learning.                                |
| `background`      | no       | `true` to always run as a background task. Default: `false`.                                                           |
| `effort`          | no       | Effort level: `low`, `medium`, `high`, `max` (Opus 4.6 only). Overrides session effort.                                |
| `isolation`       | no       | Set to `worktree` to run in a temporary git worktree. Auto-cleans up if the subagent makes no changes.                 |
| `color`           | no       | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan`.                                   |
| `initialPrompt`   | no       | Auto-submitted as the first user turn when this agent runs as the main session agent (via `--agent`).                  |

### Model selection — heuristic used in this repo

| Agent role                                                 | Model        |
|:-----------------------------------------------------------|:-------------|
| Deep reasoning, architecture, adversarial analysis         | `opus`       |
| Planning, orchestration, strategy                          | `opus`       |
| Code review, test design, writing, editing                 | `sonnet`     |
| Routine tool orchestration, search, synthesis              | `sonnet`     |
| Debugging (declarative, with evidence)                     | `sonnet`     |
| Mechanical transforms, formatting, simple lookups          | `haiku`      |

Pick the cheapest tier that reliably does the job. Spec allows `inherit` as a fallback when the parent session's model is appropriate.

### Fields this repo does NOT use (not spec)

- `role` — free-text role descriptions belong in the body, not frontmatter
- `constraints` — same; put in the body

---

## 6. Commands (`commands/<name>.md`)

Per cc-docs, commands are discovered in a plugin's `commands/` directory. Each command file is invoked as `/<plugin-name>:<command-name>`.

### Minimum valid command file

```markdown
---
description: What this command does.
---

Instructions for Claude when this command is invoked. Use $ARGUMENTS to
reference the user's arguments.
```

### Valid fields

| Field                      | Required | Notes                                                   |
|:---------------------------|:---------|:--------------------------------------------------------|
| `name`                     | no       | Defaults to filename. Kebab-case.                       |
| `description`              | yes      | Shown in autocomplete.                                  |
| `argument-hint`            | no       | e.g. `[issue-number]` or `[file] [format]`.             |
| `disable-model-invocation` | no       | `true` = slash only, model cannot auto-invoke.          |
| `allowed-tools`            | no       | Restrict tools for this command.                        |

### Documentation rule

Never document a command in `SKILL.md` or `README.md` without a corresponding `commands/<name>.md` file. CC has no way to satisfy a documented `/plugin:cmd` invocation if the file does not exist — users will type the command and see no effect.

If you list example commands in prose, use the real namespace: `/<your-plugin-name>:<command-name>`. Do not use short prefixes that do not match the plugin's `name`.

---

## 7. Marketplace registration

A plugin only appears in `/plugin install` if registered in `.claude-plugin/marketplace.json` at repo root:

```json
{
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./plugins/skill-ecosystem/domain/my-plugin",
      "description": "One-line summary for the marketplace listing.",
      "license": "MIT"
    }
  ]
}
```

The marketplace `name` can differ from the `plugin.json` `name`. Users install by marketplace name; commands use the plugin.json name. This split is intentional — it lets install identifiers be user-friendly (`my-plugin@ccplugins`) while command namespaces stay short (`/mp:*`).

---

## 8. Testing before commit

Before committing any new or changed plugin:

1. **Valid JSON.** `python3 -m json.tool < .claude-plugin/plugin.json`
2. **Frontmatter parses.** `python3 -c "import yaml,pathlib; yaml.safe_load(pathlib.Path('SKILL.md').read_text().split('---',2)[1])"`
3. **Install locally.** `/plugin install <name>@<marketplace>` in a CC session, then `/reload-plugins`. Verify the plugin appears in `/plugin` and its commands register under the expected namespace.
4. **Agent delegation works.** If the plugin defines agents, trigger one and confirm the described model and tools are active.

A plugin that passes JSON validation but fails step 3 is still broken. Always install-test.

---

## 9. What changed from the prior standard (2026-04-16 rewrite, r2)

### r2 — after adversarial review

A Gemini adversarial review flagged three real misses in the initial rewrite:

- **`user-invocable` field** missing from the SKILL.md frontmatter table (§4). Added.
- **Agent frontmatter table** (§5) was incomplete. The spec documents 15+ valid fields; the initial rewrite listed 5. Added all remaining fields (`permissionMode`, `maxTurns`, `skills`, `mcpServers`, `hooks`, `memory`, `background`, `effort`, `isolation`, `color`, `initialPrompt`).
- **Skills-path guidance** (§3) claimed root SKILL.md was the canonical layout. Corrected to reflect that the spec default is `skills/` and that both layouts are valid; root-SKILL.md plugins should either omit the field or use the array form `["./"]` per spec.

### r1 — initial rewrite

The previous SKILL-AUTHORING-STANDARD.md was invented by upstream contributors without reference to cc-docs. It treated several fields as required that the spec does not require, and documented patterns (bundle plugins sharing a namespace via `/short:command` references) that are not possible in Claude Code.

Removed as non-spec:

- Required `license` field in SKILL.md frontmatter
- Required `metadata.version` sub-block in SKILL.md frontmatter
- Required `role` and `constraints` fields in agent frontmatter
- Bundle-plugin pattern (`skills: "./"` with domain-level plugin.json)
- Shared short-prefix namespaces (`/cs:*`, `/ci:*` across multiple plugins)

Added as spec:

- Explicit note that `plugin.json` manifest is optional; default discovery handles root-level `SKILL.md`, `agents/`, `commands/`
- `model` field in agent frontmatter (with selection heuristic)
- Explicit namespace rule: one plugin = one `plugin.json` = one command prefix
- Marketplace-name vs. plugin-name distinction
- Install-test step (§8.3) as a blocking check before commit
