# VM Infrastructure — Deploy Testing on macOS

Can we spin up disposable machines to test `deploy.zsh` / `lamina deploy` before touching the daily driver?

**Yes on macOS — with caveats.** What you need depends on *what* you're testing.

**Last updated:** 2026-06-17  
**Host:** Apple Silicon (`arm64`), macOS 26.x (this machine)

---

## What we're trying to validate

| Target | Why |
|--------|-----|
| Full Personal OS Layer bootstrap | `deploy.zsh`, `lamina deploy`, dotter symlinks, zsh plugins, nvim lazy sync |
| macOS-specific paths | Homebrew bundle, XDG layout, kitty/tmux/starship, Obsidian vault paths |
| Repeatability | Snapshot → break → restore → re-run deploy |

That is **not** the same as "a Linux container for CI." This stack is macOS-first.

---

## Options on Apple Silicon Mac

### 1. Tart — **best fit for macOS-on-macOS** (recommended)

[Tart](https://tart.run/) uses Apple's **Virtualization.framework** to run fast macOS VMs on Apple Silicon.

| Pros | Cons |
|------|------|
| Native macOS guests | Requires macOS IPSW / Apple Silicon host |
| Fast boot, CI-friendly (`tart run --vnc`) | Guest macOS must be licensed like any Mac |
| Clone/snapshot VMs for rollback | Initial setup more involved than Lima |
| SSH into VM for headless deploy tests | Not in current Brewfile (easy add: `brew install cirruslabs/cli/tart`) |

**Use when:** You want a real macOS sandbox that runs the *actual* deploy path.

```bash
# Sketch workflow (after tart + IPSW setup)
tart clone base-macos deploy-test
tart run deploy-test --dir="~/.local/share/dotfiles:tag=mount"  # or rsync in
ssh admin@deploy-test 'cd dotfiles && ./deploy.zsh --install'
lamina health   # inside VM
```

### 2. Lima — **already installed** (`limactl`)

[Lima](https://github.com/lima-vm/lima) runs **Linux** VMs (Ubuntu, etc.) on Mac via VZ or QEMU.

| Pros | Cons |
|------|------|
| Already on this machine | **Cannot** run macOS guests |
| Great for Linux-only tooling | Won't exercise Homebrew/macOS dotfiles path |
| Colima uses Lima under the hood (`colima` in Brewfile) | Different shell paths, no kitty/tmux mac integration |

**Use when:** Testing Linux-side scripts, containers, or future cross-platform pieces — **not** full dotfiles bootstrap.

### 3. UTM / VMware Fusion / Parallels

| Tool | Notes |
|------|-------|
| **UTM** | Free, GUI-heavy; macOS + Linux guests; slower than Tart |
| **VMware Fusion** | Personal free tier; strong on Intel; AS Mac guests improving |
| **Parallels** | Polished macOS VMs on AS; commercial |

**Use when:** You want GUI VM management and don't mind manual snapshots.

### 4. Cloud Mac (MacStadium, AWS EC2 Mac, GitHub macOS runners)

**Use when:** CI pipelines, not local iteration. Expensive; high fidelity for release gates.

---

## Recommendation for this project

```
Phase A (now)     deploy-testing.zsh on host + lamina health
Phase B (next)    Tart base VM — "fresh macOS" snapshot, run deploy.zsh --install
Phase C (later)   Tart CI template — clone, deploy, health, destroy
```

**Do not** expect Colima/Lima to replace Tart for dotfiles testing — they're complementary (Colima = Docker/Linux workloads).

---

## Phase B — Tart bootstrap sketch

Prerequisites:
- Apple Silicon Mac
- `brew install cirruslabs/cli/tart`
- macOS IPSW from [Apple IPSW downloads](https://ipsw.me/) or `tart create` wizard

```bash
# 1. Create golden image (once)
tart create --from-ipsw=macos.ipsw base-macos
tart set base-macos --cpu 4 --memory 8
# Install Xcode CLT, Homebrew, clone dotfiles in guest → snapshot as base-macos-ready

# 2. Per test run
tart clone base-macos-ready deploy-test-$(date +%Y%m%d)
tart run deploy-test-... --vnc   # or -n for headless + ssh

# 3. Inside guest
git clone git@github.com:sudobashme/dotfiles.git ~/.local/share/dotfiles
~/.local/share/dotfiles/deploy.zsh --install   # or lamina deploy after manual prereqs
lamina health
lamina update --check
```

Document failures in `WORKLOG.md`; promote fixes to `deploy.zsh` / `lamina`.

---

## What we have today

- `deploy-testing.zsh` — partial host-side test harness (predates lamina)
- `lamina health` — post-deploy verification on real machine
- `lamina update` — routine sync path (not a VM provisioner)

**Missing:** Tart base image, automated clone-and-test script (`lamina vm test` — future).

---

## Open questions

1. **Guest credentials** — SSH keys via Tart cloud-init or manual?
2. **Dotfiles secrets** — Obsidian vault paths, API keys: mock in VM or skip those plugins?
3. **Company Mac policy** — confirm VM software is allowed on work machine.
4. **Time cost** — first IPSW + guest setup is ~1–2 hours; clones after that are minutes.

---

## Related

- [GAME-PLAN.md](./GAME-PLAN.md) — Phase 2 deploy/bootstrap
- [UPDATE-STRATEGY.md](./UPDATE-STRATEGY.md) — post-deploy verification
- [deploy-testing.zsh](../../deploy-testing.zsh) — legacy host test script