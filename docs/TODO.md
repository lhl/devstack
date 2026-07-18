# TODO

## Background Execution Stack (in progress)

Goal: composable background execution + task management for pi without blocking agent turns or flooding context.

### Current direction (2026-06-14)

The earlier gob/`pi-backtask` plan is superseded for now by evaluating maintained Pi background-task plugins directly. See [`wiki/tools/pi-background-task-plugins.md`](../wiki/tools/pi-background-task-plugins.md).

| Candidate | Role | Status |
|-----------|------|--------|
| [`@vanillagreen/pi-background-tasks`](https://www.npmjs.com/package/@vanillagreen/pi-background-tasks) | Explicit `bg_task` / `/bg` shell tasks, auto-backgrounded monitors, completion + output-pattern wakeups | ✅ Canonical as `npm:@vanillagreen/pi-background-tasks@1.6.0`; default epyc/Qwen tool-loop caveat remains operational guidance |
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

1. ✅ Use `pi -e` so the canonical stack does not change during the first trial.
2. ✅ Because local npm has `before` set to 2026-06-07, test `@vanillagreen/pi-background-tasks@1.6.0` first; `1.6.1` is newer than the local age gate.
3. ✅ Verify basic slash-command flow on a short command: `/bg:run`, `/bg:list`, `/bg log`, `/bg:clear`.
4. ✅ Verify completion exit event delivery after task completion.
5. ✅ Verify LLM-tool `bg_task` invocation with `notifyOnOutput` + `notifyPattern` for a `READY` / `BG_DONE` line using `anthropic/claude-haiku-4-5`.
6. ✅ Verify auto-backgrounding for an obvious monitor command through the LLM `bash` tool path; `tail -f` was auto-backgrounded as a follow-mode log command.
7. ⚠️ Record model guidance: the current default `epyc/shisa-ai/Qwen3.6-35B-A3B-PARO-packed` spawned the task and received wakes but then produced repeated literal `<tool_call>` text, bad `bg_task log` calls, and duplicate spawns; prefer stronger tool-calling models for autonomous background-task workflows.
8. ⏳ Test interactive dashboard behavior and shortcut ergonomics.
9. ✅ Promoted into `pi-packages.json`, `README.md`, `pi-setup.sh`, `wiki/tools/pi-agent.md`, and `wiki/tools/pi-background-task-plugins.md` in the same logical unit.

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
