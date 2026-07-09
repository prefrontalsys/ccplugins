# deep-insights

Retro analysis of Claude Code sessions over an arbitrary date range — a chunked companion to the built-in `/insights`, which caps out at 200 newly-parsed sessions per run (roughly a week of history for a heavy user).

## What it does

Given `--start` (and optionally `--end`), it:

1. Filters your `~/.claude/projects/**/*.jsonl` session logs to the window.
2. Ranks them by discussion density using the bundled `scripts/session-scanner`.
3. Extracts structured facets (goals, satisfaction, friction, tools) from the top N sessions via parallel `worker` agents.
4. Aggregates and analyzes across 6 dimensions (project areas, interaction style, what's working, friction, horizon opportunities, memorable moment) via the bundled prompt pack in `prompts/`.
5. Renders a single markdown report in `/insights`-style structure.

## Install

This plugin also needs the `agents` plugin from this same marketplace (it dispatches `worker` and `thinker`):

```
/plugin install deep-insights@ccplugins
/plugin install agents@ccplugins
```

## Usage

```
/deep-insights --start 2026-01-01 --end 2026-03-31
```

See `SKILL.md` for the full argument list and pipeline detail.

## Provenance

The bundled prompt pack (`prompts/*.txt`) was reverse-engineered from Claude Code's own built-in `/insights` command (each file carries a `# source: insights.ts line N` comment). `scripts/session-scanner` is a standalone stdlib-only Python script for ranking/extracting session transcripts — no external dependencies.
