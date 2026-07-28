---
title: OpenAI Codex
tags: [tools, coding-agents, codex, sqlite, logging, operations]
sources: []
links:
  - https://github.com/openai/codex
  - https://github.com/openai/codex/issues/29674
---

# OpenAI Codex

OpenAI Codex is a coding-agent CLI and app. Local state is stored under `~/.codex/`, including sessions and a SQLite application-log database at `~/.codex/logs_2.sqlite`.

## Local TRACE-log suppression workaround (2026-07-29)

We installed a local SQLite trigger to suppress persisted `TRACE` events while retaining `DEBUG`, `INFO`, `WARN`, and `ERROR` logs. This is a temporary, unsupported mitigation for the excessive log/WAL write-pressure behavior tracked in [openai/codex#29674](https://github.com/openai/codex/issues/29674), not an upstream product fix.

### State observed before the change

The local installation was `codex-cli 0.144.0`. With Codex fully stopped and no process holding the database files, inspection found:

| Metric | Observed value |
| --- | ---: |
| `logs_2.sqlite` size | 63.0 MiB |
| `logs_2.sqlite-wal` size | 4.3 MiB |
| Retained rows | 2,000 |
| `logs` ID high-water mark | 159,707,075 |
| Estimated retained payload | 2,000,666 bytes (1.9 MiB) |
| Retained TRACE rows | 1,517 (76%) |
| SQLite free pages | 15,345 of 16,132 (95%) |
| Retained timestamp window | 2026-07-28 18:04:12–18:36:37 JST |

The small retained row count alongside the high ID counter is consistent with repeated insertion and pruning. The database and WAL sizes do not reveal cumulative historical writes because SQLite can reuse allocated database pages and WAL space.

### Change applied

Before changing the database, we created this consistent SQLite backup:

```text
~/.codex/backups/logs_2-before-trace-trigger-20260729-053839.sqlite
```

We then installed the upstream-reported TRACE-only trigger:

```sql
CREATE TRIGGER IF NOT EXISTS codex_suppress_trace_logs
BEFORE INSERT ON logs
WHEN NEW.level = 'TRACE'
BEGIN
  SELECT RAISE(IGNORE);
END;
```

Equivalent command, to be run only while Codex is fully stopped:

```bash
sqlite3 ~/.codex/logs_2.sqlite <<'SQL'
CREATE TRIGGER IF NOT EXISTS codex_suppress_trace_logs
BEFORE INSERT ON logs
WHEN NEW.level = 'TRACE'
BEGIN
  SELECT RAISE(IGNORE);
END;
SQL
```

Verification used a transaction that was rolled back: a test `TRACE` insert reported zero inserted rows, a test `INFO` insert reported one inserted row, and no verification rows remained afterward. This confirms that the trigger blocks only `TRACE` rows.

### Check or reverse the workaround

Inspect the installed trigger:

```bash
sqlite3 ~/.codex/logs_2.sqlite \
  "SELECT name, sql FROM sqlite_master WHERE type='trigger' AND name='codex_suppress_trace_logs';"
```

Remove it, again only while Codex is fully stopped:

```bash
sqlite3 ~/.codex/logs_2.sqlite \
  "DROP TRIGGER IF EXISTS codex_suppress_trace_logs;"
```

### Caveats

- This trigger is an unsupported local workaround and may disappear if Codex recreates or migrates the database.
- Suppressing `TRACE` logs reduces diagnostic detail. Remove the trigger before collecting full traces for an upstream bug report.
- The trigger does not shrink the already allocated database file or measure/recover historical SSD writes.
- Do not replace it with an unconditional trigger unless intentionally disabling all persisted logs, including warnings and errors.
- Recheck the upstream issue and remove the trigger after Codex ships and verifies a product-level fix.
