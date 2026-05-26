#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# Install/sync canonical plugin stack. pi-packages.json is the source of truth;
# --prune removes local/dev/legacy package entries before installing/updating it.
"$SCRIPT_DIR/tools/pi-sync.sh" --prune

# Apply temporary npm security overrides for pi-managed extension deps. Pi owns
# ~/.pi/agent/npm/package.json, so reapply after sync/update until upstream
# packages relax their dependency ranges.
PI_AGENT_DIR="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
PI_NPM_DIR="$PI_AGENT_DIR/npm"
if [ -f "$PI_NPM_DIR/package.json" ]; then
  echo "Applying npm audit overrides for pi extensions..."
  (
    cd "$PI_NPM_DIR"
    npm pkg set \
      "overrides.@mozilla/readability=0.6.0" \
      "overrides.gaxios.uuid=11.1.1"
    npm install --omit=dev
  )
else
  echo "Skipping npm audit overrides; $PI_NPM_DIR/package.json not found"
fi

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

# pi-continue-after-compaction: after auto-threshold compaction only, wait for
# the next turn to start; if none starts, send an extension-originated
# "continue". Manual /compact and /pi-vcc stay manual.
PI_CONTINUE_AFTER_COMPACTION_CONFIG="$HOME/.pi/agent/continue-after-compaction.json"
if [ ! -f "$PI_CONTINUE_AFTER_COMPACTION_CONFIG" ]; then
  cat > "$PI_CONTINUE_AFTER_COMPACTION_CONFIG" <<'JSON'
{
  "enabled": true,
  "delayMs": 1500,
  "prompt": "continue",
  "requirePiVcc": false,
  "debug": false
}
JSON
  echo "Wrote $PI_CONTINUE_AFTER_COMPACTION_CONFIG with auto-threshold continue enabled"
else
  echo "Preserving existing $PI_CONTINUE_AFTER_COMPACTION_CONFIG (edit manually if needed)"
fi

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
