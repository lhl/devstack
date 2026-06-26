#!/usr/bin/env bash
# dev-setup.sh - install my base shell/dev environment.
#
# Installs and wires up (idempotent, safe to re-run):
#   - starship   cross-shell prompt          -> ~/.local/bin/starship
#   - atuin      shell history (sqlite/sync)  -> ~/.atuin/bin/atuin (+ bash-preexec)
#   - Miniforge  conda + mamba (conda-forge)  -> ~/miniforge3, base auto-activates
#                base env gets pip + uv so they are always on PATH
#
# Shell wiring is written to ~/.bashrc as guarded blocks delimited by
# `# >>> NAME >>>` / `# <<< NAME <<<` markers, so re-running replaces the block
# in place instead of appending duplicates.
#
# This is the dev-environment counterpart to pi-setup.sh (the pi agent stack).
set -euo pipefail

BASHRC="$HOME/.bashrc"
ARCH="$(uname -m)"
OS="$(uname -s)"

# --- guarded-block helper --------------------------------------------------
# upsert_block NAME <<'EOF' ... EOF
# Replaces the region between the NAME markers in ~/.bashrc, or appends it.
upsert_block() {
  local name="$1"
  local begin="# >>> ${name} >>>"
  local end="# <<< ${name} <<<"
  local body
  body="$(cat)"
  touch "$BASHRC"
  if grep -qF "$begin" "$BASHRC"; then
    # Replace existing block (delete old region, then re-insert below).
    local tmp
    tmp="$(mktemp)"
    awk -v b="$begin" -v e="$end" '
      $0==b {skip=1}
      skip==0 {print}
      $0==e {skip=0}
    ' "$BASHRC" > "$tmp"
    mv "$tmp" "$BASHRC"
  fi
  {
    printf '\n%s\n' "$begin"
    printf '%s\n' "$body"
    printf '%s\n' "$end"
  } >> "$BASHRC"
  echo "  wired ~/.bashrc block: ${name}"
}

# ---------------------------------------------------------------------------
# starship
# ---------------------------------------------------------------------------
install_starship() {
  if command -v starship &>/dev/null; then
    echo "starship already installed: $(starship --version | head -1)"
  else
    echo "Installing starship -> ~/.local/bin ..."
    mkdir -p "$HOME/.local/bin"
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
  fi
  upsert_block "starship" <<'EOF'
export PATH="$HOME/.local/bin:$PATH"
command -v starship >/dev/null && eval "$(starship init bash)"
EOF
}

# ---------------------------------------------------------------------------
# atuin (needs bash-preexec under bash)
# ---------------------------------------------------------------------------
install_atuin() {
  if command -v atuin &>/dev/null || [ -x "$HOME/.atuin/bin/atuin" ]; then
    echo "atuin already installed."
  else
    echo "Installing atuin ..."
    # --no-modify-path: we manage shell wiring ourselves via the guarded block.
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh -s -- --no-modify-path
  fi
  # bash-preexec is required for atuin's bash integration (preexec/precmd hooks).
  if [ ! -f "$HOME/.bash-preexec.sh" ]; then
    echo "Installing bash-preexec ..."
    curl -fsSL https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh \
      -o "$HOME/.bash-preexec.sh"
  fi
  upsert_block "atuin" <<'EOF'
[ -s "$HOME/.atuin/bin/env" ] && . "$HOME/.atuin/bin/env"
[ -f "$HOME/.bash-preexec.sh" ] && . "$HOME/.bash-preexec.sh"
command -v atuin >/dev/null && eval "$(atuin init bash)"
EOF
}

# ---------------------------------------------------------------------------
# Miniforge (conda + mamba), base auto-activates, base has pip + uv
# ---------------------------------------------------------------------------
install_miniforge() {
  local prefix="$HOME/miniforge3"
  if [ -x "$prefix/bin/conda" ]; then
    echo "Miniforge already installed at $prefix"
  else
    local installer="Miniforge3-${OS}-${ARCH}.sh"
    local url="https://github.com/conda-forge/miniforge/releases/latest/download/${installer}"
    echo "Installing Miniforge ($installer) -> $prefix ..."
    local tmp
    tmp="$(mktemp -d)"
    curl -fsSL "$url" -o "$tmp/$installer"
    bash "$tmp/$installer" -b -p "$prefix"
    rm -rf "$tmp"
  fi

  # Keep base auto-activating so pip/uv/python are always on PATH.
  "$prefix/bin/conda" config --set auto_activate_base true

  # Ensure uv is in the base env (pip ships with base already).
  if ! "$prefix/bin/python" -m uv --version &>/dev/null && [ ! -x "$prefix/bin/uv" ]; then
    echo "Installing uv into base env ..."
    "$prefix/bin/mamba" install -n base -y -c conda-forge uv
  fi

  # Standard conda init block, written under our marker so re-runs are clean.
  # MAMBA_ROOT_PREFIX is exported so mamba.sh doesn't warn / guess the prefix.
  upsert_block "conda-miniforge" <<EOF
export MAMBA_ROOT_PREFIX="$prefix"
__conda_setup="\$('$prefix/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ \$? -eq 0 ]; then
    eval "\$__conda_setup"
else
    if [ -f "$prefix/etc/profile.d/conda.sh" ]; then
        . "$prefix/etc/profile.d/conda.sh"
    else
        export PATH="$prefix/bin:\$PATH"
    fi
fi
unset __conda_setup
if [ -f "$prefix/etc/profile.d/mamba.sh" ]; then
    . "$prefix/etc/profile.d/mamba.sh"
fi
EOF
}

echo "== dev-setup: starship =="
install_starship
echo "== dev-setup: atuin =="
install_atuin
echo "== dev-setup: miniforge (conda + mamba) =="
install_miniforge

cat <<'DONE'

Done. Open a new shell (or `source ~/.bashrc`) to load:
  - starship prompt
  - atuin history  (Ctrl-R / up-arrow)
  - conda/mamba    (base auto-activated; pip + uv available)
DONE
