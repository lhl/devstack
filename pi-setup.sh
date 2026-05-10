#!/usr/bin/env bash
set -e

# Install rtk (token-optimizing CLI proxy). We no longer install pi-rtk-optimizer
# (the auto-rewrite pi extension) — see wiki/tools/pruning-and-compaction.md for
# the failure-mode analysis. The rtk binary itself is kept around so commands
# like `rtk proxy <cmd>` and `rtk gain` remain available for explicit use.
# Comment out this block if you want to fully remove rtk.
install_rtk() {
  echo "Installing rtk..."
  curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
}

# Install pi-coding-agent
install_pi() {
  if command -v npm &>/dev/null; then
    echo "Installing pi via npm..."
    npm install -g @earendil-works/pi-coding-agent
  else
    echo "npm not found. Installing via curl..."
    local tmp_dir
    tmp_dir=$(mktemp -d)
    curl -fsSL https://raw.githubusercontent.com/earendil-works/pi/main/packages/coding-agent/install.sh \
      -o "$tmp_dir/install-pi.sh"
    bash "$tmp_dir/install-pi.sh"
    rm -rf "$tmp_dir"
  fi
}

# Ensure rtk is available
if ! command -v rtk &>/dev/null; then
  install_rtk
fi
rtk --version

# Ensure pi is available
if ! command -v pi &>/dev/null; then
  install_pi
fi

# Verify installation
pi --version

# Install plugin stack
# Context/token management: pi-context-prune (conversation-level pruning with
# retrievable originals) replaced pi-rtk-optimizer (rtk auto-rewrite wrapper)
# on 2026-05-10. See wiki/tools/pruning-and-compaction.md for rationale.
pi install npm:pi-context-prune
pi install npm:pi-schedule-prompt
pi install npm:pi-boomerang
pi install npm:pi-web-access
pi install npm:pi-smart-fetch
pi install npm:@the-forge-flow/camoufox-pi@0.2.1
pi install npm:pi-code-previews
# Task management: use lhl's fork for prompt-queued execution and batch creation.
# Remove the legacy upstream package first so setup does not leave duplicate entries.
pi remove npm:@tintinweb/pi-tasks >/dev/null 2>&1 || true
pi install https://github.com/lhl/pi-tasks
pi install npm:pi-multiloop
pi install npm:@lhl/pi-vertex
pi install npm:@sting8k/pi-vcc

pi install npm:pi-codex-status
pi install npm:@victor-software-house/pi-multicodex
pi install npm:pi-skill-dollar

# pi-context-prune: enable the extension and use the recommended `agent-message`
# prune trigger (batches one prune per user→final-agent-message span, much
# friendlier to provider prompt caching than per-turn pruning). Default is
# enabled=false on first install, so we bootstrap an opt-in config.
mkdir -p "$HOME/.pi/agent/context-prune"
PI_CONTEXT_PRUNE_CONFIG="$HOME/.pi/agent/context-prune/settings.json"
if [ ! -f "$PI_CONTEXT_PRUNE_CONFIG" ]; then
  cat > "$PI_CONTEXT_PRUNE_CONFIG" <<'JSON'
{
  "enabled": true,
  "showPruneStatusLine": true,
  "summarizerModel": "default",
  "summarizerThinking": "default",
  "pruneOn": "agent-message",
  "remindUnprunedCount": true,
  "batchingMode": "turn"
}
JSON
  echo "Wrote $PI_CONTEXT_PRUNE_CONFIG with enabled=true, pruneOn=agent-message"
else
  echo "Preserving existing $PI_CONTEXT_PRUNE_CONFIG (edit manually or via /pruner)"
fi

# pi-vcc: make it handle /compact and auto-threshold compactions (not just /pi-vcc).
# Default is false, which only runs pi-vcc on the explicit /pi-vcc command.
# We override because pi's built-in single-pass summarizer can 400 on large spans.
mkdir -p "$HOME/.pi/agent"
PI_VCC_CONFIG="$HOME/.pi/agent/pi-vcc-config.json"
if [ ! -f "$PI_VCC_CONFIG" ]; then
  cat > "$PI_VCC_CONFIG" <<'JSON'
{
  "overrideDefaultCompaction": true,
  "debug": false
}
JSON
  echo "Wrote $PI_VCC_CONFIG with overrideDefaultCompaction=true"
else
  echo "Preserving existing $PI_VCC_CONFIG (edit manually if needed)"
fi

# My UI
pi install https://github.com/lhl/pi-zentui


# install camoufox
# camoufox-js depends on better-sqlite3 (native addon). Prebuilt binaries may
# not exist for the current Node ABI; rebuild from source so "bindings" can
# locate build/Release/better_sqlite3.node at runtime.
echo "Rebuilding native deps for camoufox-pi (better-sqlite3)..."
(npm root -g | while read -r root; do
  bsdir="$root/@the-forge-flow/camoufox-pi/node_modules/better-sqlite3"
  if [ -d "$bsdir" ]; then
    (cd "$bsdir" && npm run build-release)
    break
  fi
done)
PIP_REQUIRE_HASHES=0 pip install -U camoufox[geoip]
camoufox fetch

echo "Done. Run 'pi' to start."
