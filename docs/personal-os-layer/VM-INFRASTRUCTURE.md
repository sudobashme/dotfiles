# VM Infrastructure — Deploy Testing on macOS

Disposable macOS VMs to test `deploy.zsh` / `lamina deploy` before touching the daily driver.

**Last updated:** 2026-06-17  
**Stack:** [Tart](https://tart.run/) on Apple Silicon (`arm64`)

Lima and Colima were removed from the Brewfile — they run Linux/container workloads, not macOS guests, and are not needed for this project.

---

## Quick start

```bash
brew bundle install --file=configs/homebrew/homebrew_bundle_file   # tart + sshpass
lamina vm-test setup-base          # once: clone ~25GB Tahoe base image
lamina vm-test e2e --check         # dry-run the full flow
lamina vm-test e2e                 # clone → run → deploy → health → destroy
lamina vm-test e2e --keep          # keep VM for debugging
```

Config: `lamina/vm.toml` (base image, CPU/RAM, guest credentials, mount name).

---

## Commands

| Command | Purpose |
|---------|---------|
| `lamina vm-test setup-base` | Clone `ghcr.io/cirruslabs/macos-tahoe-base:latest` → `lamina-base-macos` |
| `lamina vm-test clone [name]` | Clone base → disposable test VM |
| `lamina vm-test run [name]` | Headless start with dotfiles mounted |
| `lamina vm-test deploy [name]` | SSH: `lamina deploy` + `lamina health` in guest |
| `lamina vm-test e2e` | Full automated cycle |
| `lamina vm-test list` | Show `lamina-*` VMs |

Guest mount: host dotfiles → `/Volumes/My Shared Files/dotfiles`

Default guest credentials (Tart base images): `admin` / `admin`

---

## What gets validated

| Target | How |
|--------|-----|
| Dotter symlinks | `lamina deploy` in guest |
| Zsh plugins | plugin sync during deploy |
| Drift / strays | `lamina health` in guest |
| macOS paths | Real Homebrew + XDG layout in macOS guest |

---

## Phase plan

```
Phase A ✅   lamina health + lamina update on host
Phase B ✅   lamina vm-test scaffold + Tart in Brewfile
Phase C      Golden image customization (pre-baked brew/dotter in base VM)
Phase D      CI-style: lamina vm-test e2e in a script / hook
```

---

## One-time host setup notes

Tart may suggest shortening the macOS Internet Sharing DHCP lease when running many VMs:

```bash
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.InternetSharing.default.plist \
  bootpd -dict DHCPLeaseTimeSecs -int 600
```

See [Tart FAQ — DHCP lease time](https://tart.run/faq/#changing-the-default-dhcp-lease-time).

---

## Cleaning up old Lima/Colima (optional)

If still installed from before:

```bash
colima stop 2>/dev/null; colima delete -f 2>/dev/null
brew uninstall colima lima docker docker-compose docker-machine 2>/dev/null
rm -rf ~/.colima ~/.lima
lamina health   # should warn if stale dirs remain
```

---

## Related

- [GAME-PLAN.md](./GAME-PLAN.md) — Phase 2 deploy/bootstrap
- [UPDATE-STRATEGY.md](./UPDATE-STRATEGY.md) — post-update verification
- `lamina/vm.toml` — VM defaults
- [deploy-testing.zsh](../../deploy-testing.zsh) — legacy host test script