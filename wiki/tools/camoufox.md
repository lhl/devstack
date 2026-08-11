---
title: Camoufox (camoufox-pi / tff tools)
tags: [tools, web-access, stealth-browser, pi-extensions, camoufox, operations]
sources: []
links:
  - https://github.com/daijro/camoufox
  - https://github.com/apify/camoufox-js
  - https://github.com/MonsieurBarti/camoufox-pi
  - https://github.com/daijro/camoufox/releases
---

# Camoufox

Camoufox is a Firefox fork patched at the C++ level for anti-fingerprinting resistance (Cloudflare / DataDome / PerimeterX / Turnstile / Google bot walls). In this devstack it backs the canonical **`@the-forge-flow/camoufox-pi`** extension (pinned `v0.2.1`), which exposes the `tff-fetch_url` and `tff-search_web` tools.

## The core gotcha: two packages, one shared cache, two different layouts

There are **two** Camoufox packages that matter, and both default to the **same cache directory** `~/.cache/camoufox` while expecting **different on-disk layouts**:

| Package | Used by | Runtime | Expected `~/.cache/camoufox` layout |
| --- | --- | --- | --- |
| `camoufox-js` (npm) | `@the-forge-flow/camoufox-pi` — the actual tff tools | Node | **Flat**: browser extracted at the root + `version.json` = `{"version":"…","release":"…"}` |
| `camoufox` (pip) | nothing in this stack (installed by `pi-setup.sh`) | Python | **Multiversion** (0.5.x): browser under `browsers/official/<version>-<sha8>/`, plus `config.json` (→ `active_version`), `repo_cache.json`, `.0.5_FLAG` — **no top-level `version.json`** |

Node `camoufox-js`:
- `INSTALL_DIR = ~/.cache/camoufox` (`userCacheDir("camoufox")`)
- validates the install by reading `~/.cache/camoufox/version.json` (fields `version`, `release`)
- supported range is `[beta.19, 1)` — `152.0.4-beta.28` qualifies
- Linux launch binary: `~/.cache/camoufox/camoufox-bin`
- `launchOptions()` → `camoufoxPath()` → `Version.fromPath()` → if `version.json` is missing it throws

## Failure symptom

`tff-search_web` / `tff-fetch_url` fail on first call:

```
browser_launch_failed: {"type":"browser_launch_failed",
  "stderr":"Version information not found at <redacted>
  Please run `camoufox fetch` to install."}
```

Why it happens even when a browser IS installed: `camoufoxPath()` sees a **non-empty** cache dir (Python's multiversion layout), takes its "exists → validate version" branch, `Version.fromPath()` can't find `~/.cache/camoufox/version.json`, and throws synchronously — the lazy auto-download branch never runs.

## Root cause in this repo

`pi-setup.sh` installs the **Python** package and fetches with the **Python** CLI:

```bash
PIP_REQUIRE_HASHES=0 pip install -U camoufox[geoip]
camoufox fetch          # ← Python CLI → writes the multiversion layout
```

but the extension runs on the **Node** port, which needs the flat layout. (The README correctly says the extension wants `npx camoufox fetch` — the Node CLI — so the setup script and README disagree.)

## What we did (2026-08-11) — current state

The machine is now fixed by **reusing** the already-downloaded browser instead of re-downloading ~660 MB (disk was 97% full):

1. Migrated the browser to the Node flat layout:
   ```bash
   CACHE=~/.cache/camoufox
   mv "$CACHE/browsers/official/152.0.4-beta.28-924f3109"/* "$CACHE"/
   printf '{"version":"152.0.4","release":"beta.28"}\n' > "$CACHE/version.json"
   chmod -R 755 "$CACHE"
   ```
2. Removed Python-specific metadata + redundant copies: `config.json`, `.0.5_FLAG`, `repo_cache.json`, and the whole `browsers/` tree (incl. stale `beta.27`, freeing ~1.3 GB).
3. Uninstalled the pip package (nothing depended on it; `Required-by:` was empty):
   ```bash
   python -m pip uninstall -y camoufox
   rm -rf ~/mambaforge/lib/python3.12/site-packages/camoufox   # leftover 66 MB GeoLite2-City.mmdb
   ```
4. Verified through the exact extension launch path (`camoufox-js launchOptions` + `playwright-core firefox.launch`): fetched `https://example.com` → `Example Domain`. Node reports `installed version: 152.0.4-beta.28`.

## Ways to fix (reference)

- **A — Reuse existing browser (what we did).** Relocate `browsers/official/<ver>-<sha8>/*` to the cache root, write `version.json`, chmod, uninstall pip. No re-download. Only works if the installed build is within the Node-supported range `[beta.19, 1)`.
- **B — Clean Node install.** `npx camoufox fetch` (the Node CLI, bin = `dist/__main__.js` inside `camoufox-js`). This `rm`s the cache and extracts the browser into the flat layout + writes `version.json`. ~660 MB download.
- **C — Let the Node lazy download run.** `rm -rf ~/.cache/camoufox`, then the next `tff-*` call triggers the package's built-in "lazy binary download on first use". Same ~660 MB download.
- **D — Long-term (recommended): fix `pi-setup.sh`.** Drop the `pip install -U camoufox[geoip]` + `camoufox fetch` lines (they fetch in the wrong layout). The extension itself already handles the browser via Node; if a setup-time fetch is wanted it must be the **Node** one (`npx camoufox fetch`).

## Prevention / detection

- Do **not** run the **Python** `camoufox fetch` for this stack — it poisons the shared cache into a layout the Node tools cannot read. Python and Node Camoufox cannot cleanly coexist on the same `~/.cache/camoufox`.
- Quick health check:
  ```bash
  ls ~/.cache/camoufox/version.json            # must exist for tff tools
  node -e "import('/home/lhl/.pi/agent/npm/node_modules/camoufox-js/dist/pkgman.js').then(m => console.log(m.installedVerStr()))"
  ```
- After any fresh `camoufox fetch`: `chmod -R 755 ~/.cache/camoufox/` (binary-permissions prompt issue, see prior 2026-05-03 wiki log entry) and reload the pi session so the extension doesn't serve a cached failed-launch state.

## Related

- Sibling extension: `lightpanda-pi` (fast/light, cooperative targets) — see Web Access section in `README.md`.
- `pi-smart-fetch` handles non-stealth bot-defended pages via TLS fingerprinting + Defuddle; Camoufox is the heavier C++-level option.
