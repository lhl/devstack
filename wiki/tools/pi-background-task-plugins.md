---
title: Pi Background Task Plugins
tags: [tools, pi, background-tasks, extension-evaluation]
sources:
  - sources/conversations/pi-background-task-plugins-2026-06-14.md
  - sources/conversations/pi-background-task-plugin-smoke-test-2026-06-14.md
  - sources/conversations/pi-background-task-plugin-fullstack-test-2026-06-14.md
links:
  - https://www.npmjs.com/package/@vanillagreen/pi-background-tasks
  - https://github.com/vanillagreencom/vstack/tree/main/pi-extensions/pi-background-tasks
  - https://www.npmjs.com/package/@richardgill/pi-tmux-bash
  - https://github.com/richardgill/pi-extensions/tree/main/extensions/tmux-bash
  - https://www.npmjs.com/package/@trevonistrevon/pi-loop
  - https://github.com/trvon/pi-loop
  - https://www.npmjs.com/package/pi-background-tasks
  - https://github.com/ismailsaleekh/pi-background-tasks
  - https://www.npmjs.com/package/@ifi/pi-background-tasks
  - https://github.com/ifiokjr/oh-pi/tree/main/packages/background-tasks
  - https://www.npmjs.com/package/@zackify/pi-bg-tasks
  - https://github.com/zackify/pi-bg-tasks
  - https://www.npmjs.com/package/pi-bg-run
  - https://www.npmjs.com/package/@artale/pi-procs
  - https://github.com/artale93/pi-procs
  - https://www.npmjs.com/package/@juanibiapina/pi-gob
  - https://github.com/juanibiapina/pi-gob
  - https://www.npmjs.com/package/pi-bash-bg
  - https://www.npmjs.com/package/pi-monitor
---

# Pi Background Task Plugins

This page tracks the June 2026 evaluation of Pi background-task extensions for the devstack plugin stack. It is specifically about **running long-lived shell/process work without blocking the agent turn** and deciding how task completion or interesting output should re-enter the conversation.

## Current decision

**Default candidate:** `@vanillagreen/pi-background-tasks`, now tested both in isolation and through the devstack canonical extension stack on 2026-06-14. Keep it out of the canonical manifest until we decide the model/tooling policy: the plugin worked with `anthropic/claude-haiku-4-5`, but the current default `epyc/shisa-ai/Qwen3.6-35B-A3B-PARO-packed` showed poor tool-loop behavior after wake injection.

Why:

- It has the richest wake/injection model among the surveyed shell-task plugins.
- It supports both completion wakeups and output-pattern wakeups.
- Its output wake path has transcript-budget controls: per-wake output caps, per-task wake counts, byte budgets, and transition/first-match defaults.
- It auto-backgrounds obvious blocking monitors such as `watch`, `tail -f`, `journalctl -f`, and polling loops before they can freeze a foreground bash turn.
- It has durable missed exit wake replay across Pi reloads/session restarts and PID reuse checks.
- It is MIT-licensed and zero-dependency in the package tarball, so a local fork remains feasible if vstack monorepo coupling becomes a problem.

**Test result:** pass for extension load, slash-command registration, `/bg:run`, completion exit wake event delivery, `/bg:list`, `/bg log`, and `/bg:clear` in an isolated temp Pi harness. Pass in the full devstack stack with Haiku 4.5 for LLM `bg_task` invocation, `notifyOnOutput` / `notifyPattern` output wake, completion exit wake, and LLM `bash` auto-backgrounding of `tail -f`. Still not covered: interactive TUI dashboard behavior, cross-restart durable replay, and long noisy wake streams with `pi-context-prune` over real sessions.

**Alternative candidate:** `@richardgill/pi-tmux-bash` if we want to replace the bash execution substrate instead of adding a parallel `bg_task` tool.

Why not default yet:

- It handles completion follow-up and timeout-to-background ergonomics, but it does not provide pattern-triggered mid-run output wakeups.
- It is still `0.0.x`.
- The npm metadata checked on 2026-06-14 did not include a license field, so fork/adoption needs a license check.

**Do not add for this use case yet:**

- `@trevonistrevon/pi-loop` — useful for cron/event re-wake loops, but devstack already has `pi-multiloop` and `pi-schedule-prompt` for the loop/heartbeat axis.
- `pi-monitor` — interesting passive-stream pattern, but not mature enough and its follow-up delivery semantics may still cause extra turns.
- `@zackify/pi-bg-tasks`, `@artale/pi-procs` — useful human/poll-driven process management, but not enough wake semantics for the main requirement.

## What matters for devstack

The devstack stack already has these adjacent primitives:

- `pi-multiloop` for explicit long-running optimization/research loops.
- `pi-schedule-prompt` for cron/interval/one-shot prompts.
- `lhl/pi-tasks` for structured task tracking and prompt-queued task execution.
- `pi-context-prune` with `pruneOn: "agent-message"`, where frequent short wake turns could hurt batching and prompt-cache locality.

The missing primitive is **non-blocking shell/process execution that can wake the agent when the work is done or when a meaningful line appears**.

The important delivery constraint is common to all candidates: Pi notifications do not interrupt an already-running tool call. A completion or output wake is queued until the current tool-call boundary.

## Feature comparison

| Package | Primary primitive | Wake / injection model | Maturity signal checked 2026-06-14 | Fit |
| --- | --- | --- | --- | --- |
| `@vanillagreen/pi-background-tasks` | Explicit `bg_task` / `/bg` shell tasks plus auto-backgrounded bash monitors | Exit wakes as `followUp` with `triggerTurn`; output-match wakes as `steer` with `triggerTurn`; `notifyPattern`, `notifyMode`, wake budgets, durable missed exit replay | `1.6.1` latest; `1.6.0` installable under local npm age gate; created 2026-05-06; MIT; vstack monorepo; isolated and full-stack smoke tests passed 2026-06-14 with model caveat | **Best default candidate; not canonical yet** |
| `@richardgill/pi-tmux-bash` | Drop-in bash replacement backed by tmux | Completion follow-up; optional polling; foreground timeout can convert to background; no pattern-triggered output wakes | `0.0.12`; modified 2026-06-06; no license field in npm metadata | Good substrate alternative; needs license check |
| `@trevonistrevon/pi-loop` | Cron/event agent re-wake loops plus process monitors | Loop/event wakeups rather than shell task completion as the main primitive | `0.5.5`; modified 2026-06-10 | Mostly redundant with current devstack loop/scheduling stack |
| `pi-background-tasks` (ismailsaleekh) | Named background tasks and background `pi -p` child agents | Completion wakeups; unique child-agent telemetry for context/tokens/tools/model | `0.6.0`; modified 2026-05-31; ISC | Watch if background Pi-agent telemetry becomes a priority |
| `@ifi/pi-background-tasks` | Reactive background shell tasks | Output/exit wakeups, regex-gated dashboard lineage | `0.5.1`; modified 2026-04-28; MIT | Upstream ancestor now outpaced by vanillagreen fork |
| `@zackify/pi-bg-tasks` | tmux background commands | Human-oriented tmux sessions and polling UX; no completion wakeups in prior review | `0.1.3`; modified 2026-05-12; MIT | Not enough wake semantics |
| `pi-bg-run` | Minimal background process runner | Completion-only `triggerTurn` notifications | `1.1.4`; modified 2026-06-07; MIT | Clean minimal option, but narrower than vanillagreen |
| `@artale/pi-procs` | Minimal process manager / `mprocs` handoff | No agent wakeups in prior review; rolling buffer | `1.1.2`; modified 2026-04-21; MIT | Tiniest option; not the default need |
| `pi-monitor` | Passive filtered process output stream | `followUp`, `triggerTurn: false` intended as ambient context, not active injection | `0.1.0`; modified 2026-04-09; MIT | Pattern worth stealing, not infrastructure yet |
| `@juanibiapina/pi-gob` | UI for gob-managed background jobs | Process-manager view/control, not full injection layer | `0.6.0`; modified 2026-05-20; MIT | Historical plan; superseded by direct plugin test |
| `pi-bash-bg` | Minimal `&`/detachment fix | Lets bash backgrounding work; no rich state/wake model | `0.1.1`; modified 2026-04-03; MIT | Too small for devstack default |

## `@vanillagreen/pi-background-tasks` notes

Verified from the 1.6.0 tarball and npm metadata:

- `bg_task` actions: `spawn`, `list`, `log`, `stop`, `clear`.
- `bg_status` inspects/stops tracked tasks.
- Spawn options include:
  - `notifyOnExit`
  - `notifyOnOutput`
  - `notifyPattern`
  - `notifyMode`
  - `dedupeKey`
  - `timeoutSeconds`
  - `title`
- `notifyMode` defaults to `first-match-only` when `notifyPattern` is set and `transition` otherwise.
- Output wakes are budgeted by default:
  - `outputAlertMaxChars`: default 2000 characters per wake.
  - `outputWakeBudgetMaxWakes`: default 20 output wakes per task.
  - `outputWakeBudgetMaxBytes`: default 20000 cumulative inline bytes per task.
- Output wakes are sent as steer messages with `triggerTurn: true`.
- Exit wakes are sent as follow-up messages with `triggerTurn: true`.
- Full logs stay on disk even when inline output is truncated.
- Tasks are stopped on session shutdown, but missed exit notifications can replay on the next session if a task reached a terminal state while Pi was gone.
- Optional resource controls can use Linux `systemd-run --user` or `nice`/`ionice` fallback.

Important caveat: local npm is age-gated with `npm config before` set to 2026-06-07. As of 2026-06-14, `@vanillagreen/pi-background-tasks@1.6.1` exists but is newer than that local policy, so the first test should use `@1.6.0` unless we deliberately bypass the age gate.

## `@richardgill/pi-tmux-bash` notes

The main architectural attraction is that it changes the execution substrate rather than adding a separate tool. If a foreground bash command runs too long, the extension can convert it into a background tmux-backed task instead of killing it. That is ergonomic for agents because the model can use bash normally and still avoid getting stuck.

Tradeoffs:

- No pattern-triggered mid-run output wakeups were identified in the prior review.
- tmux improves inspectability and reattach UX but adds a system dependency and terminal-session semantics.
- The package is active but still early (`0.0.12` at the time of the check).
- License metadata needs verification before any fork or canonical adoption.

## `pi-monitor` pattern

`pi-monitor` is not a good default background-task layer, but its design is worth remembering:

- Treat filtered process output as ambient context instead of active wakeups.
- Coalesce events.
- Truncate each event.
- Stop firehoses automatically.
- Keep stderr out of the transcript and expose it on demand.

If devstack later wants "many low-significance events accumulate into context without each becoming a discrete notification," this pattern could be folded into a vanillagreen fork or `pi-multiloop` rather than maintained as a third background execution extension.

## Test results and checklist before promotion

### Isolated smoke test — 2026-06-14

Used `pi -e npm:@vanillagreen/pi-background-tasks@1.6.0` with temporary `PI_CODING_AGENT_DIR` and `PI_BG_TASK_DIR`; no canonical user/project package settings were modified.

Passed:

- Package load and command registration: `/bg`, `/bg:list`, `/bg:run`, `/bg:stop`, `/bg:clear`.
- `/bg:run bash -lc "printf BG_START; sleep 0.2; echo BG_DONE"` returned successfully.
- Completion generated a custom `vstack-background-tasks:event` message with `eventType: "exit"`.
- `/bg:list`, `/bg log bg-1`, and `/bg:clear` returned successfully.
- Both the log notification and the task log file contained `BG_DONE`.

Observed harness caveat: the exit wake triggered an LLM turn, but the turn failed with `Validation error: The provided model identifier is invalid` because the temporary smoke-test Pi config used an invalid default Bedrock model. This still confirms wake delivery at the Pi event layer; it does not validate a successful model response after wake.

### Full devstack stack LLM-tool test — 2026-06-14

Used the real canonical extension stack plus `-e npm:@vanillagreen/pi-background-tasks@1.6.0`, from the devstack repo root, with `--no-session` so no session was persisted. The plugin was not added to `~/.pi/agent/settings.json` or `pi-packages.json`.

Passed with `--model anthropic/claude-haiku-4-5`:

- One LLM `bg_task` call spawned `bash -lc 'echo READY; sleep 2; echo BG_DONE'` with `notifyOnExit: true`, `notifyOnOutput: true`, and `notifyPattern: READY`.
- The task generated an output wake with `eventType: "output"` and `outputTail: "READY\n"`.
- The same task generated a completion wake with `eventType: "exit"` and `outputTail: "READY\nBG_DONE\n"`.
- A real model turn after wake completed without error.
- A separate LLM `bash` tool call to `tail -f /tmp/pi-vg-autobg-...log` was auto-backgrounded as a background task with reason `follow-mode log command`, returning immediately instead of blocking.

Default-model caveat:

- The current default model (`epyc/shisa-ai/Qwen3.6-35B-A3B-PARO-packed`) did call `bg_task spawn` successfully and the task/wake event worked, but the model then emitted repeated literal `<tool_call>` text, repeatedly called `bg_task log` without an id, and spawned duplicate test tasks during wake handling.
- Treat that as a model/tool-use risk before canonical promotion. The plugin itself passed the load/spawn/output-wake/exit-wake checks with a stronger tool-calling model.

Still not covered yet:

- Interactive TUI dashboard behavior.
- Cross-restart durable missed-exit replay.
- Long-running noisy-output budget behavior over many wakes.
- Prompt-cache / `pi-context-prune` quality over real multi-hour sessions.

### Promotion checklist

Use `pi -e` for isolated trials so the canonical stack does not change during evaluation:

```bash
pi --no-extensions \
  -e npm:@vanillagreen/pi-background-tasks@1.6.0 \
  --no-session --no-context-files \
  -p 'Use bg_task to spawn a short command that sleeps, prints BG_DONE, then exits; inspect its status/log and summarize.'
```

Checks:

- ✅ The extension loads in isolation.
- ✅ `bg_task` appears as a tool and can spawn a command with Haiku 4.5.
- ✅ Slash-command `list` and `log` work in isolation.
- ✅ Exit wake/follow-up delivery appears in the conversation after task completion.
- ✅ `notifyPattern` output wake works for `READY` with Haiku 4.5.
- ✅ Auto-backgrounding catches a `tail -f` monitor command through the LLM `bash` tool path.
- ⚠️ Validate model policy: default epyc/Qwen had poor tool-loop behavior even though the plugin worked.
- ⏳ Confirm wake messages stay small enough not to defeat `pi-context-prune` batching in real long sessions.
- ⏳ `tools/pi-sync.sh --dry-run --prune --no-update` would remove it until and unless we promote it into `pi-packages.json`.

## Promotion policy

If the test succeeds and we decide to make `@vanillagreen/pi-background-tasks` canonical:

1. Add it to `pi-packages.json`.
2. Update `README.md` under Automation & Workflow or Task Management.
3. Update `pi-setup.sh` only if configuration bootstrap is needed; otherwise manifest sync is enough.
4. Update [[tools/pi-agent]] installed/evaluated extension tables.
5. Keep this page as the detailed landscape/provenance record.
6. Commit all setup/docs/wiki changes in the same logical unit.
