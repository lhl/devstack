---
source: https://llm-tracker.info/howto/ML-Workflow-Tips
author: lhl
retrieved: 2026-05-04
type: article
---

# ML Workflow Tips

Extracted from llm-tracker.info/howto/ML-Workflow-Tips (self-authored).

## mamba

Use [mamba](https://github.com/conda-forge/miniforge) instead of conda. It's significantly faster.

### Cloning envs

Currently I have ~60 mamba envs on my main dev machines. >300GB on disk, but tough early lessons that overloading envs would always lead to dll/version hell. One recently learned pro-tip. You can use a template env to speed this up: `create -n [new-env] --clone [baseml-env]`

On my local workstation that has a reasonably fast PCIe 4.0 NVMe SSD (5GB/s+ sequential writes) it takes about **28 s** of wall time to create a clone (18GB env, 17GB of it is PyTorch).

**NOTE:** One important note is that when you `--clone` a new env, it doesn't move over your environment variables. If you assign GPU specific stuff for example, you might want to either:

```
# export env to file, do what you want
conda env export -n baseml > environment.yml

# pipe template env direct to new_env
conda env export -n baseml | mamba env update -n new_env -f -
```

## uv

I use mamba/conda since it will manage CUDA/GCC and other system libraries as well, but for Python libs, I basically stick completely to `pip` from within the mamba env. Or more specifically, nowadays I always first have [uv](https://github.com/astral-sh/uv) as the first thing installed (`pip install uv` if it's not in your `--clone`) and then run `uv pip` almost anytime I'd normally run `pip`.

## byobu

I'm a long-time user of [byobu](https://www.byobu.org/), a wrapper against traditional tmux/screen terminal multiplexers. These are a **must** IMO for allowing easy attachment/detachment of long-running adhoc sessions.

Byobu has a bunch of extra quality of life additions, but I also add a few things to help. I have a custom function `b` that will also try to load up the mamba env if I'm trying to startup/reconnect to a named session.

## Starship

I use [Starship](https://starship.rs/), a simple/fast cross-shell prompt. For the past few years I've mostly used `fish` as my shell, but often need to hop into `bash` for POSIX compatibility.

## Atuin

[Atuin](https://atuin.sh/) is a better history manager that I've been using for a few years now, and despite having to do a lot of configuration to get/keep it working how I want, I couldn't imagine going back to anything that has _less_ functionality.

Key config changes from defaults:
- `filter_mode_shell_up_key_binding = "session"` — find last thing typed in each session, not globally
- `inline_height = 16` — see current context when searching
- `enter_accept = false` — treat picker like a picker, don't auto-execute

I don't use the cloud syncing nor have I ever bothered to setup my own server.

## llm

simonw's [llm](https://github.com/simonw/llm) is probably the most flexible/mature CLI LLM tool.

## wut

Still a little underbaked but a great idea: [https://github.com/shobrook/wut](https://github.com/shobrook/wut)
