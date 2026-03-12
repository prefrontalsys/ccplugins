# prose-style

Prose-first output style for Claude Code. Optimized for longform writing, intellectual engagement, and argument development.

## What it does

- Sets paragraph prose as the default output format (not lists or structured code output)
- Activates always-on interlocutor mode: flags logical gaps, unsupported claims, and internal contradictions
- Encodes voice mechanics: Ars Technica directness + Aeon depth, with the user's published writing as voice anchors
- Includes essay structure guidance: thesis-first openings, one-idea paragraphs, steel-manned counterarguments, reframe closings
- Suppresses AI writing tells: no sycophantic openers, hedge phrases, filler, or epistemic cowardice

## What it doesn't do

- No tool routing or memory management (handled by CLAUDE.md)
- No vault-specific topics or infrastructure details
- No coding behavior — use the default style or `engineer` agent for code tasks

## Install

```
/plugins install prose-style@ccplugins
```

## Complementary agents

- `writer` — dispatch target for prose generation tasks (non-interactive)
- `editor` — dispatch target for editing/polishing existing prose
- `engineer` — dispatch target for code/config tasks from a prose session
