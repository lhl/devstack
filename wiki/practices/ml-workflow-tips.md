---
title: ML Workflow Tips
tags: [workflow, python, tooling, shell, dev-environment]
sources: [sources/articles/ml-workflow-tips.md, https://llm-tracker.info/howto/ML-Workflow-Tips]
links: [[tools/rtk]]
---

# ML Workflow Tips

Opinionated environment setup for ML/AI development. Focus: fast iteration, reproducible envs, good shell UX.

## Python Environment: mamba + uv

### mamba (miniforge)

Use [mamba](https://github.com/conda-forge/miniforge) instead of conda. It's significantly faster at resolving and installing packages. Mamba manages system-level dependencies (CUDA, GCC, etc.) that pip can't handle.

**Key workflow:** one mamba env per project. Clone from a template env rather than rebuilding from scratch every time:

```bash
mamba create -n my-project --clone baseml
```

Cloning an 18GB env (mostly PyTorch) takes ~28s on a fast NVMe vs ~80s to reinstall everything from scratch even with cached packages.

**Caveat:** `--clone` doesn't copy environment variables. If you have GPU-specific vars set, export and re-apply:

```bash
# Export template env config
conda env export -n baseml | mamba env update -n new_env -f -
```

### uv

[uv](https://github.com/astral-sh/uv) is a fast Python package installer (Rust-based, from Astral). Use it as a drop-in replacement for pip within mamba envs:

```bash
pip install uv
uv pip install transformers  # ~500ms vs seconds with pip
```

The pattern: mamba for env/system libs, `uv pip` for all Python packages within the env.

## Node.js: nvm.fish

For managing Node.js versions, use [jorgebucaran/nvm.fish](https://github.com/jorgebucaran/nvm.fish) (fish shell) or [nvm-sh/nvm](https://github.com/nvm-sh/nvm) (bash/zsh). Lightweight version manager, no shims.

```fish
# fish (via fisher)
fisher install jorgebucaran/nvm.fish
nvm install lts
set --universal nvm_default_version lts
```

## Shell: fish + Starship

Primary shell: [fish](https://fishshell.com/) — good defaults, fast, great completions. Fall back to zsh/bash when POSIX compatibility is needed.

[Starship](https://starship.rs/) — fast cross-shell prompt. Works identically in fish, zsh, and bash so you always know where you are. Minimal config in `~/.config/starship.toml`:

```toml
[shell]
fish_indicator = "🐟"
zsh_indicator = "ℤ"
bash_indicator = "\\$"
disabled = false
```

## Terminal Multiplexer: byobu/tmux

[byobu](https://www.byobu.org/) wraps tmux/screen with quality-of-life defaults. Essential for long-running training jobs — attach/detach freely.

Pro tip: name tmux sessions after your mamba envs and auto-activate on attach:

```fish
# ~/.config/fish/config.fish
function b
    if test -z "$argv[1]"
        byobu list-session
        return 1
    end
    if byobu list-sessions | grep -q "$argv[1]"
        byobu attach-session -t "$argv[1]"
    else
        byobu new-session -s "$argv[1]"
    end
end

# Auto-activate mamba env matching tmux session name
if test -n "$TMUX"
    set tmux_session_name (tmux display-message -p '#S')
    mamba activate $tmux_session_name[1] 2>/dev/null
end
```

## History: Atuin

[Atuin](https://atuin.sh/) — better shell history with fuzzy search, per-session filtering, and optional sync. Hard to go back once you've used it.

Key config choices in `~/.config/atuin/config.toml`:

```toml
# Search mode
search_mode = "fuzzy"

# Up-arrow searches current session, not global history
filter_mode_shell_up_key_binding = "session"

# Show context inline rather than taking over the screen
style = "full"
inline_height = "16"
show_preview = true

# Treat picker as picker — don't auto-execute on enter
enter_accept = false
```

No cloud sync configured — local-only history is fine for now. Self-hosting is possible but not worth the overhead yet.
