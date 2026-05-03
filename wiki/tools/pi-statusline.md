---
title: Pi Status Line (Powerline Footer)
tags: [tools, pi, configuration, tui, ui]
links:
  - https://github.com/nicobailon/pi-powerline-footer
  - https://github.com/mjakl/pi-statusbar
  - https://github.com/Graffioh/dotfiles/tree/main/pi/agent/extensions/berto-powerline-footer
  - https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/docs/tui.md
---

# Pi Status Line (Powerline Footer)

The default pi footer is minimal: working directory, session name, token/cache usage, cost, context %, and current model. The editor border color changes with thinking level, but there's no segment config, no glyphs, no presets. For a colorful, segmented, themeable status bar (equivalent to ccstatus / claude-hud for Claude Code), you install an extension.

## Extension API

The TUI extension surface supports: replacing the editor, adding widgets above/below it, adding a status line, replacing the footer, and overlays. Segments don't have to be owned by one extension — any extension can publish into a shared status registry via `extension_statuses` + a `statusKey`. This is how popular powerline footers pick up status from other extensions.

See [[tools/pi-agent]] for the full extension API surface.

## Third-Party Status Bars

### pi-powerline-footer (Popular)

[nicobailon/pi-powerline-footer](https://github.com/nicobailon/pi-powerline-footer) — ~8.5k installs/month, inspired by Powerlevel10k and oh-my-pi.

**Rendering:** A rounded box in the editor's top border (not a standalone footer line). Auto-detects Nerd Font support across iTerm, WezTerm, Kitty, Ghostty, Alacritty. Force with `POWERLINE_NERD_FONTS=1|0`.

**Segments:**
- Model name
- Thinking level (per-level colors, rainbow on high/xhigh)
- Path
- Git (async, 1s TTL — branch, staged/unstaged/untracked counts, ahead/behind; invalidates on file writes)
- Context % (yellow at 70%, red at 90%)
- Auto-compact indicator
- Token count (smart formatting: `1.2k/45M`)
- Cost (with `(sub)` vs `$` detection)

**Configuration:** Presets + `customItems` (id, statusKey, position: left/secondary/right, prefix, color). Separate `~/.pi/agent/extensions/powerline-footer/theme.json` for color overrides — palette names: accent, muted, dim, text, success, warning, error, border, borderAccent, borderMuted, or raw hex.

**Bundled extras:** `/vibe` (LLM-generated themed loading messages, e.g. `/vibe star trek` → "Engaging warp drive…"), branded welcome overlay, Alt+S editor stash, sticky bash mode with ghost suggestions.

```bash
pi install npm:pi-powerline-footer
```

### pi-statusbar (Focused Fork)

[mjakl/pi-statusbar](https://github.com/mjakl/pi-statusbar) — pi-powerline-footer with extras (splash, vibe, overlay) stripped out. Just the status bar.

**Presets:** `default`, `focused`, `minimal`, `compact`, `full`, `nerd`, `ascii`. Switch with `/powerline <preset>`.

The closer match to ccstatus-style discipline — no noise, just the bar.

```bash
pi install git:github.com/mjakl/pi-statusbar
```

### berto-powerline-footer (Reference)

[Graffioh/dotfiles/.../berto-powerline-footer](https://github.com/Graffioh/dotfiles/tree/main/pi/agent/extensions/berto-powerline-footer) — a personal fork useful as a **segment vocabulary reference**. Lists available pieces explicitly:

`pi · model · thinking · path · git · subagents · token_in · token_out · token_total · cost · context_pct · context_total · time_spent · time · session · hostname · cache_read · cache_write · powerline`

Local extension, fork-and-edit style. No npm package.

### pi-agent-extensions (Bundle)

[jayshah5696/pi-agent-extensions](https://github.com/jayshah5696/pi-agent-extensions) ships a slim Powerline Footer alongside other utilities (sessions, ask_user, handoff). Install for the bundle if you want those too.

## Slash Commands

Once a powerline is loaded:

```
/powerline                 # Toggle on/off
/powerline <preset>        # Switch preset
```

Preset is persisted in `~/.pi/agent/settings.json` under `powerline` and restored on startup. `/reload` re-reads after editing `theme.json` or custom items.

## Authoring a Custom Status Bar

The path: a TypeScript extension that registers a custom footer/status widget and emits keys other extensions can hook. pi-powerline-footer's source is a clean blueprint, and pi can read its own docs and rewrite its own extensions in-session.

Forking `pi-powerline-footer` or `pi-statusbar` into a personal variant with custom segments (Shisa endpoint health, GPU util via polled script, eval queue depth, etc.) is roughly a one-session task — pi edits its own extensions.

See the segment vocabulary from berto-powerline-footer above for the full list of available data sources to wire into custom segments.