# @vanillagreen/pi-background-tasks isolated smoke test — 2026-06-14

Local test run for devstack background-task plugin evaluation.

## Setup

The smoke test used a temporary Pi agent directory and temporary workspace so the canonical user/project extension stack was not modified.

Environment:

- `PI_CODING_AGENT_DIR=/tmp/pi-bgsmoke-d55x79np/agent`
- `PI_BG_TASK_DIR=/tmp/pi-bgsmoke-d55x79np/tasks`
- working directory: `/tmp/pi-bgsmoke-d55x79np/work`

Command shape:

```bash
pi --mode rpc \
  --no-session \
  --no-context-files \
  --no-extensions \
  -e npm:@vanillagreen/pi-background-tasks@1.6.0
```

The test used RPC extension commands rather than installing the package into `~/.pi/agent/settings.json`.

## Checks

The RPC client performed:

1. `get_commands`
2. `/bg:run bash -lc "printf BG_START; sleep 0.2; echo BG_DONE"`
3. wait for a custom background-task exit event
4. `/bg:list`
5. `/bg log bg-1`
6. `/bg:clear`

## Result summary

```text
COMMANDS_OK= True
SPAWN_RESPONSE= True
EXIT_WAKE_SEEN= True
EXIT_WAKE_DELIVERY= exit
LIST_RESPONSE= True
LOG_RESPONSE= True
LOG_NOTIFICATION_HAS_DONE= True LOG_FILE_HAS_DONE= True
CLEAR_RESPONSE= True
MODEL_WAKE_ERROR_SEEN= True
STDERR_HAS_INSTALL= True
```

Interpretation:

- The package loaded via `pi -e`.
- `/bg`, `/bg:list`, `/bg:run`, `/bg:stop`, and `/bg:clear` were registered.
- `/bg:run` spawned a background shell task.
- The task's log contained `BG_DONE`.
- `/bg:list`, `/bg log`, and `/bg:clear` returned successfully.
- A custom background-task `exit` event was delivered after completion, confirming completion wake injection at the Pi event layer.
- The wake attempted to trigger an LLM turn; that turn failed only because the temporary test Pi config inherited an invalid default Bedrock model identifier. This is a test-harness/model-config issue, not a background-task extension load/spawn/log failure.

## Not covered

- `bg_task` LLM tool invocation with `notifyOnOutput` / `notifyPattern`; RPC commands do not directly expose arbitrary tool execution, and the slash command does not accept these advanced tool parameters.
- Auto-backgrounding of LLM `bash` tool calls; RPC `bash` commands bypassed the `user_bash`/LLM tool path used by the extension.
- Interactive TUI dashboard behavior.
- Cross-restart durable missed-exit replay.
- Interaction with the full canonical stack, especially `pi-context-prune` batching after real model wakeups.
