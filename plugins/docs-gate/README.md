# docs-gate

A `PreToolUse` hook plugin that deterministically blocks further debugging
attempts (edits, test/build/run commands) once you've made `threshold` of
them in a row with no documentation lookup in between.

It exists because soft `CLAUDE.md` instructions like "verify against docs
instead of guessing" get silently ignored once the context window fills up.
This gate enforces that mechanically — pure counting and pattern matching,
like a rate limiter. **There is no LLM judgment anywhere in this script.**

## How it works

1. Every tool call passes through `docs-gate.sh` (registered with matcher
   `*` on `PreToolUse`).
2. The call is classified as exactly one of:
   - **risky** — `Edit`, `MultiEdit`, `Write`, or a `Bash` command matching
     a configured test/build/run/debug pattern.
   - **grounding** — `WebFetch`, `WebSearch`, any tool whose name contains
     `context7` or `deepwiki` (matches both the generic `mcp__context7__*`
     naming and connector-scoped names like `mcp__claude_ai_Context7__*`),
     or a `Bash` command hitting `gh issue`, `gh pr view`, `gh api`, or a
     docs/GitHub-API URL via `curl`.
   - **neutral** — everything else (`Read`, `Grep`, `Glob`, ...). No effect.
3. A per-session counter (keyed by `session_id`, hashed to a filesystem-safe
   name) increments on every risky call and resets to 0 on every grounding
   call.
4. When a risky call arrives with the counter already at or above
   `threshold` (default 3), the call is **hard-blocked** (`exit 2`) with a
   message telling Claude exactly what to do next. Below threshold, it's
   allowed and the counter increments.

Grounding calls are never blocked — the gate only ever blocks risky calls.

## Install

```
/plugin install docs-gate@ccplugins
/reload-plugins
```

No further setup needed — the hook registers itself (`PreToolUse`, matcher
`*`) and runs with built-in defaults. State lives in the plugin's own
persistent data directory (`${CLAUDE_PLUGIN_DATA}`), so it survives plugin
updates and is cleaned up on full uninstall.

To tune thresholds or patterns, copy `config.example.json` (bundled in the
plugin) to `${CLAUDE_PLUGIN_DATA}/state/config.json` and edit it — see
Configuration below.

## Configuration

`${CLAUDE_PLUGIN_DATA}/state/config.json`, all keys optional — anything you
omit falls back to the built-in default:

| Key                       | Meaning                                                      |
| -------------------------- | ------------------------------------------------------------ |
| `threshold`                | Consecutive risky calls allowed before a block (default `3`). |
| `risky_tools`               | Exact tool names always counted as risky.                    |
| `risky_bash_patterns`       | `grep -iE` patterns tested against `Bash` commands.           |
| `grounding_tool_patterns`   | `grep -iE` patterns tested against the tool name.             |
| `grounding_bash_patterns`   | `grep -iE` patterns tested against `Bash` commands.           |

See `config.example.json` for the full default set.

## Kill switch

```bash
touch "${CLAUDE_PLUGIN_DATA}/state/OFF"
```

While that file exists, the hook exits `0` (allow) immediately, before any
classification or counting. Delete the file to re-arm.

## Fail-open guarantee

Any internal error — `jq` missing, state directory unwritable, corrupt
state JSON, malformed stdin — makes the hook exit `0` (allow). The gate is
only ever supposed to slow down an unverified debugging loop, never to wedge
a session. See `tests/docs-gate.test.sh` for the cases this is verified
against.

## Limitations (honest)

- **This checks for the mechanical absence of a grounding call, not the
  semantic quality of one.** Calling `WebFetch` on an unrelated page, or
  running `gh issue view` on the wrong repo, resets the counter exactly the
  same as a genuinely relevant docs lookup would. Judging relevance would
  require the kind of LLM judgment this gate deliberately avoids — that's a
  disclosed limitation, not a bug.
- **Pattern matching is coarse by design.** `risky_bash_patterns` includes
  a bare `error` (anchored to word position, not just an unbounded
  substring), which will still flag a command like
  `git commit -m "fix error handling"`. Tune `config.json` for your
  project if the defaults over- or under-trigger. The patterns require
  start/whitespace/shell-operator boundaries specifically so a file path
  like `docs-gate.test.sh` doesn't trip `test` — that was a real false
  positive hit during this project's own development (see
  `dg_classify`'s boundary regex and the Test 1d regression test).
- **The counter is per-session, not per-bug or per-file.** Three edits
  across three unrelated files count the same as three edits chasing one
  bug. It's a blunt rate limiter, not a debugging-loop detector.
- **`if` a Bash command matches both a risky and a grounding pattern**
  (e.g. `gh issue view 1 && pytest`), grounding wins and the counter
  resets. This is a deliberate precedence choice, not a discovered
  ordering guarantee — documented in `docs-gate-lib.sh`'s `dg_classify`.
- **No cross-session or cross-restart memory beyond the state file.** If
  you delete the plugin's `${CLAUDE_PLUGIN_DATA}/state/sessions/`
  directory, every session's counter resets to 0.
- **Regex-based `gh`/`curl` grounding detection is easy to spoof** (e.g. a
  command that merely contains the substring `gh api` in a comment). This
  gate is meant to keep an honest agent honest under context pressure, not
  to resist adversarial evasion.
- **The counter has a read-modify-write race under concurrent tool calls.**
  `dg_read_counter` and `dg_write_counter` are separate `jq` invocations;
  the tmp-file-then-`mv` write is non-corrupting but not atomic across the
  read. Parallel tool calls in one turn (e.g. under a high
  `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY`) can both read counter N and both
  write N+1, silently losing an increment. This biases toward *allowing*
  an extra risky call or two, which is the safe direction for a fail-open
  rate limiter — `flock` would close it but is excluded by the "no other
  dependencies" constraint.

## Requirements

`jq`, `shasum` or `sha256sum`, and bash 3.2+ (the stock `/bin/bash` on
macOS). No other dependencies — this is a single self-contained script
pair, not a framework.

## Files

```
hooks/hooks.json                    # PreToolUse registration (matcher "*")
hooks-handlers/docs-gate.sh         # the hook entry point
hooks-handlers/lib/docs-gate-lib.sh # shared classification + state logic
config.example.json                 # copy to config.json and tune
tests/docs-gate.test.sh             # self-contained test suite (bash + jq only)
```
