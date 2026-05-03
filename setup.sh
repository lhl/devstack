#!/usr/bin/env bash
set -e

# Install rtk (token-optimizing CLI proxy; pairs with pi-rtk-optimizer below)
install_rtk() {
  echo "Installing rtk..."
  curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
}

# Install pi-coding-agent
install_pi() {
  if command -v npm &>/dev/null; then
    echo "Installing pi via npm..."
    npm install -g @mariozechner/pi-coding-agent
  else
    echo "npm not found. Installing via curl..."
    local tmp_dir
    tmp_dir=$(mktemp -d)
    curl -fsSL https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/install.sh \
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
pi install npm:pi-rtk-optimizer
pi install npm:pi-schedule-prompt
pi install npm:pi-boomerang
pi install npm:pi-web-access
pi install npm:pi-smart-fetch
pi install npm:@the-forge-flow/camoufox-pi@0.2.1
pi install npm:pi-continue
pi install npm:pi-code-previews
pi install npm:pi-multiloop

# Pre-fetch the Camoufox browser binary (~500 MB) so the camoufox-pi extension
# doesn't probe-and-warn on first pi launch.
camoufox_bin="$(npm root -g)/@the-forge-flow/camoufox-pi/node_modules/.bin/camoufox-js"
if [ -x "$camoufox_bin" ]; then
  echo "Fetching Camoufox browser binary..."
  "$camoufox_bin" fetch
fi

echo "Done. Run 'pi' to start."