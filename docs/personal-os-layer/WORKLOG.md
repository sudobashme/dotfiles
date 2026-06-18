# Worklog — Personal OS Layer

Chronological record of meaningful changes. One entry per sprint or significant session.

---

## 2026-06-17 — Editor cohesion sprint (Neovim + Yazi)

**Commit:** `bcb779a` — `neovim fixes`  
**Context:** Grok-assisted stabilization pass on LazyVim custom plugins after Neorg, health warnings, and tooling conflicts surfaced in daily use.

### Changed

**Neovim (`configs/nvim/`)**
- `neorg.lua` — proper tree-sitter-norg deps; removed luarocks path
- `conform.lua` — Biome-first JS/TS formatting
- `neoconf.lua` + `neoconf.json` — early neoconf load; global lua_ls settings
- `nvim-lspconfig.lua` — neoconf `before_init` for jsonls/lua_ls; removed bogus `keys` server block
- `which-key.lua` — hide `<Plug>` duplicates; Neorg key group
- `obsidian.lua` — all setup options moved into `opts`; `ui.enable = false` for render-markdown
- `snacks.lua` — `image.math.enabled = false` (render-markdown owns LaTeX)
- `mason.lua` — `json-lsp` in ensure_installed
- `nvim-treesitter.lua` — parser list trimmed (norg parsers owned by neorg deps)
- Deleted `nvim-luarocks.lua`
- `dotfyle.json` / `lazy-lock.json` regenerated

**Yazi**
- `configs/yazi/flavors/catppuccin-mocha.yazi/flavor.toml` — removed invalid wildcard rules

**Shell**
- `zsh/rc.d/000_tmux.zsh` — prompt/tmux integration tweak (same commit)

### Verified (automated)

- `render-markdown` health: no obsidian/snacks conflicts after opts fix
- `obsidian.get_client().opts.ui.enable == false` after reload

### Left for user smoke test

- Neorg `.norg` editing
- Obsidian vault markdown rendering
- Yazi launch + flavor
- Biome format on save

### Docs updated

- `GAME-PLAN.md` (created)
- `WORKLOG.md` (this file)
- `UPDATE-STRATEGY.md` (created) — cadence for git/deploy/`up`/nvim/docs; notes gaps until `lamina update`
- `CURRENT-STATE.md` — Neovim section refreshed
- `README.md` — links to game plan, worklog, update strategy

---

## 2026-06-17 — `lamina update` + VM infrastructure doc

**Context:** Unify scattered update paths; answer whether macOS can host deploy-test VMs.

### Added

- `lamina/update.zsh` — `lamina update [--check|--full|--no-pull|--no-nvim|--no-health]`
- `bin/lamina` — `update` / `up` subcommand
- `zsh/rc.d/800_update.zsh` — `update`/`up` now delegates to `lamina update --full`
- `docs/personal-os-layer/VM-INFRASTRUCTURE.md` — Tart (macOS guests) vs Lima/Colima (Linux)

### VM takeaway

- **Yes on macOS** for full dotfiles testing → **Tart** (Apple Virtualization.framework, macOS-on-macOS)
- **Lima/Colima** already on machine — good for Linux/Docker, not macOS bootstrap fidelity

---

## 2026-06-17 — Tart VM testing + remove Colima/Docker stack

### Added

- `lamina/vm-test.zsh` — `lamina vm-test {setup-base,clone,run,deploy,test,...}`
- `lamina/vm.toml` — Tart image/CPU/RAM/guest defaults
- Brewfile: `tap cirruslabs/cli`, `tart`, `sshpass`

### Removed from Brewfile

- `colima`, `docker`, `docker-compose`, `docker-machine` (Lima/Colima Linux stack — not needed)

### Health

- Stale path warnings for `~/.colima` and `~/.lima`

### First run

```bash
lamina vm-test setup-base    # downloads ~25GB base image (once)
lamina vm-test e2e --check
```

### Tart e2e validated (2026-06-17)

- `setup-base` completed (~27GB pull)
- Fixed: `tart list` name parsing, `lamina_dotfiles()` for sourced scripts, guest Homebrew/dotter bootstrap
- `lamina vm-test e2e` — deploy + health passed in guest, VM destroyed after run

### Host cleanup (2026-06-17)

- Stopped/deleted Colima instance
- `brew uninstall colima lima docker docker-compose docker-machine`
- Removed `~/.colima`
- `lamina health` — all checks passed

---

## Earlier history

Pre-2026 work (lamina scaffold, personal-os-layer charter, zsh modularization, OpenClaw integration doc) predates this worklog. See git history and [PROJECT-CHARTER.md](./PROJECT-CHARTER.md) for intent.