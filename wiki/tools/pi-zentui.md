---
title: pi-zentui
tags: [tools, pi-extensions, tui, statusline, lifecycle, operations]
sources: []
links:
  - https://github.com/lhl/pi-zentui
  - https://github.com/lhl/pi-zentui/commit/a4d6a362ea6182390657024c548f77babae6af85
  - https://pi.dev/docs/latest/extensions
---

# pi-zentui

`pi-zentui` is this devstack's canonical Pi status-line and editor extension. The `lhl/pi-zentui` fork adds local visual preferences, Codex quota display, and lifecycle fixes on top of `lmilojevicc/pi-zentui`.

## Stale-context shutdown failure

A print-mode smoke could produce the requested model response and then exit nonzero:

```text
OK
Error: This extension ctx is stale after session replacement or reload.
    at refreshProjectState (.../extensions/zentui/index.ts:336:33)
    at scheduleProjectRefresh (.../extensions/zentui/index.ts:350:10)
```

The model/provider request was successful. The failure happened afterward during extension shutdown.

### Root cause

1. `session_start` began an asynchronous git/runtime project refresh and captured the live Pi `ExtensionContext`.
2. `message_end` and `agent_end` requested more refreshes while the first refresh was in flight, setting a pending flag.
3. Print mode completed and Pi emitted `session_shutdown`, disposed the session, and invalidated the old extension context.
4. The first refresh's `finally` callback recursively started the pending refresh with the captured old `ctx`.
5. Reading `ctx.cwd` triggered Pi's stale-context guard. Because the fire-and-forget promise chain had no rejection handler, Node treated it as an unhandled rejection and exited with status 1.

Two adjacent lifecycle problems made the race easier to trigger:

- the extension installed footer/editor/widget component factories in print, JSON, and RPC modes even though they are terminal UI (TUI)-only;
- the extension had no `session_shutdown` handler to stop queued refresh work and clear callbacks.

Pi's stale-context error was the intended safety mechanism, not the defect. Session-bound objects must not escape their active extension runtime.

## Fix in `a4d6a36`

Commit [`a4d6a36`](https://github.com/lhl/pi-zentui/commit/a4d6a362ea6182390657024c548f77babae6af85) made the refresh path lifecycle-safe:

- guard UI installation with `ctx.hasUI` plus `ctx.mode === "tui"` when the newer mode property exists;
- skip later UI event work when no TUI was installed;
- copy `ctx.cwd` to a plain string before asynchronous work rather than retaining `ExtensionContext`;
- move refresh coalescing into `project-refresh.ts`, keeping only the latest pending working directory;
- add idempotent `session_shutdown` cleanup that stops pending recursion and drops render/widget callbacks;
- consume project-refresh failures so a fire-and-forget status probe cannot become an unhandled process-level rejection.

The mode check intentionally supports both the fork's older `@mariozechner/pi-coding-agent@0.65.2` development types (which lack `ctx.mode`) and current `@earendil-works/pi-coding-agent` runtimes.

## Verification

The regression was reproduced with only the Zentui extension enabled:

```bash
pi --no-extensions --no-skills --no-prompt-templates \
  --no-context-files --no-session \
  -e ~/.pi/agent/git/github.com/lhl/pi-zentui/extensions/zentui/index.ts \
  --provider zai --model glm-5.3 --thinking low \
  -p 'Reply with exactly OK.'
```

Before the fix, the command printed `OK`, threw the stale-context error, and exited 1. After the fix it printed `OK` and exited 0.

Mechanical verification on 2026-08-14:

- red test: five lifecycle assertions failed and the not-yet-created scheduler test could not load;
- focused green test: seven lifecycle/scheduler tests passed;
- full project verification: lint, typecheck, and 17 tests passed;
- package dry run passed;
- a full installed-extension Pi smoke returned `OK`, exited 0, and showed neither the stale-context nor Camoufox launch errors.

## Operational notes

- The canonical package source remains `https://github.com/lhl/pi-zentui`; no manifest source switch is required.
- Run `/reload` in an existing Pi session after updating the package.
- The Pi-managed clone can contain package-manager-only `package-lock.json` formatting changes. Keep those out of behavioral commits unless intentionally refreshing the lockfile.

## Permanent follow-ups

- Update the fork's Pi development dependencies/imports from legacy `@mariozechner/*` 0.65 types to current `@earendil-works/*`, then simplify the compatibility mode check to `ctx.mode === "tui"`.
- Thread an `AbortSignal` through `readGitStatus()` and runtime-version probes so `session_shutdown` can terminate in-flight subprocesses, not only suppress their callbacks and pending reruns.
- Replace silent refresh-error consumption with a rate-limited diagnostic that cannot crash Pi or spam the terminal.
- Add an interactive replacement test covering `/reload`, `/new`, and `/resume`; print/JSON/RPC guarding and scheduler shutdown are unit-tested, but the live TUI replacement path is only covered by lifecycle design and smoke tests.
- Upstream the generic lifecycle corrections to `lmilojevicc/pi-zentui` if that project remains maintained.

## General extension rule

For Pi extension background work, copy plain durable values (paths, ids, serialized config) while the handler context is active. Do not retain `ctx`, `ctx.sessionManager`, `pi`, or UI component callbacks across `session_shutdown`, session replacement, or reload. Start session-scoped work from `session_start` and make `session_shutdown` cleanup idempotent.

## Related

- [[tools/pi-agent]] — canonical package list and the broader Zentui customization history
- [[tools/pi-statusline]] — status-line alternatives and design comparisons
