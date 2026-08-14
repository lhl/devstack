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
# Headless Firefox still loads GTK/X11/ALSA runtime libraries. Ubuntu 24.04:
#   sudo apt-get install -y --no-install-recommends \
#     libgtk-3-0t64 libx11-xcb1 libasound2t64
# Older Debian/Ubuntu releases use libgtk-3-0 and libasound2. This script does
# not run privileged distro-specific package-manager commands automatically;
# see wiki/tools/camoufox.md for detection and permanent follow-up work.
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

# Pin playwright-core to <1.61.0 for camoufox compatibility.
#
# camoufox-pi (via camoufox-js) requires playwright-core < 1.61.0. Starting in
# Playwright 1.61, the client adds an `isMobile` field to the viewport sent in
# Browser.setDefaultViewport; the Camoufox Juggler protocol's Viewport schema only
# knows viewportSize/deviceScaleFactor, so a too-new playwright-core fails with:
#   browser_launch_failed: ... "Found property \".viewport.isMobile\" - false
#   which is not described in this scheme"
# Pin it as a DIRECT dependency of the Pi user package.json so npm hoists a single
# shared playwright-core@1.60.0 that BOTH camoufox-js and camoufox-pi resolve.
# (An npm `overrides` entry does NOT work here: it nests playwright-core under
# camoufox-pi only, leaving camoufox-js without a resolvable peer and breaking the
# launch with ERR_MODULE_NOT_FOUND.)
PI_USER_PKG="$PI_AGENT_DIR/npm/package.json"
ensure_playwright_pin() {
  if [ ! -f "$PI_USER_PKG" ]; then
    echo "error: Pi user package manifest not found at $PI_USER_PKG" >&2
    exit 1
  fi
  node - "$PI_USER_PKG" <<'NODE'
const fs = require('fs');
const path = process.argv[2];
const pkg = JSON.parse(fs.readFileSync(path, 'utf8'));
pkg.dependencies = pkg.dependencies || {};
const prev = pkg.dependencies['playwright-core'];
pkg.dependencies['playwright-core'] = '1.60.0';
fs.writeFileSync(path, JSON.stringify(pkg, null, 2) + '\n');
if (prev !== '1.60.0') {
  console.log('Pinned playwright-core in ' + path + ': ' + (prev || '(absent)') + ' -> 1.60.0');
}
NODE
  (cd "$PI_AGENT_DIR/npm" && npm install --legacy-peer-deps >/dev/null 2>&1 || npm install --legacy-peer-deps)
}
ensure_playwright_pin

check_playwright_version() {
  node - "$CAMOUFOX_JS_PACKAGE" <<'NODE'
const { createRequire } = require('node:module');
const requireFromCamoufox = createRequire(process.argv[2]);
const v = requireFromCamoufox('playwright-core/package.json').version;
console.log('camoufox-js resolves playwright-core ' + v);
if (!(v.startsWith('1.60.') || v < '1.61.0')) {
  console.error('error: camoufox-js resolves playwright-core ' + v + ' but needs <1.61.0');
  process.exit(1);
}
NODE
}
check_playwright_version

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
