---
title: Arch AUR Safety
tags: [security, supply-chain, arch-linux, aur, package-management]
sources:
  - sources/repos/supply-chain-security/guides/arch-aur-safety.md
links:
  - https://archlinux.org/news/active-aur-malicious-packages-incident/
  - https://lists.archlinux.org/archives/list/aur-general%40lists.archlinux.org/message/FCH7TT6IOVT7D477JKSVJALBKADAARSW/
  - https://md.archlinux.org/s/SxbqukK6IA
  - https://ioctl.fail/preliminary-analysis-of-aur-malware/
  - https://www.sonatype.com/blog/atomic-arch-npm-campaign-adds-malicious-dependency
---

# Arch AUR Safety

Last reviewed: 2026-06-13 JST.

This page adapts the Arch Linux and Arch User Repository (AUR) guidance from the supply-chain-security repo into this wiki. It complements [[practices/supply-chain-security]], which covers Python, JavaScript package managers, GitHub Actions, and general incident response.

Verified locally on 2026-06-13: Arch published an active incident notice on 2026-06-12 about high-volume malicious AUR package adoptions and updates, and an `aur-general` post linked an affected-package list containing many, but not all, known affected packages. The malware capability details below are public-analysis claims from the source guide and linked analysis; we have not reproduced the reverse engineering here.

## Working model

AUR packages are executable code, not just metadata.

- `PKGBUILD` files can run shell during build.
- `prepare()`, `build()`, `check()`, and `package()` steps run before a package is installed.
- `.install` hooks can run during install, upgrade, and removal.
- Build-time code usually runs as the developer user and can read home-directory secrets.
- Pacman install hooks can run as root.

The practical policy is simple: treat an AUR install or update as running third-party code on the workstation.

## June 2026 AUR incident

Arch reported an active incident on 2026-06-12 involving a high volume of malicious package adoptions and updates in AUR. The AUR mailing list later linked a live affected-package list and explicitly said it contains many, but not all, affected packages.

Public analysis reported two delivery paths:

- AUR package changes that installed the malicious npm package `atomic-lockfile`.
- Later package changes that used Bun to install `js-digest` and related dependencies.

The analyzed `atomic-lockfile` package reportedly contained a Linux ELF payload at `src/hooks/deps` and a malicious npm lifecycle entry:

```json
{
  "scripts": {
    "preinstall": "./src/hooks/deps"
  }
}
```

Reported capabilities included developer credential theft and optional root-only eBPF rootkit behavior. If a confirmed affected package executed on a machine, handle it as a host compromise and credential exposure, not merely as a bad package install.

## Exposure checks

Use the Arch-maintained list as data. Do not run arbitrary fetched scripts.

```bash
tmp_known_bad=$(mktemp)
tmp_installed=$(mktemp)
trap 'rm -f "$tmp_known_bad" "$tmp_installed"' EXIT

curl -fsSL --proto '=https' https://md.archlinux.org/s/SxbqukK6IA/download \
  | grep -E '^[a-z0-9][a-z0-9._+-]*[a-z0-9]$' \
  | sort -u > "$tmp_known_bad"

pacman -Qqm | sort -u > "$tmp_installed"

echo "Known affected AUR packages currently installed:"
comm -12 "$tmp_installed" "$tmp_known_bad" || true
```

Check whether known affected packages were recently installed, upgraded, reinstalled, or downgraded. The public incident reports centered on 2026-06-11 and 2026-06-12, but teams should adjust the window for their environment.

```bash
tmp_known_bad=$(mktemp)
tmp_history=$(mktemp)
trap 'rm -f "$tmp_known_bad" "$tmp_history"' EXIT

curl -fsSL --proto '=https' https://md.archlinux.org/s/SxbqukK6IA/download \
  | grep -E '^[a-z0-9][a-z0-9._+-]*[a-z0-9]$' \
  | sort -u > "$tmp_known_bad"

awk '$1 >= "[2026-06-11" && /\[ALPM\] (installed|upgraded|reinstalled|downgraded)/ {print $4}' \
  /var/log/pacman.log \
  | sort -u > "$tmp_history"

echo "Known affected packages touched since 2026-06-11:"
comm -12 "$tmp_history" "$tmp_known_bad" || true
```

No output means no match against the current known list. It does not prove the system is clean because the public list is incomplete and fast-changing.

## IOC checks

Search likely package-manager caches, AUR helper checkouts, temporary directories, global Node locations, and systemd units for the reported package names, payload path, and C2 string:

```bash
rg -n --hidden --no-messages -S \
  'atomic-lockfile|js-digest|olrh4mibs62l6kkuvvjyc5lrercqg5tz543r4lsw3o6mh5qb7g7sneid\.onion|src/hooks/deps' \
  ~/.npm ~/.cache/yay ~/.cache/paru ~/.cache/pikaur ~/.cache/bun ~/.bun \
  /tmp /var/tmp /usr/lib/node_modules /usr/local/lib/node_modules \
  /etc/systemd/system ~/.config/systemd/user 2>/dev/null || true
```

Check for known `deps` payload hashes in likely cache paths:

```bash
find ~/.npm ~/.cache/yay ~/.cache/paru ~/.cache/pikaur ~/.cache/bun ~/.bun \
  /tmp /var/tmp /usr/lib/node_modules /usr/local/lib/node_modules \
  -type f -name deps -print0 2>/dev/null \
  | while IFS= read -r -d '' f; do sha256sum "$f"; done \
  | grep -Ei '6144d433f8a0316869877b5f834c801251bbb936e5f1577c5680878c7443c98b|7883bda1ff15425f2dbe622c45a3ae105ddfa6175009bbf0b0cad9bf5c79b316' || true
```

If `bpftool` is available, check for the suspicious eBPF map names reported in public analysis:

```bash
sudo bpftool map list | grep -E 'hidden_pids|hidden_names|hidden_inodes' || true
```

No matches are expected on a normal system. A clean result is only one signal; it does not rule out exposure.

## Daily operating rules

Use official repositories for routine updates:

```bash
sudo pacman -Syu
```

Keep AUR updates separate from reflexive daily updates:

- Do not run unattended AUR updates.
- Inventory installed AUR packages with `pacman -Qqm | sort`.
- Remove AUR packages that are no longer needed.
- Prefer official repository packages, Flatpak, signed upstream releases, or internally repackaged artifacts when practical.

## Review checklist

Review all AUR repository file changes, not just `PKGBUILD`.

Pay special attention to:

- New or changed `.install` files.
- New `install=...` entries in `PKGBUILD`.
- New `npm`, `bun`, `curl`, `wget`, `bash -c`, `sh -c`, `chmod +x`, `systemctl`, or `/tmp` usage.
- New dependencies that do not match the upstream project's language or build system.
- Maintainer or contributor identity changes.
- Source URLs moving from the upstream project to a personal fork, paste site, file host, or shortened URL.
- `sha256sums=('SKIP')` where a stable release archive could be hashed.
- Git sources that track a branch instead of a reviewed commit or tag.

Do not treat `makepkg --nobuild` as a safe preview. `makepkg` may execute package functions such as `prepare()`. Review the AUR Git diff before running build commands.

## Build isolation

The strongest practical defense is to build AUR packages somewhere that has no secrets.

Recommended options, strongest first:

1. Disposable VM with no browser profile, SSH keys, cloud tokens, npm tokens, GitHub tokens, Vault tokens, or project secrets.
2. Clean chroot builds using Arch `devtools` or `aurutils`.
3. Dedicated low-privilege local build user with a separate home directory and no secret-bearing config.
4. Normal workstation build, only for packages that were reviewed and actively trusted.

Install the resulting package only after reviewing package contents and install scripts.

## npm and Bun guardrails

The June 2026 incident used npm/Bun as second-stage delivery mechanisms. Harden them globally, but do not treat that as sufficient.

```bash
sudo sh -c 'printf "ignore-scripts=true\n" > /etc/npmrc'
```

This blocks many npm lifecycle-script paths, but it can break legitimate packages and it does not stop a malicious `PKGBUILD` from executing shell directly or overriding local policy. Bun refuses dependency lifecycle scripts by default unless packages are explicitly trusted, but a malicious AUR script can still run arbitrary commands around Bun.

## Network and secret controls

For build VMs or dedicated build hosts:

- Restrict outbound network access to known package mirrors and registries where feasible.
- Block Tor egress from build hosts unless there is a documented need.
- Prevent build environments from reaching internal production systems.
- Do not mount SSH agent sockets, browser profiles, password-manager data, or project secret directories.
- Keep developer secrets out of build hosts.

Network controls are not a substitute for review, but they can stop or slow exfiltration when a malicious package runs.

## If a match is found

Treat the system as compromised.

1. Stop running installs and builds on the machine.
2. Disconnect or isolate it if active compromise is suspected.
3. Preserve logs and package caches if forensic review matters.
4. Rotate secrets accessible from that machine: SSH keys, GitHub tokens, npm tokens, cloud credentials, VPN material, Vault tokens, Docker/Podman registry credentials, chat-app tokens, and browser-session backed service access.
5. Check GitHub, npm, cloud, and registry audit logs for suspicious use.
6. Reinstall from known-good media if privileged execution is confirmed or the rootkit path is plausible.

Do not try to clean a confirmed rootkit-capable host in place and continue trusting it.

## Managed-machine baseline

For team-managed developer machines:

- Keep a documented allowlist of approved AUR packages.
- Require review for new AUR packages and for AUR package ownership or source changes.
- Build AUR packages in a dedicated clean environment.
- Record AUR package inventory in endpoint management or asset inventory.
- Run the known-affected package intersection check during active incidents.
- Prefer non-AUR distribution paths for high-trust developer tooling.
