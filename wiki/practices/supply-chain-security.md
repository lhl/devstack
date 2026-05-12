---
title: Supply Chain Security
tags: [security, supply-chain, python, javascript, ci, package-management]
sources: []
links:
  - https://socket.dev/blog/tanstack-npm-packages-compromised-mini-shai-hulud-supply-chain-attack
  - https://socket.dev/supply-chain-attacks/mini-shai-hulud
  - https://docs.astral.sh/uv/reference/environment/
  - https://docs.astral.sh/uv/reference/settings/
  - https://pip.pypa.io/en/stable/topics/secure-installs/
  - https://pip.pypa.io/en/stable/user_guide/
  - https://pnpm.io/supply-chain-security
  - https://docs.npmjs.com/cli/v11/using-npm/config
  - https://docs.npmjs.com/verifying-registry-signatures/
  - https://docs.npmjs.com/trusted-publishers/
  - https://docs.github.com/actions/using-workflows/workflow-syntax-for-github-actions
  - https://docs.github.com/en/code-security/concepts/secret-security/about-push-protection
  - https://slsa.dev/
---

# Supply Chain Security

Practical defaults for defending developer workstations and CI from package supply-chain attacks. This page records our current Python shell defaults plus a broader checklist for npm, pnpm, Bun, GitHub Actions, and incident response.

Related: [[practices/ml-workflow-tips]] for the broader mamba + uv + fish environment pattern.

## Current local defaults: fish wrappers for uv and pip

On 2026-05-12 we made `uv` and `pip` secure-by-default in fish by adding wrapper functions instead of static global environment variables. The wrappers recompute the freshness cutoff on every invocation, so long-lived shells do not keep a stale date.

Files installed:

- `~/.config/fish/functions/uv.fish`
- `~/.config/fish/functions/pip.fish`
- `~/.config/fish/functions/uv-unsafe.fish`
- `~/.config/fish/functions/pip-unsafe.fish`

Behavior:

```fish
# uv wrapper
set -lx UV_EXCLUDE_NEWER (date -u -d '1 day ago' +%Y-%m-%dT00:00:00Z)
set -lx UV_NO_BUILD 1
command uv $argv

# pip wrapper
set -lx PIP_ONLY_BINARY :all:
set -lx PIP_UPLOADED_PRIOR_TO (date -u -d '1 day ago' +%Y-%m-%dT00:00:00Z)
command pip $argv
```

Escape hatches:

```fish
uv-unsafe  ...   # real uv, no age gate, sdists allowed
pip-unsafe ...   # real pip, no age gate, sdists allowed
```

Why wrappers instead of only `config.fish`:

- The 1-day age gate is aimed at drive-by malicious publishes that are discovered and yanked within hours.
- Recomputing on every call is more accurate than setting a static date at shell startup.
- The `*-unsafe` commands make the bypass explicit and narrow when a package is sdist-only or genuinely needs a fresh release.

Simpler alternative documented in the function comments: put the same settings in `~/.config/fish/config.fish` with `set -gx`. That is simpler, but the date is frozen at shell startup and the opt-out is less obvious.

Current version caveat: local `uv` is `0.6.9`, which supports `UV_NO_BUILD`. Local `pip` observed during setup was `25.0.1`; `PIP_UPLOADED_PRIOR_TO` is intended for pip 26.0+ and was observed to be ignored by pip 25.0.1, so it is safe to set now and should activate after upgrade.

## Minimum individual settings

### Python: uv

Interactive/default:

```bash
export UV_EXCLUDE_NEWER=$(date -d '1 day ago' -u +%Y-%m-%dT00:00:00Z)
export UV_NO_BUILD=1
```

CI/project reproducibility:

```bash
uv lock --check
uv sync --frozen
```

Rules:

- Commit `uv.lock`.
- Use `UV_EXCLUDE_NEWER` / `--exclude-newer` to block very recent releases.
- Use `UV_NO_BUILD=1` / `--no-build` to refuse source distribution builds.
- Do not set `UV_FROZEN=1` globally for interactive dev; it breaks normal `uv add` / lockfile update flows. Enforce frozen mode in CI.

### Python: pip

Strict CI install from a fully-hashed requirements file:

```bash
pip install \
  --require-hashes \
  --only-binary :all: \
  --uploaded-prior-to $(date -d '1 day ago' -u +%Y-%m-%dT00:00:00Z) \
  -r requirements.txt
```

Rules:

- Pin every dependency with `==`.
- Generate pinned+hashed requirements with `uv pip compile --generate-hashes`.
- `--require-hashes` is excellent in CI, but do not make `PIP_REQUIRE_HASHES=1` a global interactive default; it breaks ad-hoc `pip install <package>` unless every transitive requirement has a hash.
- `--only-binary :all:` blocks source builds and therefore blocks install-time arbitrary code from `setup.py` / PEP 517 build hooks.
- `--uploaded-prior-to` is a pip 26.0+ age gate. It accepts an absolute date, so wrappers/CI should compute it dynamically.
- Avoid `--extra-index-url` for private packages because it creates dependency-confusion risk. Prefer one `--index-url` or uv's default first-index behavior.

### npm

`~/.npmrc` or project `.npmrc`:

```ini
min-release-age=1440   # 1 day in minutes; use 10080 for 7 days
ignore-scripts=true
save-exact=true
```

Rules:

- Use `npm ci` in CI, not `npm install`.
- Commit `package-lock.json`.
- Avoid random `npx` commands; they bypass the project lockfile.
- If a package legitimately needs lifecycle scripts, review and allow it deliberately rather than globally enabling scripts.

### pnpm

`pnpm-workspace.yaml`:

```yaml
minimumReleaseAge: 1440   # 1 day in minutes; use 10080 for 7 days
blockExoticSubdeps: true
trustPolicy: no-downgrade
```

`.npmrc`:

```ini
save-exact=true
```

Rules:

- Use `pnpm install --frozen-lockfile` in CI.
- Commit `pnpm-lock.yaml`.
- Use `pnpm approve-builds` to explicitly allow install scripts.

### Bun

`bunfig.toml`:

```toml
[install]
minimumReleaseAge = 86400  # 1 day in seconds; use 604800 for 7 days
```

Bun blocks dependency lifecycle scripts by default. Only add packages to `trustedDependencies` after review.

### GitHub Actions

Pin third-party actions to full commit SHAs, not mutable tags:

```yaml
# Avoid: mutable tag can be force-pushed
- uses: actions/checkout@v4

# Prefer: immutable commit SHA, optionally commented with tag name
- uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
```

Harden every workflow:

```yaml
permissions:
  contents: read
  id-token: none
```

Then grant more only per job that needs it, e.g. `id-token: write` only for an OIDC publishing job.

Rules:

- Avoid `pull_request_target` and `workflow_run` with untrusted code. These patterns repeatedly show up in supply-chain compromises.
- Use OIDC federation for cloud credentials instead of long-lived static secrets.
- Remove legacy publish tokens after enabling trusted publishing. If a token and OIDC are both available, tooling may choose the token path.
- Use ephemeral/JIT runners, not persistent self-hosted runners, for untrusted workloads.
- Restrict allowed actions to GitHub-owned, verified, or explicitly approved actions.

## Why the age gate matters

Most opportunistic supply-chain attacks have short public windows: malicious versions are discovered, quarantined, deprecated, or yanked in hours to days. A 7-day maturity rule is stronger and should be used when compatibility allows. For our interactive Python defaults we chose 1 day because the goal is to catch drive-by attacks without making fresh legitimate releases too painful.

Bypass rule: emergency security patches may bypass the age gate, but the bypass should be a conscious `uv-unsafe` / `pip-unsafe` / CI override with an audit trail.

## Defense tiers

### Tier 1: lockfiles and frozen installs

Commit lockfiles and use frozen installs in CI:

- npm: `package-lock.json` + `npm ci`
- pnpm: `pnpm-lock.yaml` + `pnpm install --frozen-lockfile`
- uv: `uv.lock` + `uv sync --frozen`
- Poetry: `poetry.lock` + locked install flow

This prevents surprise version drift but does not protect the first time you select a malicious version.

### Tier 2: maturity / cooldown gates

Block packages uploaded too recently:

- npm: `min-release-age`
- pnpm: `minimumReleaseAge`
- Bun: `minimumReleaseAge`
- uv: `UV_EXCLUDE_NEWER` / `--exclude-newer`
- pip: `--uploaded-prior-to` / `PIP_UPLOADED_PRIOR_TO` once pip 26.0+ is available

### Tier 3: disable lifecycle and build scripts

JavaScript attacks commonly use `preinstall`, `postinstall`, or `prepare`. Python has analogous build-time execution through source distributions, plus the particularly dangerous `.pth` mechanism in installed wheels, which can execute on interpreter startup.

Controls:

- npm: `ignore-scripts=true`
- pnpm: `approve-builds`
- Bun: scripts blocked by default unless trusted
- Python: prefer wheels only (`PIP_ONLY_BINARY=:all:`, `UV_NO_BUILD=1`)

### Tier 4: hash verification and immutable references

Hash verification catches registry tampering and content swaps. It does not catch legitimate-account malicious publishes: a malicious package published by a compromised maintainer will have valid hashes.

Controls:

- pip: `--require-hashes` with fully-hashed `requirements.txt`
- JS package managers: lockfile `integrity` fields
- GitHub Actions: full commit SHA pins instead of version tags

### Tier 5: provenance and attestation

Provenance helps show a package was built through an expected CI path from a specific commit. It does not help if the attacker can run inside that CI path or if legacy publish tokens remain available.

Controls:

- npm trusted publishing / provenance
- `npm audit signatures`
- PyPI attestations / Integrity API where available
- pnpm `trustPolicy: no-downgrade`
- SLSA-aligned provenance review for critical packages

### Tier 6: runtime, network, and secrets controls

Assume package installs may execute hostile code anyway.

- Block arbitrary egress from CI/build systems.
- Do not inject secrets into jobs that do not need them.
- Prefer OIDC short-lived credentials to static keys.
- Use ephemeral containers/runners with no persistent home directory.
- Enable GitHub secret scanning push protection.
- Keep developer tool hook directories reviewable (`.claude/`, `.vscode/`, shell profiles, package-manager config files).

### Tier 7: organizational controls

- Maintain SBOMs so exposure queries are fast.
- Use a private registry/proxy as a single enforcement point where practical.
- Require dependency review on PRs, especially lockfile diffs.
- Keep dependency count low.
- Use overrides/constraints for rapid containment of a known-bad transitive dependency.

## What not to do

- Do not run `npm install` in CI; use `npm ci`.
- Do not run random `npx` commands.
- Do not allow package lifecycle scripts by default.
- Do not use broad version ranges for production dependencies when exact pins are feasible.
- Do not pin GitHub Actions to tags for high-trust workflows.
- Do not put unnecessary secrets in CI environments.
- Do not rely on provenance badges alone.
- Do not assume lockfile hashes protect against publisher compromise.

## Incident response if exposed

Treat supply-chain malware exposure as credential compromise, not merely a bad dependency.

1. Stop running installs/builds on the affected host or runner.
2. Preserve evidence if needed, then rebuild from a clean image.
3. Rotate all secrets reachable from the environment: GitHub tokens, npm/PyPI tokens, cloud keys, SSH keys, Kubernetes tokens, Vault tokens, database credentials.
4. Audit lockfiles for unexpected version bumps or new dependencies.
5. Check CI logs, package publishing logs, and GitHub audit logs.
6. Scan for persistence in developer tooling directories (`.claude/`, `.vscode/`, shell startup files, package-manager configs, systemd user services).
7. Notify the team and block known IOCs at network boundaries.
8. Add temporary package-manager overrides/constraints to keep known-bad versions out.

## Current campaign note: Mini Shai-Hulud / TanStack / PyPI spillover

Socket reports an ongoing Mini Shai-Hulud campaign affecting npm and PyPI. The TanStack wave involved compromised `@tanstack/*` package artifacts with a new `router_init.js` payload and a malicious git dependency (`@tanstack/setup`) wired through `optionalDependencies` to a suspicious standalone GitHub commit. Socket and TanStack attribute the publish path to a GitHub Actions/OIDC compromise chain rather than stolen npm tokens: attacker-controlled code ran in CI, extracted an OIDC token from the runner process, and published through the trusted-publisher binding.

The campaign reportedly expanded beyond npm into PyPI, including compromised artifacts such as `mistralai@2.4.6` and `guardrails-ai@0.10.1`. Socket's analysis says the `guardrails-ai` payload executes on import, downloads `https://git-tanstack.com/transformers.pyz`, writes it to `/tmp/transformers.pyz`, and runs it without integrity verification.

Important implications:

- OIDC trusted publishing is not magic: if attackers can execute in the trusted workflow, they can produce valid-looking publishes and attestations.
- Age gates help because these malicious versions are often detected quickly.
- Script/build blocking helps because the npm variant used lifecycle execution (`prepare`) on a Git dependency.
- Network egress controls help because payloads need to exfiltrate secrets and sometimes fetch second stages.
- Developer tools are now part of the persistence surface: Socket calls out `.claude/` and `.vscode/` persistence paths in this campaign.

Socket's recommended triage includes checking `router_init.js` hashes, rotating secrets on any machine or CI runner that installed affected versions, revoking/re-establishing GitHub Actions OIDC federation grants for affected publishers, auditing `.claude/` and `.vscode/` directories, checking for suspicious commits authored as `claude@users.noreply.github.com`, and blocking egress to `filev2.getsession[.]org` if Session is not intentionally used.

Reference: https://socket.dev/blog/tanstack-npm-packages-compromised-mini-shai-hulud-supply-chain-attack

## Layer interaction table

| Control | Protects against | Does not protect against |
| --- | --- | --- |
| Lockfile | Version drift, surprise updates | First-time selection of malicious version |
| Hash verification | Registry tampering, content swaps | Publisher compromise |
| Age gate | Short-lived malicious publishes | Slow-burn implants |
| Script/build blocking | Install-time build/lifecycle execution | Runtime payloads, malicious wheels/imports |
| Provenance | Some unauthorized publishing paths | Compromised CI, legacy-token coexistence, malicious trusted workflow |
| Egress control | Exfiltration and second-stage fetches | Local sabotage, already-present secrets exposure |

Use the layers together. Each one fails differently.
