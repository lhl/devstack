# Arch Linux and AUR Safety Guide

Last reviewed: 2026-06-13 JST

This guide is for developers using Arch Linux, CachyOS, EndeavourOS, Manjaro, or other Arch-derived systems. It focuses on the Arch User Repository (AUR), where package recipes are maintained by users rather than by the Arch package maintainers.

The short version: AUR packages are executable code. A `PKGBUILD` can run shell during build, and a package `.install` hook can run during install, upgrade, or removal. Treat AUR usage as running third-party code on your workstation.

For language package manager hardening, also apply the baseline controls in the [README](../README.md#minimum-individual-settings) and [end-user safety guide](end-user-safety.md).

## Threat Model

The AUR has useful software, but it does not have the same trust boundary as official Arch repositories. Important differences:

- Official packages are maintained through Arch's packaging process.
- AUR packages are user-submitted build recipes.
- AUR helpers can make package updates feel routine, but every update may execute new shell code.
- Build-time code usually runs as your user and can read your home directory, browser profiles, shell history, SSH config, npm/GitHub/Vault tokens, and project files.
- Pacman install hooks can run as root.

This means a malicious AUR update can compromise a developer workstation even when the upstream project itself is not compromised.

## June 2026 AUR Malware Incident

On 2026-06-12, Arch published an active incident notice for a high volume of malicious AUR package adoptions and updates. The AUR mailing list later linked a live list containing many, but not all, affected package names.

Public analysis reported two main payload paths:

- AUR package changes that installed the malicious npm package `atomic-lockfile`.
- Later package changes that used Bun to install `js-digest` and related dependencies.

The analyzed `atomic-lockfile` package contained a Linux ELF payload named `deps` and a malicious npm lifecycle entry:

```json
{
  "scripts": {
    "preinstall": "./src/hooks/deps"
  }
}
```

Reported capabilities included credential theft from developer workstations and optional root-only eBPF rootkit behavior. Treat any confirmed exposure as a host compromise, not just a bad package install.

## Exposure Check

Use the live Arch-maintained package list as data only. Do not run arbitrary fetched scripts.

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

Also check whether any known affected package was recently installed or upgraded. Use the incident window relevant to your environment; the public reports centered on 2026-06-11 and 2026-06-12.

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

No output means no match against the current known list. It does not prove the system is clean because the Arch list is explicitly incomplete.

## IOC Check

Search package-manager caches, AUR helper checkouts, temporary directories, and systemd units for the reported package names and C2 string.

```bash
rg -n --hidden --no-messages -S \
  'atomic-lockfile|js-digest|olrh4mibs62l6kkuvvjyc5lrercqg5tz543r4lsw3o6mh5qb7g7sneid\.onion|src/hooks/deps' \
  ~/.npm ~/.cache/yay ~/.cache/paru ~/.cache/pikaur ~/.cache/bun ~/.bun \
  /tmp /var/tmp /usr/lib/node_modules /usr/local/lib/node_modules \
  /etc/systemd/system ~/.config/systemd/user 2>/dev/null || true
```

Check for known payload hashes in likely cache paths:

```bash
find ~/.npm ~/.cache/yay ~/.cache/paru ~/.cache/pikaur ~/.cache/bun ~/.bun \
  /tmp /var/tmp /usr/lib/node_modules /usr/local/lib/node_modules \
  -type f -name deps -print0 2>/dev/null \
  | while IFS= read -r -d '' f; do sha256sum "$f"; done \
  | grep -Ei '6144d433f8a0316869877b5f834c801251bbb936e5f1577c5680878c7443c98b|7883bda1ff15425f2dbe622c45a3ae105ddfa6175009bbf0b0cad9bf5c79b316' || true
```

If `bpftool` is available, check for the suspicious eBPF map names reported by IFIN:

```bash
sudo bpftool map list | grep -E 'hidden_pids|hidden_names|hidden_inodes' || true
```

This check may require root. No matches are expected on a normal system.

## Daily Operating Rules

Use official repositories for routine updates:

```bash
sudo pacman -Syu
```

Do not run AUR updates as part of unattended or reflexive daily updates. Keep AUR updates as a separate, reviewed action.

Inventory your AUR footprint:

```bash
pacman -Qqm | sort
```

Remove packages you no longer need. Every AUR package you remove is one fewer package that can be adopted, renamed, or modified by a malicious maintainer account.

## Review Checklist Before Installing or Updating AUR Packages

Review all AUR repo file changes, not just `PKGBUILD`.

Check for:

- New or changed `.install` files.
- New `install=...` entries in `PKGBUILD`.
- New `npm`, `bun`, `curl`, `wget`, `bash -c`, `sh -c`, `chmod +x`, `systemctl`, or `/tmp` usage.
- New dependencies that do not match the project language or build system.
- Maintainer or contributor identity changes.
- Source URLs that moved from an upstream project to a personal fork, paste site, file host, or shortened URL.
- `sha256sums=('SKIP')` where a stable release archive could be hashed.
- Git sources that track a branch rather than a reviewed commit or tag.

Do not rely on `makepkg --nobuild` as a safe preview step. `makepkg` may execute package functions such as `prepare()`. Review the AUR Git diff before running package build commands.

## Build Isolation

The best practical defense is to build AUR packages somewhere that has no secrets.

Recommended options, from strongest to weakest:

1. Disposable VM with no browser profile, SSH keys, cloud tokens, npm tokens, GitHub tokens, Vault tokens, or project secrets.
2. Clean chroot builds using Arch `devtools` or `aurutils`.
3. Dedicated low-privilege local build user with a separate home directory and no secret-bearing config.
4. Normal workstation build, only for packages you have reviewed and actively trust.

Install the resulting package only after reviewing the package contents and install scripts.

For chroot builds, prefer established Arch tooling rather than ad hoc shell wrappers. The exact command depends on the helper and repository setup, but the principle is constant: build in a clean environment, then install the artifact intentionally.

## npm and Bun Guardrails

This incident used npm/Bun as a second-stage delivery mechanism. Harden them globally, but do not treat this as sufficient.

```bash
sudo sh -c 'printf "ignore-scripts=true\n" > /etc/npmrc'
```

This can break legitimate packages that require npm lifecycle scripts, so teams should document exceptions. It also does not stop a malicious `PKGBUILD` from executing shell directly or passing flags that override local policy.

Bun refuses dependency lifecycle scripts by default unless packages are explicitly trusted, but a malicious AUR script can still invoke arbitrary commands around Bun.

## Network Controls

If you build AUR packages in a VM, restrict outbound network access:

- Allow package fetches only through known mirrors and registries where feasible.
- Block Tor egress from build hosts unless there is a documented need.
- Do not allow build VMs to reach internal production systems.
- Avoid mounting SSH agent sockets, browser profiles, password-manager data, or project secret directories into build environments.

Network controls are not a substitute for review, but they can prevent credential exfiltration when a malicious package runs.

## If You Find a Match

Treat the system as compromised.

1. Stop running installs and builds on the machine.
2. Disconnect or isolate it if active compromise is suspected.
3. Preserve logs and package caches if forensic review matters.
4. Rotate secrets accessible from that machine: SSH keys, GitHub tokens, npm tokens, cloud credentials, VPN material, Vault tokens, Docker/Podman registry credentials, chat app tokens, and browser-session backed service access.
5. Check GitHub, npm, cloud, and registry audit logs for suspicious use.
6. Reinstall the OS from known-good media if the rootkit path is plausible or if privileged execution is confirmed.

Do not attempt to "clean" a confirmed rootkit-capable compromise in place and then continue trusting the host.

## Team Policy Baseline

For managed developer machines:

- Keep a documented allowlist of approved AUR packages.
- Require review for new AUR packages and for AUR package ownership or source changes.
- Prefer official repo packages, Flatpak, upstream signed releases, or internally repackaged artifacts over AUR when practical.
- Build AUR packages in a dedicated clean environment.
- Keep developer secrets out of build hosts.
- Run a known-affected package check during active incidents.
- Record AUR package inventory in endpoint management or asset inventory.

## References

- [Arch Linux: Active AUR malicious packages incident](https://archlinux.org/news/active-aur-malicious-packages-incident/)
- [Arch aur-general: List of affected packages](https://lists.archlinux.org/archives/list/aur-general%40lists.archlinux.org/message/FCH7TT6IOVT7D477JKSVJALBKADAARSW/)
- [Arch live affected package list](https://md.archlinux.org/s/SxbqukK6IA)
- [IFIN: 400+ AUR packages compromised with infostealer and rootkit](https://discourse.ifin.network/t/400-aur-packages-compromised-with-infostealer-and-rootkit/577)
- [ioctl.fail: Preliminary analysis of AUR malware](https://ioctl.fail/preliminary-analysis-of-aur-malware/)
- [Sonatype: Atomic Arch npm campaign adds malicious dependency](https://www.sonatype.com/blog/atomic-arch-npm-campaign-adds-malicious-dependency)
