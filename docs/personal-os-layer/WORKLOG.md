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

## Earlier history

Pre-2026 work (lamina scaffold, personal-os-layer charter, zsh modularization, OpenClaw integration doc) predates this worklog. See git history and [PROJECT-CHARTER.md](./PROJECT-CHARTER.md) for intent.