# TODO

## Background Execution Stack (in progress)

Goal: composable background execution + task management for pi without blocking agent turns or flooding context.

### Current direction (2026-06-14)

The earlier gob/`pi-backtask` plan is superseded for now by evaluating maintained Pi background-task plugins directly. See [`wiki/tools/pi-background-task-plugins.md`](../wiki/tools/pi-background-task-plugins.md).

| Candidate | Role | Status |
|-----------|------|--------|
| [`@vanillagreen/pi-background-tasks`](https://www.npmjs.com/package/@vanillagreen/pi-background-tasks) | Explicit `bg_task` / `/bg` shell tasks, auto-backgrounded monitors, completion + output-pattern wakeups | **Next test** via `pi -e npm:@vanillagreen/pi-background-tasks@1.6.0` |
| [`@richardgill/pi-tmux-bash`](https://www.npmjs.com/package/@richardgill/pi-tmux-bash) | tmux-backed drop-in `bash` replacement, timeout→background | Alternative if substrate replacement is preferable; verify license first |
| [`@trevonistrevon/pi-loop`](https://www.npmjs.com/package/@trevonistrevon/pi-loop) | Cron/event re-wake loops plus process monitors | Mostly redundant with `pi-multiloop` + `pi-schedule-prompt` for devstack |
| `pi-monitor` | Passive filtered stream as context | Pattern to steal later, not infrastructure now |
| `gob` + `@juanibiapina/pi-gob` + `lhl/pi-backtask` | Older process-manager-backed plan | Parked unless plugin options fail or gob reattach becomes necessary |

### Why vanillagreen first

- Completion wakeups and output-match wakeups are both supported.
- Output wakeups have budget controls (`outputAlertMaxChars`, wake count, cumulative bytes) and transition/first-match defaults.
- Obvious blocking monitors (`watch`, `tail -f`, `journalctl -f`, polling loops) auto-background before they freeze a turn.
- Exit wakeups are durable across reload/restart/PID reuse cases.
- The package is MIT and zero-dependency, so a fork is tractable if vstack monorepo coupling becomes a problem.

### Test plan

1. Use `pi -e` so the canonical stack does not change during the first trial.
2. Because local npm has `before` set to 2026-06-07, test `@vanillagreen/pi-background-tasks@1.6.0` first; `1.6.1` is newer than the local age gate.
3. Verify basic `bg_task spawn/list/log/stop` on a short command.
4. Verify `notifyOnExit` follow-up delivery after completion.
5. Verify `notifyOnOutput` + `notifyPattern` steer delivery for a `READY` / `BG_DONE` line.
6. Verify auto-backgrounding for an obvious monitor command without blocking.
7. Watch interaction with `pi-context-prune` batching: wake streams should not fragment batches or harm prompt-cache locality.
8. If promoted, update `pi-packages.json`, `README.md`, `pi-setup.sh` if config bootstrap is needed, `wiki/tools/pi-agent.md`, and `wiki/tools/pi-background-task-plugins.md` in the same logical unit.

### Parked historical plan

The old plan was:

1. Install gob.
2. Install `@juanibiapina/pi-gob` for a `/gob` interactive TUI.
3. Install/fork `lhl/pi-backtask` for background execution, result injection, and a `bg_process` tool.
4. Optionally implement the `@tintinweb/pi-subagents` RPC protocol so `pi-tasks TaskExecute` could track spawned agent tasks.

Keep this as a fallback only if maintained single-plugin options fail. `lhl/pi-tasks` is already forked and canonical, so task tracking no longer depends on upstream `@tintinweb/pi-subagents`.

---

## Other

- [ ] Review pi-backtask subagent work when complete
- [ ] Evaluate whether `@tintinweb/pi-subagents` RPC compat layer in pi-backtask is worth it vs fork
