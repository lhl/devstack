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
# camoufox-js depends on better-sqlite3 (native addon). With npm
# ignore-scripts=true, its install hook is intentionally skipped. Resolve the
# actual dependency from Pi's user package tree (normally ~/.pi/agent/npm), not
# npm's unrelated global root; npm may hoist better-sqlite3 outside camoufox-pi.
PI_AGENT_DIR="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
CAMOUFOX_JS_PACKAGE="$PI_AGENT_DIR/npm/node_modules/camoufox-js/package.json"
if [ ! -f "$CAMOUFOX_JS_PACKAGE" ]; then
  echo "error: camoufox-js was not installed at $CAMOUFOX_JS_PACKAGE" >&2
  exit 1
fi

check_camoufox_sqlite() {
  node - "$CAMOUFOX_JS_PACKAGE" <<'NODE'
const { createRequire } = require("node:module");
const requireFromCamoufox = createRequire(process.argv[2]);
const Database = requireFromCamoufox("better-sqlite3");
const db = new Database(":memory:");
const row = db.prepare("SELECT 1 AS ok").get();
db.close();
if (row.ok !== 1) process.exit(1);
NODE
}

if check_camoufox_sqlite >/dev/null 2>&1; then
  echo "Camoufox native dependency is usable (better-sqlite3)."
else
  BETTER_SQLITE3_DIR="$(node - "$CAMOUFOX_JS_PACKAGE" <<'NODE'
const path = require("node:path");
const { createRequire } = require("node:module");
const requireFromCamoufox = createRequire(process.argv[2]);
process.stdout.write(path.dirname(requireFromCamoufox.resolve("better-sqlite3/package.json")));
NODE
)"
  echo "Rebuilding Camoufox native dependency at $BETTER_SQLITE3_DIR ..."
  (cd "$BETTER_SQLITE3_DIR" && npm run build-release)
  check_camoufox_sqlite
fi

echo "Done. Run 'pi' to start."
