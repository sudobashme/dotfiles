# Agent instructions (Grok / Cursor)

**Canonical playbook (in git):** `lamina/skills/dotfiles/SKILL.md`

Deployed to `~/.grok/skills/dotfiles/SKILL.md` via `lamina deploy` so Grok auto-loads it.

## 30-second orientation

- **Repo:** `~/.local/share/dotfiles`
- **Symlinks:** `.dotter/global.toml` (dotter)
- **Deploy:** `lamina deploy` → `lamina health`
- **Configs:** `configs/<app>/` → `~/.config/<app>` (only if listed in global.toml)
- **Zsh:** `zsh/.zshenv` → `env.d/*` → `rc.d/*`

## Add config checklist

1. `configs/<app>/`
2. `.dotter/global.toml`
3. `lamina/health.zsh` (directory loop or explicit check)
4. `lamina deploy && lamina health`

## Source-of-truth priority

1. `.dotter/global.toml` — what gets linked
2. `lamina/health.zsh` — what gets verified
3. `lamina/manifest.toml` — desired state (keep in sync; not fully wired yet)

## Machine rebuild

```bash
git clone <dotfiles-remote> ~/.local/share/dotfiles
cd ~/.local/share/dotfiles
# ensure .dotter/local.toml exists: packages = ["lamina"]
lamina deploy && lamina health
```

That restores configs, zsh, bin scripts, the Grok dotfiles skill, and seeds Grok memory if missing.

## Grok memory

- Enabled via `lamina deploy` → `lamina/hooks/bootstrap-grok-memory.zsh`
- Live store: `~/.grok/memory/MEMORY.md` (grows with `/remember`, `/flush`, `/dream`)
- Seed template (git): `lamina/grok/MEMORY.seed.md` — copied only when global MEMORY.md absent
- Config: `[memory] enabled = true` appended to `~/.grok/config.toml` if missing