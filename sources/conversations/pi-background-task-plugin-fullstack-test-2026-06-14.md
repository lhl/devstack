# @vanillagreen/pi-background-tasks devstack-context tests — 2026-06-14

Local tests run from `/home/lhl/github/lhl/devstack` after the initial isolated slash-command smoke test.

The plugin was loaded with `-e npm:@vanillagreen/pi-background-tasks@1.6.0`; it was **not** added to `~/.pi/agent/settings.json` or `pi-packages.json`.

## Environment notes

Canonical devstack Pi settings were used unless otherwise stated:

- cwd: `/home/lhl/github/lhl/devstack`
- Pi mode: `--mode json`
- session persistence: `--no-session`
- extra extension: `-e npm:@vanillagreen/pi-background-tasks@1.6.0`
- canonical extensions remained active, including `pi-context-prune`, `pi-tasks`, `pi-multiloop`, `pi-schedule-prompt`, `pi-vcc`, etc.
- stderr showed the pre-existing `pi-vertex` warning: no Google Cloud project ID configured.

No persistent package-stack change was made. A grep of `~/.pi/agent/settings.json` after the test found no `vanillagreen` / `pi-background-tasks` entry.

## Full-stack LLM tool test with Haiku 4.5

Command shape:

```bash
pi --mode json \
  --no-session \
  --model anthropic/claude-haiku-4-5 \
  -e npm:@vanillagreen/pi-background-tasks@1.6.0 \
  -p 'One-tool test ... Make exactly one tool call: bg_task with action spawn, command: bash -lc '\''echo READY; sleep 2; echo BG_DONE'\'', notifyOnExit true, notifyOnOutput true, notifyPattern READY ...'
```

Summarized JSONL result:

```text
RC=0
counts {'session': 1, 'agent_start': 1, 'turn_start': 4, 'message_start': 8, 'message_end': 8, 'message_update': 56, 'tool_execution_start': 1, 'tool_execution_end': 1, 'turn_end': 4, 'agent_end': 1}
starts [('bg_task', {'action': 'spawn', 'command': "bash -lc 'echo READY; sleep 2; echo BG_DONE'", 'notifyOnExit': True, 'notifyOnOutput': True, 'notifyPattern': 'READY'})]
ends [('bg_task', False, "Started bg-1 ... Wakeups: exit=yes, output=READY, mode=first-match-only")]
custom events:
  output bg-1 notifyOnOutput=True notifyPattern=READY outputTail='READY\n'
  exit   bg-1 notifyOnOutput=True notifyPattern=READY outputTail='READY\nBG_DONE\n'
assistant text: '(Acknowledged. Task bg-1 completed successfully.)'
errors: none
```

Interpretation:

- `bg_task` is visible to the model in the full canonical extension stack.
- LLM tool invocation works with `notifyOnExit`, `notifyOnOutput`, and `notifyPattern`.
- `notifyPattern: READY` produced an output wake event while the task was still running.
- The task's normal completion produced a later exit wake event with the final output tail.
- The real model turn after wake completed successfully with Haiku 4.5.
- In JSONL, the output and exit events each appear as `message_start` and `message_end`; they are not duplicate plugin events.

## Auto-background test through the LLM `bash` tool path

Command shape:

```bash
watch=/tmp/pi-vg-autobg-652601.log
printf 'seed\n' > "$watch"
pi --mode json \
  --no-session \
  --model anthropic/claude-haiku-4-5 \
  -e npm:@vanillagreen/pi-background-tasks@1.6.0 \
  -p "Auto-background test. Make exactly one tool call to the built-in bash tool with this exact command and no extra wrapping: tail -f $watch ..."
```

Summarized JSONL result:

```text
RC=0
counts {'session': 1, 'agent_start': 1, 'turn_start': 2, 'message_start': 4, 'message_end': 4, 'message_update': 26, 'tool_execution_start': 1, 'tool_execution_update': 2, 'tool_execution_end': 1, 'turn_end': 2, 'agent_end': 1}
starts [('bash', {'command': 'tail -f /tmp/pi-vg-autobg-652601.log'})]
ends [('bash', False, 'Started bg-1 (pid 652963) in the background.\nReason: follow-mode log command.\nCommand: tail -f /tmp/pi-vg-autobg-652601.log\nCwd: /home/lhl/github/lhl/devstack\nLog: /tmp/vstack-pi-bg/bg-1-1781407089145.log\nWakeups: exit=yes, output=no, mode=transition\nContinue the turn without waiting. Use bg_task list/log/stop to inspect or terminate this task.\n')]
assistant text: 'Yes, it was auto-backgrounded...'
errors: none
```

Interpretation:

- Auto-backgrounding works through the real LLM `bash` tool path.
- A `tail -f` follow-mode log command returned immediately as a background task instead of blocking the tool call.
- The result text tells the model to continue and use `bg_task list/log/stop` for inspection or termination.
- The test cleanup killed any matching `tail -f` process after the run; no matching test process remained.

## Default devstack model caveat

A first full-stack run used the default configured model:

- provider: `epyc`
- model: `shisa-ai/Qwen3.6-35B-A3B-PARO-packed`

That run showed that the extension itself worked, but the model/tool loop behaved poorly:

- `bg_task spawn` was called with `notifyOnExit: true`, `notifyOnOutput: true`, and `notifyPattern: READY|BG_DONE`.
- The spawned task completed and the custom exit event contained `outputTail: 'READY\nBG_DONE\n'`.
- The model then produced repeated literal `<tool_call>` text and repeatedly attempted `bg_task log` without a task id, causing many `No background task matched that id or pid` errors.
- It also spawned extra duplicate test tasks during wake handling.

Interpretation:

- This looks like default-model/tool-calling pathology rather than a plugin load/spawn/wake failure.
- For canonical adoption, test with the model(s) actually used for agentic coding sessions. Haiku 4.5 handled the same tool path cleanly.
- If the default epyc/Qwen model remains the everyday default, add stronger system guidance or avoid relying on it for autonomous `bg_task` workflows until tool-use behavior improves.

## What remains untested

- Interactive TUI dashboard and keybinding ergonomics.
- Cross-restart durable missed-exit replay.
- Long-running noisy-output budget behavior over many wakes.
- Prompt-cache / `pi-context-prune` quality over real multi-hour sessions.

## Current recommendation after devstack-context tests

`@vanillagreen/pi-background-tasks@1.6.0` is technically viable in the devstack stack:

- explicit `bg_task` spawn/list/log style flow works,
- output-pattern wake injection works,
- completion wake injection works,
- LLM `bash` auto-backgrounding works.

Do not promote blindly for all models. The default epyc/Qwen model produced poor tool-loop behavior in this test; use a reliable tool-calling model or validate the default model interactively before making the plugin canonical.
