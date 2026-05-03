#!/usr/bin/env bash
set -e

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

# Ensure pi is available
if ! command -v pi &>/dev/null; then
  install_pi
fi

# Verify installation
pi --version

# Install plugin stack
PI_MULTILOOP_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../github/lhl/pi-multiloop" && pwd)"

echo "Installing plugin stack..."

pi install npm:pi-rtk-optimizer
pi install npm:pi-schedule-prompt
pi install npm:pi-boomerang
pi install npm:pi-web-access
pi install npm:pi-smart-fetch
pi install npm:@the-forge-flow/camoufox-pi@0.2.1
pi install "$PI_MULTILOOP_PATH"

echo "Done. Run 'pi' to start."