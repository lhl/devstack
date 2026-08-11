#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# Ensure pi is available
if ! command -v pi &>/dev/null; then
  install_pi
fi

# Verify installation
pi --version

# Install/sync canonical plugin stack. pi-packages.json is the source of truth;
# --prune removes local/dev/legacy package entries before installing/updating it.
# This includes @vanillagreen/pi-background-tasks@1.6.0 for non-blocking
# shell tasks and output/completion wakeups; it is pinned to the version tested
# with the devstack extension stack while local npm age-gates newer releases.
# pi-web-access is intentionally pruned for now because v0.13.0 imports a
# pi-ai compat path that Pi 0.79.7 no longer exports.
# pi-multicodex is safe to keep alongside codex-pool because it only registers
# its openai-codex override when a usable managed/imported account exists.
"$SCRIPT_DIR/tools/pi-sync.sh" --prune

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

# install camoufox browser binary (Node side)
# camoufox-pi (tff-fetch_url / tff-search_web) runs on the Node camoufox-js port,
# which reads ~/.cache/camoufox/version.json and expects the browser extracted flat
# at the cache root. Do NOT install the Python `camoufox` pip package or run its
# `camoufox fetch` here: it writes the 0.5.x "multiversion" layout
# (browsers/official/<ver>-<sha8>/ + config.json, no version.json) that the Node
# tools cannot read, breaking tff-fetch_url / tff-search_web with "Version
# information not found at ~/.cache/camoufox/version.json". See wiki/tools/camoufox.md.
# The extension lazy-downloads the browser on first tff use; for a deterministic
# setup-time fetch use the Node CLI instead:
#   npx camoufox fetch && chmod -R 755 ~/.cache/camoufox/
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

echo "Done. Run 'pi' to start."
