#!/usr/bin/env bash
# pkg-security-setup.sh - apply a minimum-release-age ("cooldown") gate to the
# language package managers on this machine, to blunt drive-by supply-chain
# attacks.
#
# Threat model: most opportunistic malicious publishes are discovered and yanked
# within hours of going up. Refusing to install any release younger than
# MIN_AGE_DAYS catches the bulk of them at install time, with no scanner,
# monitoring, or allowlist to maintain. 1 day is the default (catches drive-bys
# without making fresh legit releases painful); bump to 7 where compatibility
# allows.
#
# Every tool below now supports a ROLLING window via a relative duration, so a
# single static config line is enough -- no cron job and no shell-startup `date`
# math. The window slides forward on its own and is recomputed on each resolve:
#   - npm  >= 11.10.0     : min-release-age      (unit: DAYS)    -> ~/.npmrc
#   - pnpm (via corepack) : minimumReleaseAge    (unit: MINUTES) -> pnpm global config
#   - uv   >= 0.9.17      : exclude-newer "P1D"  (ISO 8601 dur)  -> ~/.config/uv/uv.toml
#   - pip  >= 26.1        : uploaded-prior-to P1D (ISO 8601 dur) -> ~/.config/pip/pip.conf
#
# Idempotent: safe to re-run. Prefers each tool's own `config set` so other
# settings in the same file are preserved.
#
# Escape hatches for when you genuinely need a brand-new release:
#   npm  i --min-release-age 0 <pkg>@<version>
#   pnpm set minimumReleaseAge: 0 in ~/.config/pnpm/config.yaml  # then restore
#   uv   add --exclude-newer-package <pkg>=false <pkg>  # or: UV_EXCLUDE_NEWER= uv ...
#   pip  install --uploaded-prior-to P0D <pkg>
#
# Companion to dev-setup.sh (base shell env) and pi-setup.sh (pi agent stack).
set -euo pipefail

MIN_AGE_DAYS="${MIN_AGE_DAYS:-1}"
MIN_AGE_MINUTES=$(( MIN_AGE_DAYS * 24 * 60 ))
ISO_DUR="P${MIN_AGE_DAYS}D"

# corepack would otherwise prompt before downloading pnpm on first use.
export COREPACK_ENABLE_DOWNLOAD_PROMPT=0

# --- npm -------------------------------------------------------------------
# Native since npm 11.10.0. UNIT IS DAYS (not minutes -- that's pnpm/yarn).
setup_npm() {
  if ! command -v npm >/dev/null 2>&1; then
    echo "npm: not found, skipping"
    return
  fi
  local ver
  ver="$(npm --version 2>/dev/null || echo 0)"
  npm config set min-release-age "$MIN_AGE_DAYS"
  echo "npm $ver: min-release-age=$(npm config get min-release-age) day(s)"
  case "$ver" in
    0.*|1.*|2.*|3.*|4.*|5.*|6.*|7.*|8.*|9.*|10.*|11.0.*|11.1.*|11.2.*|11.3.*|11.4.*|11.5.*|11.6.*|11.7.*|11.8.*|11.9.*)
      echo "npm: WARNING -- min-release-age needs npm >= 11.10.0; this is $ver (key is set but inert)" ;;
  esac
}

# --- pnpm (via corepack) ---------------------------------------------------
# pnpm ships through corepack, which comes with the nvm-managed Node. Enable it
# on demand rather than installing a separate global. UNIT IS MINUTES.
#
# pnpm refuses `config set --global` until `pnpm setup` has wired PNPM_HOME into
# PATH, so write its global config file directly. pnpm >= 11 uses YAML
# (config.yaml); older pnpm uses an ini-style rc/.npmrc. Branch on extension.
# (Do NOT put minimumReleaseAge in ~/.npmrc -- npm warns on the unknown key.)
setup_pnpm() {
  if ! command -v pnpm >/dev/null 2>&1; then
    if command -v corepack >/dev/null 2>&1; then
      echo "pnpm: enabling via corepack ..."
      corepack enable pnpm 2>/dev/null || corepack prepare pnpm@latest --activate
    else
      echo "pnpm: pnpm and corepack both absent, skipping"
      return 0
    fi
  fi
  local cfg
  cfg="$(pnpm config get globalconfig 2>/dev/null || true)"
  if [ -z "$cfg" ] || [ "$cfg" = "undefined" ]; then
    cfg="${XDG_CONFIG_HOME:-$HOME/.config}/pnpm/config.yaml"
  fi
  mkdir -p "$(dirname "$cfg")"
  touch "$cfg"
  case "$cfg" in
    *.yaml|*.yml)
      if grep -qE '^minimumReleaseAge:' "$cfg"; then
        sed -i -E "s|^minimumReleaseAge:.*|minimumReleaseAge: $MIN_AGE_MINUTES|" "$cfg"
      else
        printf 'minimumReleaseAge: %s\n' "$MIN_AGE_MINUTES" >> "$cfg"
      fi ;;
    *)
      if grep -qE '^minimumReleaseAge=' "$cfg"; then
        sed -i -E "s|^minimumReleaseAge=.*|minimumReleaseAge=$MIN_AGE_MINUTES|" "$cfg"
      else
        printf 'minimumReleaseAge=%s\n' "$MIN_AGE_MINUTES" >> "$cfg"
      fi ;;
  esac
  echo "pnpm $(pnpm --version): minimumReleaseAge=$(pnpm config get minimumReleaseAge) min (${MIN_AGE_DAYS}d) [$cfg]"
}

# --- uv --------------------------------------------------------------------
# uv has no `config set`, so manage the one line in uv.toml. A relative duration
# (ISO 8601) makes it a rolling window, recomputed on each resolve (uv >=0.9.17).
setup_uv() {
  if ! command -v uv >/dev/null 2>&1; then
    echo "uv: not found, skipping"
    return
  fi
  local cfg="${XDG_CONFIG_HOME:-$HOME/.config}/uv/uv.toml"
  mkdir -p "$(dirname "$cfg")"
  touch "$cfg"
  if grep -qE '^[[:space:]]*exclude-newer[[:space:]]*=' "$cfg"; then
    sed -i -E "s|^[[:space:]]*exclude-newer[[:space:]]*=.*|exclude-newer = \"$ISO_DUR\"|" "$cfg"
  else
    printf '# minimum-release-age gate (managed by pkg-security-setup.sh)\nexclude-newer = "%s"\n' "$ISO_DUR" >> "$cfg"
  fi
  echo "uv $(uv --version | awk '{print $2}'): exclude-newer=\"$ISO_DUR\" ($cfg)"
}

# --- pip -------------------------------------------------------------------
# uploaded-prior-to accepts an ISO 8601 duration (e.g. P1D) since pip 26.1.
# pip config set preserves any other keys already in pip.conf.
setup_pip() {
  if ! command -v pip >/dev/null 2>&1; then
    echo "pip: not found, skipping"
    return
  fi
  pip config set --user install.uploaded-prior-to "$ISO_DUR" >/dev/null
  echo "pip $(pip --version | awk '{print $2}'): install.uploaded-prior-to=$(pip config get install.uploaded-prior-to 2>/dev/null)"
}

echo "== pkg-security-setup: gating releases younger than ${MIN_AGE_DAYS} day(s) =="
# One tool failing (missing, version too old) should not block the others.
for fn in setup_npm setup_pnpm setup_uv setup_pip; do
  "$fn" || echo "$fn: failed (continuing)"
done

cat <<DONE

Done. A rolling ${MIN_AGE_DAYS}-day cooldown is active for npm, pnpm, uv, and pip.
Need a brand-new release once? Use the per-tool escape hatch (see header comment).
DONE
