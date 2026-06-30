# Lamina

Deploy, health, update, and VM-test CLI for the Personal OS Layer.

**Entry point:** `bin/lamina` (symlinked to `~/.local/bin/lamina`)

---

## What it does

Lamina is the operational layer on top of your dotfiles repo. It answers four questions:

1. **Deploy** — Is the machine in the desired state? (symlinks + zsh plugins)
2. **Health** — Has anything drifted, gone stale, or broken?
3. **Update** — Keep platform, packages, and runtimes current in one pass
4. **VM-test** — Prove deploy works in a disposable macOS VM before touching the daily driver

```
┌─────────────────────────────────────────────────────────────┐
│                         lamina                              │
├──────────────┬──────────────┬──────────────┬────────────────┤
│   deploy     │    health    │    update    │    vm-test     │
│  (dotter +   │  (drift +    │  (git pull → │  (Tart macOS   │
│   plugins)   │   strays)    │   brew/nvim) │   sandbox)     │
└──────┬───────┴──────┬───────┴──────┬───────┴────────┬───────┘
       │              │              │                │
       ▼              ▼              ▼                ▼
   .dotter/      manifest.toml   update-*.zsh    vm.toml
   plugins.toml   health.zsh      brew/envs       tart + sshpass
```

---

## Quick reference

| Command | Purpose |
|---------|---------|
| `lamina deploy` | Apply dotter symlinks + sync zsh plugins |
| `lamina deploy --dry-run` | Preview symlink changes (via dotter) |
| `lamina deploy --symlinks-only` | Skip plugin sync |
| `lamina repair` | Like deploy, but replaces copied bin files with symlinks and passes `--force` to dotter |
| `lamina diff` | `dotter deploy --dry-run` from repo root |
| `lamina sync-plugins` | Sync plugins from `lamina/plugins.toml` only |
| `lamina health` | Check strays, stale paths, plugins, bins, core symlinks |
| `lamina update` | Comprehensive maintenance (see below) |
| `lamina vm-test <cmd>` | Tart-based macOS deploy sandbox |

Shell aliases: `update` / `up` → `lamina update` (defined in `zsh/rc.d/800_update.zsh`).

---

## File layout

```
lamina/
├── manifest.toml       # Declarative metadata (symlink provider, health rules)
├── plugins.toml        # Zsh plugin inventory (git repos + plain files)
├── vm.toml             # Tart VM defaults (base image, CPU/RAM, credentials)
├── deploy.zsh          # dotter deploy + dual-link .zshenv + plugin sync
├── health.zsh          # Drift / stray / plugin / symlink checks
├── update.zsh          # Orchestrates comprehensive update pipeline
├── vm-test.zsh         # Tart macOS sandbox commands
├── hooks/
│   └── sync-plugins.zsh    # Wrapper → lib/sync_plugins.py
└── lib/
    ├── common.zsh          # Path helpers, ok/warn/fail output
    ├── update-brew.zsh     # brew update/upgrade/autoremove + Brewfile dump
    ├── update-envs.zsh     # pyenv/nodenv/rbenv/luaenv/goenv + pip/gem/npm
    └── sync_plugins.py     # Clone/update zsh plugin repos from plugins.toml
```

**Symlink policy** (`.dotter/global.toml`):

| `recurse` | When | Examples |
|-----------|------|----------|
| `false` | Whole directory is config | nvim, kitty, fish, git, mc, npm, ranger, znt |
| `true` | App writes logs/state into config dir | btop, lnav |

**Related (outside `lamina/`):**

| Path | Role |
|------|------|
| `.dotter/global.toml` | Symlink manifest (what `lamina deploy` applies) |
| `bin/lamina` | CLI entry point |
| `configs/homebrew/homebrew_bundle_file` | Brewfile (dumped by `lamina update`) |

---

## Commands in detail

### `lamina deploy`

1. Ensure prerequisite dirs exist (`~/.zsh`, `~/.config`, `~/.local/bin`, etc.)
2. Run `dotter deploy` (symlinks from `.dotter/global.toml`)
3. Dual-link `zsh/.zshenv` → both `~/.zshenv` and `$ZDOTDIR/.zshenv`
4. Sync zsh plugins from `lamina/plugins.toml` (unless `--symlinks-only`)

Dotter args are forwarded: `--dry-run`, `--force`, etc.

### `lamina health`

Checks four categories:

| Category | What it checks |
|----------|----------------|
| **Stray files** | e.g. `~/.zshrc` (installer wrote a real file; ZDOTDIR owns config) |
| **Stale artifacts** | Old plugins (p10k, autocomplete), removed VM stacks (`.lima`, `.colima`) |
| **Zsh plugins** | Each repo in `plugins.toml` has a `.git` dir under `~/.zsh/plugins` |
| **Core symlinks** | Key dotter targets (zsh dirs, nvim, kitty, starship, tmux) |
| **Required bins** | `launch-os-layer`, `grok-acp`, `lamina` in `~/.local/bin` |

Exit code 1 if any issue found. Fix with `lamina deploy` (or manual cleanup for stale paths).

### `lamina update`

Default (comprehensive) pipeline:

```
git pull (if clean)
  → lamina deploy
  → Neovim Lazy sync + TSUpdate + MasonUpdate
  → Xcode / CLT check
  → Homebrew update + upgrade + autoremove + Brewfile dump
  → version-manager definition refresh (python-build, node-build, etc.)
  → pip / gem / npm upgrades
  → lamina health
```

| Flag | Effect |
|------|--------|
| `--quick` | git pull → deploy → nvim only |
| `--install-latest` | Also install latest stable pyenv/nodenv/rbenv/luaenv/goenv (does not change global) |
| `--check` | Print planned steps, run nothing |
| `--no-pull` / `--no-nvim` / `--no-brew` / `--no-envs` / `--no-packages` / `--no-health` | Skip individual stages |

See also: [UPDATE-STRATEGY.md](../personal-os-layer/UPDATE-STRATEGY.md)

### `lamina vm-test`

Tart-based disposable macOS VMs for deploy verification.

```bash
lamina vm-test setup-base          # once: clone ~25GB Tahoe base image
lamina vm-test e2e --check         # dry-run full cycle
lamina vm-test e2e                 # clone → run → deploy → health → destroy
lamina vm-test e2e --keep          # keep VM for debugging
```

Config: `lamina/vm.toml`. Guest mount: host dotfiles → `/Volumes/My Shared Files/dotfiles`.

See also: [VM-INFRASTRUCTURE.md](../personal-os-layer/VM-INFRASTRUCTURE.md)

---

## Configuration files

### `manifest.toml`

Declares lamina metadata and health rules:

- `[symlinks]` — dotter is the symlink provider (`.dotter/global.toml`)
- `[plugins]` — points to `plugins.toml` and sync hook
- `[health.stray_files]` — paths that should not exist
- `[health.stale_paths]` — legacy artifacts to warn about
- `[health.required_bins]` — binaries that must be present and executable

### `plugins.toml`

Canonical zsh plugin list. Each `[[plugins.repo]]` entry specifies name, dir, url, depth, optional branch/submodules. Synced by `lamina sync-plugins` (also runs during deploy).

To add a plugin: edit `plugins.toml` → `lamina deploy` → verify in `lamina health`.

### `vm.toml`

Tart VM settings: base image, CPU/RAM, guest credentials, mount name, SSH timeout.

---

## Typical workflows

### Something broke after a pull

```bash
cd ~/.local/share/dotfiles
git pull
lamina deploy
lamina health
exec zsh   # reload shell if symlinks/plugins changed
```

### Routine maintenance

```bash
update              # comprehensive (alias for lamina update)
update --quick      # fast path: dotfiles + nvim only
update --check      # see what would run
```

### Preview symlink changes

```bash
lamina diff
lamina deploy --dry-run
```

### Test deploy in a VM

```bash
brew bundle install --file=configs/homebrew/homebrew_bundle_file   # tart + sshpass
lamina vm-test setup-base
lamina vm-test e2e
```

---

## How lamina relates to dotter

- **Dotter** owns the symlink manifest (`.dotter/global.toml`) — declarative, diffable
- **Lamina** orchestrates dotter + plugin sync + health + update + VM testing
- **Dual-link** `.zshenv` is lamina-specific (dotter handles `~/.zshenv`; lamina also links into `$ZDOTDIR`)

`lamina deploy` is the day-to-day command. `deploy.zsh --install` is the heavier first-time bootstrap (still being refined).

---

## Roadmap / open items

From [GAME-PLAN.md](../personal-os-layer/GAME-PLAN.md):

| Item | Status |
|------|--------|
| `lamina health` | Started — symlink/bin/stray checks |
| `lamina update` | Done |
| `lamina vm-test e2e` | Validated (needs `setup-base` on host) |
| `lamina health --brief` for prompt | Not started |
| Golden VM image (pre-baked brew/dotter) | Phase C |
| Fresh-machine `deploy.zsh --install` in VM | Partial |

---

## Related docs

- [UPDATE-STRATEGY.md](../personal-os-layer/UPDATE-STRATEGY.md) — cadence, workflows, what to commit
- [VM-INFRASTRUCTURE.md](../personal-os-layer/VM-INFRASTRUCTURE.md) — Tart setup, e2e testing
- [ARCHITECTURE-SKETCH.md](../personal-os-layer/ARCHITECTURE-SKETCH.md) — layer model
- [GAME-PLAN.md](../personal-os-layer/GAME-PLAN.md) — phase tracking
- [WORKLOG.md](../personal-os-layer/WORKLOG.md) — what shipped and when