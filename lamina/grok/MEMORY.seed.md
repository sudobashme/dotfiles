# Global memory (seed)

Curated facts for Grok across all projects. Grows via `/remember`, `/flush`, and `/dream`.
Lamina seeds this file on deploy only when `~/.grok/memory/MEMORY.md` does not exist yet.

## Preferences

- Run commands and investigate yourself; do not hand the user a todo list of shell steps.
- Prefer concise, well-structured prose — complete sentences, not telegraphic shorthand.
- Use code citation blocks (`startLine:endLine:path`) when referencing existing code.
- Match existing code style; minimal diffs; no drive-by refactors.
- Personal machine / Personal OS Layer context — not work-corporate environments.

## Personal OS Layer (lamina)

- Dotfiles repo: `~/.local/share/dotfiles` (`$XDG_DATA_HOME/dotfiles`)
- Deploy: `lamina deploy` then `lamina health`
- Symlinks: `.dotter/global.toml` (dotter); health checks in `lamina/health.zsh`
- Zsh: `ZDOTDIR=~/.zsh`; boot `.zshenv` → `env.d/*` → `rc.d/*`; no stray `~/.zshrc`
- Agent playbook in git: `lamina/skills/dotfiles/SKILL.md` → `~/.grok/skills/dotfiles/`

## Neovim (LazyVim)

- Config: `configs/nvim/` → `~/.config/nvim`
- `g.python3_host_prog` must use `vim.fn.expand("~/...")` — Neovim does not expand `${HOME}`
- Set provider paths in `init.lua` before `require("config.lazy")`
- Colorscheme bluloco: plugin spec + `LazyVim` opts — never `colorscheme` in `options.lua` before plugins load
- Neorg conflicts: use `\no` (TOC) and `\ts` (cycle task) in `.norg` buffers — not `gO` or `<C-Space>`

## Memory layers (do not confuse)

| Layer | Location | Purpose |
|-------|----------|---------|
| Lamina/dotfiles | git repo | Machine config, deploy playbooks, skills |
| Grok memory | `~/.grok/memory/` | Cross-session facts for Grok (this file) |
| OpenBrain | optional MCP | Not set up; only if cross-tool memory needed later |

## Habits

- End productive sessions with `/flush` before closing Grok.
- Say "remember …" or `/remember` for durable preferences.
- After dotfiles changes: `lamina deploy && lamina health`.