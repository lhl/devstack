# Pi background-task plugin comparison notes — 2026-06-14

Source type: in-session research/conversation excerpts supplied by the user, plus local npm metadata checks run during the 2026-06-14 devstack update.

## User-provided comparison excerpt

The prior comparison covered at least these pi.dev / npm packages:

- `@trevonistrevon/pi-loop`
- `@vanillagreen/pi-background-tasks`
- `@zackify/pi-bg-tasks`
- `@ifi/pi-background-tasks`
- `pi-bg-run`
- `pi-background-tasks` by ismailsaleekh
- `@richardgill/pi-tmux-bash`
- `@artale/pi-procs`
- adjacent packages such as `pi-tau`, `pi-schedule-prompt`, `pi-bash-bg`, `pi-tmux-task`, `pi-monitor`, and `@juanibiapina/pi-gob`

Key claims from that comparison:

- `@trevonistrevon/pi-loop` is not primarily a background-shell manager. It is cron/event loop infrastructure plus process monitoring. It fits "wake the agent periodically or on events" more than "run a dev server without blocking."
- `@vanillagreen/pi-background-tasks` looked like the most engineered pure background-task plugin. It has explicit background task tools, auto-backgrounding for blocking monitors, exit wakeups, output-match wakeups, wake budgets, context-tail caps, optional resource controls, and durable missed exit wake replay across restarts / PID reuse.
- `pi-background-tasks` by ismailsaleekh has a distinctive agent-telemetry angle for background `pi -p ...` children, including context-window/token/tool/model visibility, but cross-restart process reattachment is out of scope and it uses an ISC license.
- The tmux camp trades portability for inspectability. `@richardgill/pi-tmux-bash` is a drop-in `bash` replacement where foreground timeouts can convert to background tasks; `@zackify/pi-bg-tasks` is more human-oriented/poll-driven.
- `@ifi/pi-background-tasks` is the upstream ancestor of vanillagreen's fork and now appears to lag it.
- `pi-bg-run` and `@artale/pi-procs` are minimal options: completion-only notification or lightweight process management rather than rich wake semantics.

Recommendation from the prior comparison:

1. Shortlist `@vanillagreen/pi-background-tasks` as the default background-task layer.
2. Consider `@richardgill/pi-tmux-bash` if the desired architecture is replacing the bash substrate instead of adding a parallel tool.
3. Add `pi-loop` separately only if cron/event re-wakes are needed beyond the existing `pi-multiloop` / `pi-schedule-prompt` stack.

## User-provided devstack fit excerpt

After looking at devstack, the prior conclusion was:

- devstack already covers loop/heartbeat workflows with `pi-multiloop` and `pi-schedule-prompt`.
- `lhl/pi-tasks` is the tintinweb-lineage task package that `pi-loop` can integrate with, so `pi-loop` is mostly redundant for devstack right now.
- Completion-triggered injection is the desired primitive for background tasks, and the plugins differ significantly in their injection surfaces.

Delivery/injection comparison:

- `@vanillagreen/pi-background-tasks` has the richest semantics:
  - exit wakeups
  - output-match wakeups gated by `notifyPattern`
  - `notifyMode` of transition or first-match-only by default
  - durable missed exit wake replay across session restarts / PID reuse
  - output wakes delivered as steer messages
  - exit wakes delivered as follow-up messages
- `@richardgill/pi-tmux-bash` covers completion follow-up and optional polling, but does not have pattern-triggered mid-run output wakes.
- ismailsaleekh's `pi-background-tasks` and `pi-bg-run` are completion-only wakeup systems.
- `@zackify/pi-bg-tasks` and `@artale/pi-procs` are effectively poll-only/no-wakeup options for this criterion.
- None of these can interrupt an already-running tool call; injected messages queue until the current tool boundary.

Maintainability notes:

- vanillagreen is actively maintained but lives in the vstack monorepo and has optional/soft couplings to other vstack pieces such as session bridge / Flightdeck / tool renderer.
- It is MIT and zero-dependency, so extraction should be tractable if a fork is needed.
- `@richardgill/pi-tmux-bash` is also in a monorepo, and package metadata had a license question to check before forking.

Devstack-specific recommendation:

- Prefer vanillagreen, with a fork in reserve.
- Verify how wake messages interact with `pi-context-prune` batching (`agent-message`) and prompt-cache locality.

## User-provided pi-monitor excerpt

The prior conclusion on `pi-monitor` was situational:

- It delivers events with `deliverAs: "followUp"` and `triggerTurn: false`, so it is ambient context enrichment rather than injection-on-completion.
- It has good small-plugin engineering ideas: event coalescing, truncation, firehose auto-stop, concurrency caps, stderr written to file and read on demand, and "silence costs zero tokens" as a design axiom.
- It is immature: version `0.1.0`, one release, low downloads.
- There was an explicit concern that pi's follow-up drain can still start extra LLM turns, making `triggerTurn: false` weaker than advertised and potentially bad for `pi-context-prune` batching / prompt-cache hit rate.
- Verdict: do not adopt as infrastructure; steal the passive-stream pattern later if needed.

## Local npm metadata checked 2026-06-14

`npm config get before` returned `Sun Jun 07 2026 11:56:56 GMT+0900 (Japan Standard Time)`, so very recent package versions are intentionally age-gated locally.

`npm view @vanillagreen/pi-background-tasks --json` showed:

- latest version: `1.6.1`
- latest publish time: 2026-06-12
- created: 2026-05-06
- license: MIT
- repository: `https://github.com/vanillagreencom/vstack`, directory `pi-extensions/pi-background-tasks`
- description: `Pi extension for explicit non-blocking background shell tasks, log tails, and completion wakeups.`

`npm pack @vanillagreen/pi-background-tasks@1.6.1` failed under the local npm age gate because that version is newer than the configured `before` date. `npm pack @vanillagreen/pi-background-tasks@1.6.0` succeeded. The 1.6.0 tarball had 32 files, about 596 KB packed / 819 KB unpacked, and included:

- `extensions/background-tasks.ts`
- `extensions/wake-events.ts`
- `extensions/auto-background.ts`
- `extensions/resource-control.ts`
- `extensions/persistence.ts`
- `instructions.md`
- README assets and two small tests

README/tool metadata confirmed:

- `bg_task` supports `spawn`, `list`, `log`, `stop`, and `clear`.
- `bg_status` supports listing/inspecting/stopping tracked tasks.
- spawn parameters include `notifyOnExit`, `notifyOnOutput`, `notifyPattern`, `notifyMode`, `dedupeKey`, `timeoutSeconds`, and `title`.
- output wake defaults are budgeted; exit wakes use `deliverAs: "followUp", triggerTurn: true`; output wakes use `deliverAs: "steer", triggerTurn: true`.
- tasks are scoped to the current Pi runtime and stopped on session shutdown, while exit wake replay is durable across reload/restart for missed terminal notifications.

Other npm metadata checked locally:

- `@trevonistrevon/pi-loop` version `0.5.5`, modified 2026-06-10, description: cron/event-based agent re-wake loops and background process monitoring.
- `@richardgill/pi-tmux-bash` version `0.0.12`, modified 2026-06-06, description: drop-in bash replacement using tmux; no license field in npm metadata.
- `@zackify/pi-bg-tasks` version `0.1.3`, modified 2026-05-12, MIT.
- `@ifi/pi-background-tasks` version `0.5.1`, modified 2026-04-28, MIT.
- `pi-bg-run` version `1.1.4`, modified 2026-06-07, MIT.
- `pi-background-tasks` by ismailsaleekh version `0.6.0`, modified 2026-05-31, ISC.
- `@artale/pi-procs` version `1.1.2`, modified 2026-04-21, MIT.
- `pi-monitor` version `0.1.0`, modified 2026-04-09, MIT.
- `@juanibiapina/pi-gob` version `0.6.0`, modified 2026-05-20, MIT.
- `pi-bash-bg` version `0.1.1`, modified 2026-04-03, MIT.
