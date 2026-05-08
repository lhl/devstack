# Supply Chain Security for Software Developers

Practical, layered defenses against package supply chain attacks. Written after the March–April 2026 wave of supply chain compromises: [Trivy](https://github.com/aquasecurity/trivy/discussions/10425) and [LiteLLM](https://snyk.io/blog/poisoned-security-scanner-backdooring-litellm/) (TeamPCP), and [axios](https://www.microsoft.com/en-us/security/blog/2026/04/01/mitigating-the-axios-npm-supply-chain-compromise/) (Sapphire Sleet / UNC1069).

## What Happened

Three major supply chain attacks hit within two weeks, exposing how fragile implicit trust in open-source tooling can be.

**Trivy (TeamPCP, March 19–22):** Aqua Security's Trivy vulnerability scanner — the most widely used open-source scanner in cloud-native CI/CD — was [compromised in a multi-phase attack](https://www.paloaltonetworks.com/blog/cloud-security/trivy-supply-chain-attack/). An earlier breach in February via a misconfigured `pull_request_target` workflow stole a Personal Access Token. Credential rotation was incomplete, and TeamPCP retained access. They force-pushed 75 of 76 `trivy-action` tags and all 7 `setup-trivy` tags to malicious commits, published an infected binary (v0.69.4), and harvested SSH keys, cloud credentials, Kubernetes tokens, Docker registry credentials, database passwords, and private keys from runner memory. A persistent systemd backdoor was installed on developer workstations. The group also launched [CanisterWorm](https://www.stepsecurity.io/blog/canisterworm-how-a-self-propagating-npm-worm-is-spreading-backdoors-across-the-ecosystem), compromising 47+ npm packages via stolen publish tokens.

**LiteLLM (TeamPCP, March 24):** Using PyPI credentials stolen from LiteLLM's CI pipeline (which ran Trivy without version pinning), TeamPCP [published malicious versions](https://docs.litellm.ai/blog/security-update-march-2026) 1.82.7 and 1.82.8. Version 1.82.8 used a `.pth` file that executes on *every* Python process startup — not just processes that import LiteLLM. The packages were live for roughly 3–5 hours before PyPI quarantined them. Docker image users were unaffected because the official image pins dependencies. LiteLLM has ~95 million monthly downloads.

**axios (Sapphire Sleet / UNC1069, March 31):** In a [separate incident](https://cloud.google.com/blog/topics/threat-intelligence/north-korea-threat-actor-targets-axios-npm-package) attributed to a North Korean state actor, the npm account of the lead axios maintainer was compromised. Two malicious versions (1.14.1 and 0.30.4) were [published directly via npm CLI](https://www.huntress.com/blog/supply-chain-compromise-axios-npm-package) using a stolen long-lived access token, bypassing the project's OIDC trusted publishing setup. The versions injected `plain-crypto-js` as a dependency, whose `postinstall` script dropped a cross-platform RAT. The malicious packages were live for ~3 hours. axios has roughly 100 million *weekly* downloads.

Key lessons:
- **Trivy**: Mutable version tags can be force-pushed. Anyone using `@v0.28.0` instead of a full commit SHA got compromised.
- **LiteLLM**: Python's `.pth` mechanism fires on every interpreter startup. Virtual environments and containers limit blast radius.
- **axios**: OIDC trusted publishing only works if you *remove* the legacy token. The axios project had OIDC configured, but the workflow also passed `NPM_TOKEN` as an environment variable — and npm uses the token when both are present.

---

## Minimum Individual Settings

Apply these now. They protect against the majority of supply chain attacks with minimal effort.

### npm

Add to `~/.npmrc` or your project `.npmrc`:

```ini
min-release-age=7
ignore-scripts=true
save-exact=true
```

- Always use `npm ci` (not `npm install`) in CI
- Always commit your `package-lock.json`
- Don't run random `npx` commands — they bypass your lockfile

### pnpm

Add to `pnpm-workspace.yaml`:

```yaml
minimumReleaseAge: 10080   # 7 days in minutes
blockExoticSubdeps: true
trustPolicy: no-downgrade
```

Add to `.npmrc`:

```ini
save-exact=true
```

- Use `pnpm install --frozen-lockfile` in CI
- Commit `pnpm-lock.yaml`
- Run `pnpm approve-builds` to explicitly allow install scripts

### Python (uv)

```bash
# Set a 7-day freshness cutoff for dependency resolution
export UV_EXCLUDE_NEWER=$(date -d '7 days ago' -u +%Y-%m-%dT00:00:00Z)

# Always use frozen installs in CI
uv sync --frozen
```

- Commit `uv.lock`
- Use `uv lock --check` to verify the lockfile is clean

### Python (pip)

```bash
# Always require hashes, only use wheels, and enforce an age gate
pip install \
  --require-hashes \
  --only-binary :all: \
  --uploaded-prior-to $(date -d '7 days ago' -u +%Y-%m-%dT00:00:00Z) \
  -r requirements.txt
```

- Pin every dependency with `==`
- `--require-hashes` enables all-or-nothing hash checking: every requirement must have a hash or the install fails
- `--only-binary :all:` prevents source distributions from executing arbitrary code during build
- `--uploaded-prior-to` (pip 26.0+) implements the 7-day age gate; note it only accepts absolute dates, so CI needs a wrapper or `PIP_UPLOADED_PRIOR_TO` set dynamically
- For generating pinned+hashed requirements: `uv pip compile --generate-hashes`

### Bun

Add to `bunfig.toml`:

```toml
[install]
minimumReleaseAge = 604800  # 7 days in seconds
```

Bun refuses dependency lifecycle scripts by default — only add packages to `trustedDependencies` after review.

### GitHub Actions

Pin all third-party actions to full commit SHAs, not mutable version tags:

```yaml
# BAD - mutable tag can be force-pushed
- uses: actions/checkout@v4

# GOOD - immutable commit SHA
- uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
```

Additional hardening:
- Set `permissions:` to least privilege on every job (default `contents: read` at the workflow level)
- Avoid `pull_request_target` and `workflow_run` with untrusted code — the initial Trivy breach exploited exactly this pattern
- Use OIDC federation for cloud credentials instead of long-lived secrets
- Restrict allowed actions to `actions/*`, verified creators, and explicitly approved third-party actions
- Use ephemeral/JIT runners, not persistent self-hosted runners — the Trivy attack installed persistent systemd backdoors on non-ephemeral runners

---

## The 7-Day Rule

**Never install a package version that's less than 7 days old.** This is the single most effective defense against short-lived malicious publishes. The axios attack had a window of roughly 3 hours before detection — a 7-day policy would have trivially avoided it.

All the package manager settings above enforce this. For pip, this requires pip 26.0+ with `--uploaded-prior-to` or uv's `--exclude-newer`. The one exception: emergency security patches (actual CVEs) may bypass the age gate, but this should be a conscious decision.

---

## What Not To Do

- **Don't run `npm install` in CI** — use `npm ci` or `pnpm install --frozen-lockfile`
- **Don't use `npx` for random packages** — it bypasses your lockfile entirely
- **Don't allow install scripts by default** — most supply chain attacks use `postinstall`/`preinstall` as the execution vector
- **Don't use version ranges** (`^`, `~`) — pin exact versions
- **Don't pin GitHub Actions to tags** — use full commit SHAs
- **Don't store secrets in CI environment variables unnecessarily** — the Trivy attack harvested everything from runner memory (AWS keys, SSH keys, Kubernetes tokens)
- **Don't use `--extra-index-url` for private packages** — it creates dependency confusion risk; use `--index-url` with a single registry, or uv's `first-index` strategy

---

## Defense Tiers

### Tier 1: Lockfiles and Frozen Installs (Zero-Effort Wins)

Commit `package-lock.json` / `pnpm-lock.yaml` / `uv.lock` / `poetry.lock`. Use frozen installs in CI (`npm ci`, `pnpm i --frozen-lockfile`, `uv sync --frozen`). Pin exact versions. This is your seatbelt.

### Tier 2: The 7-Day Cooldown

Never install a package version less than 7 days old. The settings in the "Minimum Individual Settings" section above all enforce this. Compromised packages are typically detected and removed within hours to days.

### Tier 3: Disable Lifecycle Scripts

`postinstall` / `preinstall` scripts are the primary execution vector. Set `ignore-scripts=true` in `.npmrc` and explicitly allowlist packages that legitimately need build scripts. pnpm v10 has `pnpm approve-builds`; Bun blocks scripts by default.

For Python, the `.pth` file technique (LiteLLM) is worse — it runs on every Python process, not just ones that import the package. Use `--only-binary :all:` to prevent source distributions from running build-time code. Use virtual environments and containers aggressively.

### Tier 4: Hash Verification

Lockfiles with integrity hashes ensure that even if a registry serves different content for the same version, the install fails. For pip, `--require-hashes` activates all-or-nothing hash checking: every requirement must include a hash or the install errors out.

Note: hash verification confirms a file matches what the registry advertises. It does **not** protect against publisher compromise — the malicious LiteLLM 1.82.8 wheel passed all hash checks because it was published with legitimate stolen credentials.

For GitHub Actions, pin to full commit SHAs (see above).

### Tier 5: Provenance and Attestation

npm supports provenance attestation — packages can cryptographically prove they were built from a specific Git commit through a verified CI/CD pipeline. The axios attack bypassed CI/CD entirely (stolen credentials, published directly). Provenance would flag this.

**Critical caveat:** provenance only protects if you remove legacy publishing paths. The axios project had OIDC trusted publishing configured, but the workflow still passed `NPM_TOKEN` alongside OIDC credentials. When both are present, npm uses the token — making the OIDC configuration ineffective.

Check with `npm audit signatures`. PyPI has attestations via the Integrity API. pnpm's `trustPolicy: no-downgrade` fails closed when trust evidence gets worse.

### Tier 6: Runtime and Network Defense

- **Egress filtering**: The axios RAT called `sfrclak[.]com:8000`. If builds can't reach arbitrary hosts, exfil fails.
- **Secrets management**: Don't put secrets in the build environment. The Trivy attack harvested everything from runner memory. Use OIDC for cloud providers; inject secrets only when strictly necessary.
- **Sandboxed builds**: Ephemeral containers with no persistent state. The LiteLLM attack installed a persistent systemd backdoor. Use ephemeral/JIT CI runners.
- **Push protection**: Enable GitHub secret scanning push protection to block secrets from landing in repositories in the first place.

### Tier 7: Organizational

- **SBOMs**: Know what you have so when the next axios happens, you can query instantly.
- **Private registry/proxy**: Single chokepoint for enforcement (Artifactory, Nexus, etc.).
- **Dependency review on PR**: Tools like Socket, Snyk, Renovate that flag suspicious lockfile diffs. Make this a required check.
- **Minimal dependencies**: Every dep you don't have is a dep that can't be compromised.
- **Rapid containment**: When an incident hits, use npm/pnpm `overrides` or pip constraints files to force a known-good transitive version before every upstream package has shipped a fix.

---

## If You Think You Were Exposed

**Assume breach, not just "bad dependency."**

1. **Stop** — don't run any more installs or builds on the affected system
2. **Rotate all secrets** accessible from the affected environment (API keys, cloud credentials, SSH keys, publishing tokens)
3. **Check your lockfile** — look for unexpected new dependencies or version changes
4. **Check for IOCs** — unexpected outbound network connections, new system services, unfamiliar files
5. **Alert your team** so they can check other systems
6. **Audit CI/CD** — check for unauthorized workflow changes, new secrets access, or token usage

Official incident guidance:
- [Trivy (Aqua)](https://github.com/aquasecurity/trivy/discussions/10425): rotate pipeline secrets immediately
- [LiteLLM](https://docs.litellm.ai/blog/security-update-march-2026): rotate all secrets on affected systems, upgrade to v1.83.0+
- [axios (Huntress)](https://www.huntress.com/blog/supply-chain-compromise-axios-npm-package): audit lockfiles, rotate secrets, check for platform-specific IOCs
- [axios (Microsoft)](https://www.microsoft.com/en-us/security/blog/2026/04/01/mitigating-the-axios-npm-supply-chain-compromise/): detection queries and Defender guidance

---

## Why Layered Controls

No single control is sufficient:

| Control | Protects against | Does not protect against |
| --- | --- | --- |
| Lockfile | Version drift, surprise updates | First-time bad version choice |
| Hash verification | Registry tampering, content swap | Publisher compromise (LiteLLM passed hash checks) |
| Age gate | Short-lived malicious publishes | Slow-burn implants |
| Script blocking | Install-time code execution | Runtime payloads, `.pth` injection |
| Provenance | Unauthorized publishing | Compromised CI/CD, legacy token coexistence |

You want the layers together. A lockfile helps reproducibility but does nothing for the first time you choose a bad version. A hash helps integrity but not publisher compromise. A maturity gate helps against short-lived bad publishes but not slow-burn implants.

---

## Scope and Limitations

This guide covers npm, pnpm, Bun, pip, uv, and GitHub Actions — the ecosystems hit in the March–April 2026 incidents. Cargo, Go modules, Maven/Gradle, and other ecosystems have their own supply chain considerations but are not covered here.

---

## References

- [Trivy supply chain compromise (Aqua)](https://github.com/aquasecurity/trivy/discussions/10425)
- [Microsoft: Detecting and defending against Trivy compromise](https://www.microsoft.com/en-us/security/blog/2026/03/24/detecting-investigating-defending-against-trivy-supply-chain-compromise/)
- [Microsoft: Mitigating the Axios npm supply chain compromise](https://www.microsoft.com/en-us/security/blog/2026/04/01/mitigating-the-axios-npm-supply-chain-compromise/)
- [Google: North Korea-nexus threat actor compromises axios](https://cloud.google.com/blog/topics/threat-intelligence/north-korea-threat-actor-targets-axios-npm-package)
- [Snyk: How a poisoned security scanner became the key to backdooring LiteLLM](https://snyk.io/blog/poisoned-security-scanner-backdooring-litellm/)
- [Huntress: Supply chain compromise of axios npm package](https://www.huntress.com/blog/supply-chain-compromise-axios-npm-package)
- [Wiz: Trivy compromised by TeamPCP](https://www.wiz.io/blog/trivy-compromised-teampcp-supply-chain-attack)
- [Datadog: LiteLLM and Telnyx compromised on PyPI](https://securitylabs.datadoghq.com/articles/litellm-compromised-pypi-teampcp-supply-chain-campaign/)
- [Palo Alto Networks: Trivy supply chain attack](https://www.paloaltonetworks.com/blog/cloud-security/trivy-supply-chain-attack/)
- [LiteLLM: Security update March 2026](https://docs.litellm.ai/blog/security-update-march-2026)
- [npm config reference (min-release-age, ignore-scripts)](https://docs.npmjs.com/cli/v11/using-npm/config)
- [npm package-lock.json](https://docs.npmjs.com/cli/v11/configuring-npm/package-lock-json)
- [npm verifying registry signatures](https://docs.npmjs.com/verifying-registry-signatures/)
- [npm trusted publishers](https://docs.npmjs.com/trusted-publishers/)
- [pnpm: Mitigating supply chain attacks](https://pnpm.io/supply-chain-security)
- [pip: Secure installs](https://pip.pypa.io/en/stable/topics/secure-installs/)
- [pip: --uploaded-prior-to (pip 26.0)](https://pip.pypa.io/en/stable/user_guide/)
- [GitHub: Workflow syntax (permissions)](https://docs.github.com/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub: About push protection](https://docs.github.com/en/code-security/concepts/secret-security/about-push-protection)
- [GitHub dependency review](https://docs.github.com/code-security/supply-chain-security/understanding-your-software-supply-chain/about-dependency-review)
- [GitHub Dependabot options (cooldown)](https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-options-reference)
- [GitHub artifact attestations](https://docs.github.com/actions/security-for-github-actions/using-artifact-attestations)
- [GitHub securing accounts](https://docs.github.com/en/code-security/tutorials/implement-supply-chain-best-practices/securing-accounts)
- [SLSA framework](https://slsa.dev/)
- [uv settings reference](https://docs.astral.sh/uv/reference/settings/)

*Last updated: 2026-04-02*
