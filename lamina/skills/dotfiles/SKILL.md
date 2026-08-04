---
name: dotfiles
description: >
  Work on Shawn's Personal OS Layer dotfiles (lamina + dotter). Use when the user
  mentions dotfiles, lamina, dotter, deploy, symlink configs, zsh rc.d/env.d,
  ~/.local/share/dotfiles, or asks to add/fix tooling in this repo. Triggers:
  "dotfiles", "lamina deploy", "lamina health", "add config for", "wire into dotter".
---

# Dotfiles / Lamina Agent Playbook

Repo: `~/.local/share/dotfiles` (`$XDG_DATA_HOME/dotfiles`). CLI: `~/.local/bin/lamina`.

**Do not re-audit from scratch.** Follow this playbook. Verify with `lamina deploy` + `lamina health`.

## Architecture (two layers)

| Layer | Role | Source of truth |
|-------|------|-----------------|
| **Dotter** | Symlinks repo paths → home | `.dotter/global.toml` |
| **Lamina** | Orchestration, plugins, health, update | `bin/lamina`, `lamina/*.zsh` |

Dotter runs `pre_deploy` automatically. Lamina wraps `dotter deploy` and adds zsh plugin sync + dual-link `.zshenv`.

## Repo map (what matters)

```
dotfiles/
├── .dotter/global.toml      # ALL symlink entries — edit this first
├── .dotter/pre_deploy.sh    # mkdir parents; bat/lazygit light-dark symlinks
├── configs/<app>/           # App configs → ~/.config/<app>
├── zsh/
│   ├── .zshenv              # Boot: ZDOTDIR, DOTFILES, env.d/*
│   ├── .zshrc               # rc.d/* glob + starship + version managers
│   ├── env.d/               # Exports (numbered 01_…05_)
│   └── rc.d/                # Shell behavior (numbered 000_…zzz_)
├── lamina/
│   ├── deploy.zsh           # dotter + dual-link + plugin sync
│   ├── health.zsh           # Drift checks (hardcoded lists)
│   ├── manifest.toml        # Desired-state metadata (keep in sync with health)
│   └── plugins.toml         # Zsh git plugins → ~/.zsh/plugins
└── bin/                     # Scripts symlinked to ~/.local/bin
```

**Not everything under `configs/` is deployed.** Only paths in `global.toml` are linked. Examples currently *outside* dotter: `yazi`, `GIMP`, `homebrew` (commented), `aerospace`.

## Symlink policy (dotter)

```toml
# Pure config tree — link whole directory (default)
"configs/nvim" = { target = "~/.config/nvim", type = "symbolic", recurse = false }

# App writes logs/state into ~/.config/<app>/ — link files only
"configs/btop" = { target = "~/.config/btop", type = "symbolic", recurse = true }

# Single file outside .config
"configs/tmux/tmux.conf" = "~/.tmux.conf"
```

**Rule:** If the app creates runtime files beside config (history, logs, DB), use `recurse = true` (btop, lnav). Otherwise `recurse = false`.

## Checklists

### Add a new app config

1. Put files in `configs/<app>/`
2. Add entry to `.dotter/global.toml` (pick recurse policy)
3. Add `"<app>"` to the `for cfg in …` loop in `lamina/health.zsh` (directory symlinks)
4. If single-file: add explicit `check_dotter_symlink` in health.zsh
5. Run: `lamina deploy` then `lamina health`
6. If light/dark variants: see bat/lazygit pattern below

### Add a zsh rc module

1. Create `zsh/rc.d/NNN_name.zsh` (number = load order; `000_` early, `zzz_` late)
2. No dotter change (`rc.d` is already symlinked)
3. Use `return 0` early for opt-in modules (see `600_autosuggest.zsh`)

### Add a zsh plugin

1. Add `[[plugins.repo]]` to `lamina/plugins.toml`
2. `source` from an `rc.d/*.zsh` file
3. Run `lamina deploy` (syncs clones to `~/.zsh/plugins/<dir>`)
4. Do **not** ad-hoc `git clone` unless matching existing `450_zdharma.zsh` fallback pattern

### Add a bin script

1. Add script to `bin/<name>`
2. Add `"bin/<name>" = "~/.local/bin/<name>"` to `global.toml`
3. Optionally add to `[health.required_bins]` in `manifest.toml` + `health.zsh`
4. `lamina deploy`

### Light/dark config variants (bat, lazygit)

- Store `config-light.*` and `config-dark.*` in repo
- Gitignore active symlinks: `configs/bat/config`, `configs/lazygit/config.yml`
- Extend `.dotter/pre_deploy.sh` to `ln -sf config-${variant}.*` based on `defaults read -g AppleInterfaceStyle`
- **pre_deploy repo-root detection:** walk up until `configs/bat` + `lamina` exist (dotter runs hook from `.dotter/cache/.dotter/`)
- Re-run `lamina deploy` after macOS appearance change

## Zsh boot sequence

```
~/.zshenv  (= $ZDOTDIR/.zshenv, dual-linked by deploy)
  → ZDOTDIR=~/.zsh, DOTFILES=~/.local/share/dotfiles
  → source env.d/*
  → if interactive: .zshrc → rc.d/* (glob order)
```

- `GLOBAL_RCS` is off — no system `/etc/zshrc`
- Stray `~/.zshrc` = health failure (real config is `~/.zsh/.zshrc`)
- Key env: `XDG_CONFIG_HOME`, `ZDOTDIR`, `DOTFILES`, `BTOPRC`, `NPM_CONFIG_USERCONFIG`

## Lamina commands

| Command | Use |
|---------|-----|
| `lamina deploy` | Apply symlinks + sync plugins |
| `lamina repair` | deploy + `--force` + fix copied bin scripts |
| `lamina health` | Drift/stray/plugin/symlink checks |
| `lamina diff` | `dotter deploy --dry-run -v` |
| `lamina sync-plugins` | Plugins only |
| `lamina update` | Full maintenance pipeline |

Always run `lamina health` after symlink/config changes.

## Common gotchas

1. **manifest.toml ≠ health runtime** — health lists are hardcoded in `health.zsh`; update both when changing checks.
2. **Fresh clone** — needs `.dotter/local.toml` with `packages = ["lamina"]` (gitignored per machine).
3. **Neovim/python** — `g.python3_host_prog` must use `vim.fn.expand("~/...")`, not `${HOME}`; set in `init.lua` before lazy loads.
4. **LazyVim colorscheme** — never `colorscheme` in `options.lua` before plugins load; use plugin spec + `LazyVim` opts.
5. **Configs in repo but not linked** — grep `global.toml` before assuming deploy covers a path.
6. **Stale path warnings** — health treats warnings as failures (exit 1).
7. **lazygit on macOS** — uses `~/.config/lazygit` because `XDG_CONFIG_HOME` is set in `env.d`.

## Files to edit by task type

| Task | Files |
|------|-------|
| New symlink | `.dotter/global.toml`, `lamina/health.zsh` |
| Deploy hook / mkdir | `.dotter/pre_deploy.sh` |
| Shell exports | `zsh/env.d/*.zsh` |
| Shell aliases/behavior | `zsh/rc.d/*.zsh` |
| Neovim | `configs/nvim/lua/**` |
| Gitignore runtime artifacts | `.gitignore` (btop logs, lnav DB, bat/lazygit active config) |

## Verification (agent must run)

```bash
cd ~/.local/share/dotfiles
lamina deploy
lamina health
```

For dotter-only preview: `lamina diff`.

## What not to do

- Don't tell the user to run commands you can run yourself.
- Don't symlink into `~/.config` manually — use dotter.
- Don't add `${HOME}` in Neovim lua paths.
- Don't assume all of `configs/` is deployed.
- Don't create markdown docs unless the user asks.

## Grok cross-session memory

| What | Where |
|------|-------|
| Live memory | `~/.grok/memory/MEMORY.md` + workspace dirs |
| Seed (git) | `lamina/grok/MEMORY.seed.md` — copied on deploy if global MEMORY.md missing |
| Enable hook | `lamina/hooks/bootstrap-grok-memory.zsh` (runs on `lamina deploy`) |

User habits: `/remember`, `/flush` at end of good sessions, `/memory` to browse.

## Canonical location

This file lives in git at `lamina/skills/dotfiles/SKILL.md`. `lamina deploy` symlinks it to `~/.grok/skills/dotfiles/` for Grok auto-load. **Edit the repo copy**, not `~/.grok` directly.

Quick ref: `lamina/AGENTS.md`