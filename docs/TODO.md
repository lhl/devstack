# TODO

## Background Execution Stack (in progress)

Goal: composable background execution + task management for pi.

### Components

| Component | Source | Status |
|-----------|--------|--------|
| [gob](https://github.com/juanibiapina/gob) | Process manager backend | Need to install binary |
| [@juanibiapina/pi-gob](https://github.com/juanibiapina/pi-gob) | Powerbar segment + `/gob` interactive TUI | Install when ready |
| [lhl/pi-backtask](https://github.com/lhl/pi-backtask) | Background execution, result injection, `bg_process` tool | Extending with subagent functionality |
| [@tintinweb/pi-tasks](https://github.com/tintinweb/pi-tasks) | LLM-callable structured task management (7 tools) | ✅ Installed |

### Integration Plan

1. Finish pi-backtask subagent extension
2. Install gob binary
3. Install pi-gob (`pi install npm:@juanibiapina/pi-gob`)
4. Install pi-backtask from fork (`pi install git:github.com/lhl/pi-backtask`)
5. Verify all three compose without conflicts
6. Update wiki/tools/pi-agent.md with final setup
7. Update pi-setup.sh and README.md

### Composition Notes

**pi-tasks ↔ pi-backtask:** No conflicts. Different tool names, different keybindings, different storage.
- pi-tasks = LLM self-organizes work (structured tasks, dependencies, `TaskCreate`/`TaskList`/etc.)
- pi-backtask = background execution engine + human task tracking (`/bg run`, `/bg agent`, `bg_process`)

**pi-tasks TaskExecute:** Uses `@tintinweb/pi-subagents` via `pi.events` RPC protocol (`subagents:rpc:spawn`, `subagents:completed`, `subagents:failed`). If pi-backtask emits the same events, pi-tasks could track agent tasks spawned by pi-backtask automatically — but this requires implementing the `pi-subagents` RPC protocol in pi-backtask.

**pi-gob ↔ pi-backtask:** Both talk to gob. pi-gob is view-only (daemon socket subscription + interactive TUI). pi-backtask spawns jobs via `gob add` CLI. No conflicts — pi-gob will show jobs that pi-backtask spawns.

### Do we need to fork pi-tasks?

**Probably not yet.** pi-tasks is designed to be composable:
- Its `TaskExecute` only fires if `@tintinweb/pi-subagents` is loaded (checked via RPC ping)
- Without pi-subagents, the other 6 tools (TaskCreate, TaskList, TaskGet, TaskUpdate, TaskOutput, TaskStop) work standalone
- The task store, dependency tracking, widget, and system-reminder injection are all independent of the subagent layer

**Fork if:** we want pi-backtask to be the subagent backend instead of `@tintinweb/pi-subagents`. That would mean pi-backtask implements the `subagents:rpc:spawn` / `subagents:completed` / `subagents:failed` event protocol so pi-tasks' TaskExecute works with gob-backed agents instead of pi-subagents' in-process agents.

**Alternative:** Just implement the pi-subagents RPC protocol in pi-backtask as a compatibility layer. Then pi-tasks works unmodified.

---

## Other

- [ ] Review pi-backtask subagent work when complete
- [ ] Evaluate whether `@tintinweb/pi-subagents` RPC compat layer in pi-backtask is worth it vs fork
