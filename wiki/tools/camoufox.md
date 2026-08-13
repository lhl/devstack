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

## Gotcha 1: two packages, one shared cache, two different layouts

There are **two** Camoufox packages that matter, and both default to the **same cache directory** `~/.cache/camoufox` while expecting **different on-disk layouts**:

| Package | Used by | Runtime | Expected `~/.cache/camoufox` layout |
| --- | --- | --- | --- |
| `camoufox-js` (npm) | `@the-forge-flow/camoufox-pi` — the actual tff tools | Node | **Flat**: browser extracted at the root + `version.json` = `{"version":"…","release":"…"}` |
| `camoufox` (pip) | nothing in this stack (formerly installed by `pi-setup.sh`) | Python | **Multiversion** (0.5.x): browser under `browsers/official/<version>-<sha8>/`, plus `config.json` (→ `active_version`), `repo_cache.json`, `.0.5_FLAG` — **no top-level `version.json`** |

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

## Gotcha 2: missing `better-sqlite3` native binding

After fixing the browser layout, the tff tools can fail with a different launch error:

```
browser_launch_failed: {"type":"browser_launch_failed",
  "stderr":"Could not locate the bindings file. Tried: …/better_sqlite3.node …"}
```

`camoufox-js` uses `better-sqlite3` while generating launch options for WebGL fingerprint sampling. On this machine, `~/.npmrc` has `ignore-scripts=true`, so npm intentionally skipped `better-sqlite3`'s native install/build hook. The package's JavaScript was present, but no ABI-specific `better_sqlite3.node` existed for Node `24.16.0`.

The old `pi-setup.sh` tried to compensate, but searched under:

```
$(npm root -g)/@the-forge-flow/camoufox-pi/node_modules/better-sqlite3
```

That path was wrong twice: Pi user npm packages live under `~/.pi/agent/npm/`, not npm's global root, and npm hoisted this dependency to `~/.pi/agent/npm/node_modules/better-sqlite3`. The loop found nothing and silently skipped the repair.

The corrected setup resolves `better-sqlite3/package.json` with `createRequire()` from Pi's installed `camoufox-js/package.json`, builds only when an in-memory SQLite probe fails, and probes again after the build. This survives npm hoisting and respects `PI_CODING_AGENT_DIR`.

## Gotcha 3: `playwright-core` must be pinned `< 1.61.0`

Even with the browser cache and native binding correct, the tff tools can fail at **context creation** with a protocol-schema error:

```
browser_launch_failed: {"type":"browser_launch_failed",
  "stderr":"browser.newContext: Protocol error (Browser.setDefaultViewport): ERROR: …
  Found property \"<root>.viewport.isMobile\" - false which is not described in this scheme"}
```

**Root cause:** `camoufox-pi`/`camoufox-js` require `playwright-core < 1.61.0`. Starting in Playwright **1.61**, the client adds an `isMobile` field to the viewport object sent in `Browser.setDefaultViewport`, but the Camoufox Juggler protocol's `pageTypes.Viewport` schema only knows `viewportSize`/`deviceScaleFactor`. When the Pi user package tree resolves a too-new `playwright-core` (e.g. `1.62.1`), the launch call is rejected. This is an upstream incompatibility (see [daijro/camoufox#653](https://github.com/daijro/camoufox/issues/653)); the current `camoufox-js` declares `playwright-core: <1.61.0` as its peer constraint.

**Fix (what we did):** pin `playwright-core@1.60.0` as a **direct dependency** of the Pi user manifest and reinstall:

```bash
PI_NPM=~/.pi/agent/npm
node - "$PI_NPM/package.json" <<'NODE'
const fs = require('fs');
const p = process.argv[2];
const pkg = JSON.parse(fs.readFileSync(p, 'utf8'));
pkg.dependencies = pkg.dependencies || {};
pkg.dependencies['playwright-core'] = '1.60.0';
fs.writeFileSync(p, JSON.stringify(pkg, null, 2) + '\n');
NODE
(cd "$PI_NPM" && npm install --legacy-peer-deps)
```

This must be a **direct dependency**, not an npm `overrides` entry. `overrides` nests `playwright-core@1.60.0` under `camoufox-pi` only and removes the top-level package, leaving `camoufox-js` (a sibling dependency) without a resolvable peer and breaking the launch with `ERR_MODULE_NOT_FOUND: Cannot find package 'playwright-core' imported from camoufox-js/dist/server.js`. A hoisted direct dependency makes one shared `playwright-core@1.60.0` resolve from **both** `camoufox-js` and `camoufox-pi` (`npm ls playwright-core` shows `deduped` under both). `pi-setup.sh` now performs this pin and reinstall automatically and verifies the resolved version with `createRequire` from the installed `camoufox-js`.

**Detection:**
```bash
# from the installed camoufox-js package — must be 1.60.x / <1.61.0
node - ~/.pi/agent/npm/node_modules/camoufox-js/package.json <<'NODE'
const { createRequire } = require('node:module');
const r = createRequire(process.argv[2]);
console.log(r('playwright-core/package.json').version);
NODE
npm ls playwright-core --prefix ~/.pi/agent/npm
```

## Former cache-layout root cause in this repo

Before commit `cd9a9ab`, `pi-setup.sh` installed the **Python** package and fetched with the **Python** CLI:

```bash
PIP_REQUIRE_HASHES=0 pip install -U camoufox[geoip]
camoufox fetch          # ← Python CLI → writes the multiversion layout
```

but the extension runs on the **Node** port, which needs the flat layout. (The README correctly says the extension wants `npx camoufox fetch` — the Node CLI — so the setup script and README disagree.)

## What we did (2026-08-11) — current state

Both failure layers are now repaired. The browser-cache repair **reused** the already-downloaded browser instead of re-downloading ~660 MB (disk was 97% full):

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
4. Verified through the exact extension launch path (`camoufox-js launchOptions` + `playwright-core firefox.launch`): fetched `https://example.com` → `Example Domain`. That operation recorded `installed version: 152.0.4-beta.28`.
5. Rebuilt `better-sqlite3@12.10.1` at the path actually resolved by `camoufox-js@0.9.3`, then fixed `pi-setup.sh` so future runs probe and repair the Pi-managed dependency instead of searching npm's global tree.
6. Verified a fresh `@the-forge-flow/camoufox-pi` client end to end: `fetchUrl("https://example.com")` returned HTTP 200 and `Example Domain`; `checkHealth({ probe: true })` reported `ready`, connected, and a successful page round trip. The cache currently reports browser `135.0.1-beta.24`; why it differs from the browser version recorded by the earlier cache migration was not investigated.

The already-loaded extension instance still retains its earlier failed-launch state. Run `/reload` before using the tff tools in this session.

## What we did (2026-08-12) — playwright-core pin

A third failure layer surfaced after the cache + native-binding repairs: `tff-*` failed at **context creation** with the Gotcha 3 `isMobile … not described in this scheme` error because the Pi user package tree had resolved `playwright-core@1.62.1`. Fixed by pinning `playwright-core@1.60.0` as a **direct dependency** of `~/.pi/agent/npm/package.json` and running `npm install --legacy-peer-deps`. Verified `npm ls playwright-core` shows a single hoisted `1.60.0` `deduped` under both `camoufox-js` and `camoufox-pi`, and a real launch through `camoufox-js launchOptions` + `firefox.launch`/`newContext`/`newPage` succeeded on Camoufox `152.0.4-beta.28`. `pi-setup.sh` now performs this pin + reinstall and verifies the resolved version automatically.

## Ways to fix (reference)

- **A — Reuse existing browser (what we did).** Relocate `browsers/official/<ver>-<sha8>/*` to the cache root, write `version.json`, chmod, uninstall pip. No re-download. Only works if the installed build is within the Node-supported range `[beta.19, 1)`.
- **B — Clean Node install.** `npx camoufox fetch` (the Node CLI, bin = `dist/__main__.js` inside `camoufox-js`). This `rm`s the cache and extracts the browser into the flat layout + writes `version.json`. ~660 MB download.
- **C — Let the Node lazy download run.** `rm -rf ~/.cache/camoufox`, then the next `tff-*` call triggers the package's built-in "lazy binary download on first use". Same ~660 MB download.
- **D — Long-term browser fix (applied in `cd9a9ab`).** Drop the `pip install -U camoufox[geoip]` + `camoufox fetch` lines (they fetch in the wrong layout). The extension itself already handles the browser via Node; if a setup-time fetch is wanted it must be the **Node** one (`npx camoufox fetch`).
- **E — Native binding fix (applied in `6b7cfdf`).** Resolve `better-sqlite3` from Pi's installed `camoufox-js` package, not `npm root -g`; run its explicit `npm run build-release` when a live in-memory probe fails. This is required when npm lifecycle scripts are disabled or after a Node Application Binary Interface (ABI) change invalidates an older build.
- **F — playwright-core pin (applied 2026-08-12).** Pin `playwright-core@1.60.0` as a **direct dependency** of `~/.pi/agent/npm/package.json`, then `npm install --legacy-peer-deps`. Do **not** use an npm `overrides` entry (nests under `camoufox-pi` only, breaks `camoufox-js` resolution). Required while `camoufox-js`/`camoufox-pi` target `playwright-core < 1.61.0`; see Gotcha 3.

## Prevention / detection

- Do **not** run the **Python** `camoufox fetch` for this stack — it poisons the shared cache into a layout the Node tools cannot read. Python and Node Camoufox cannot cleanly coexist on the same `~/.cache/camoufox`.
- Quick browser health check:
  ```bash
  ls ~/.cache/camoufox/version.json            # must exist for tff tools
  node -e "import('/home/lhl/.pi/agent/npm/node_modules/camoufox-js/dist/pkgman.js').then(m => console.log(m.installedVerStr()))"
  ```
- Native dependency health check: run `./pi-setup.sh`; it opens an in-memory `better-sqlite3` database and rebuilds the binding only if that probe fails.
- playwright-core version check: run `./pi-setup.sh` (pins/verifies automatically) or `npm ls playwright-core --prefix ~/.pi/agent/npm` — must resolve `< 1.61.0` from both `camoufox-js` and `camoufox-pi`.
- After a fresh `camoufox fetch`: `chmod -R 755 ~/.cache/camoufox/` (binary-permissions prompt issue, see prior 2026-05-03 wiki log entry).
- After repairing either the browser cache or native binding, run `/reload`; `camoufox-pi` caches failed launch state for the lifetime of the loaded extension instance.

## Related

- Sibling extension: `lightpanda-pi` (fast/light, cooperative targets) — see Web Access section in `README.md`.
- `pi-smart-fetch` handles non-stealth bot-defended pages via TLS fingerprinting + Defuddle; Camoufox is the heavier C++-level option.
