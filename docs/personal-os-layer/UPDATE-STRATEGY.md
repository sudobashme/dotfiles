# Update Strategy — Personal OS Layer

How this environment stays current **intentionally** — not "run a script and hope."

**Last updated:** 2026-06-17

---

## Principles

1. **Git is source of truth** for config (dotfiles repo). Machines pull; they don't drift silently.
2. **Layered updates** — platform, packages, plugins, and docs are separate steps with different cadences.
3. **Document when you ship** — code changes without `WORKLOG.md` / `GAME-PLAN.md` updates are incomplete work.
4. **Verify after update** — `lamina health` (growing) + targeted smoke tests, not blind upgrades.

---

## Cadence Overview

| Layer | How often | Command / action |
|-------|-----------|------------------|
| Dotfiles config | When you change something | `git pull` → `lamina deploy` |
| Project docs | Same commit as meaningful work | Edit `WORKLOG.md`, `GAME-PLAN.md` |
| macOS / CLT | Monthly or when prompted | `update` (xcode section) |
| Homebrew | Weekly–monthly | `update` or `brew upgrade` |
| Neovim plugins | Weekly or after config edits | `lu` or `Lazy sync` |
| Tree-sitter parsers | After plugin/neovim bumps | `:TSUpdate` |
| Mason LSP/tools | When adding formatters/linters | `:Mason` / `:MasonUpdate` |
| Dotfyle metadata | After plugin add/remove | `:DotfyleGenerate` → commit `dotfyle.json` |
| Zsh plugins | After `lamina/plugins.toml` edit | `lamina deploy` (runs sync hook) |
| npm global | Occasional | `update` (npm section) |

---

## Workflows

### A. Daily driver — "something broke after pulls"

```bash
cd ~/.local/share/dotfiles   # or $DOTFILES
git pull
lamina deploy
lamina health                # when checks exist for what you changed
```

Reload shell (`exec zsh`) or restart Neovim if symlinks/plugins changed.

### B. Routine maintenance — `update` / `up`

Defined in `zsh/rc.d/800_update.zsh`. Runs:

1. Xcode / Command Line Tools (`softwareupdate`)
2. Homebrew `update` + `upgrade` + Brewfile re-dump
3. Neovim `Lazy! sync` (headless)
4. npm global update

```bash
update    # or: up
```

**Gaps today (known):** `update` does not run `TSUpdate`, `MasonUpdate`, `lamina deploy`, or `git pull`. Those stay manual until Phase 2 folds them into lamina.

### C. Neovim plugin / config change (you edit `configs/nvim/`)

1. Edit `lua/plugins/*.lua` (or LazyVim extras in `lazyvim.json`)
2. In Neovim: `:Lazy sync` (or `lu` from shell)
3. If parsers complain: `:TSUpdate`
4. If new Mason tool: `:Mason` → install; add to `lua/plugins/mason.lua` `ensure_installed` if pinned
5. If plugins added/removed: `:DotfyleGenerate`
6. Commit: `lazy-lock.json`, `dotfyle.json`, plugin lua files
7. Update `WORKLOG.md` + `GAME-PLAN.md` if it's sprint-level work

### D. New machine / repair

```bash
./deploy.zsh --install       # full bootstrap (still brittle — see GAME-PLAN Phase 2)
# or, on existing machine:
lamina deploy
lamina deploy --repair       # LAMINA_DEPLOY_MODE=repair for bin symlink repair
```

`deploy.zsh` also runs `Lazy sync` and `TSUpdate` at end of install — heavier than day-to-day `update`.

### E. Documentation-only change

```bash
# edit docs/personal-os-layer/*.md
git add docs/personal-os-layer/
git commit -m "docs: ..."
git push
```

No deploy step required.

---

## What to commit after updates

| Change type | Files to commit |
|-------------|-----------------|
| Lazy plugin versions | `configs/nvim/lazy-lock.json` |
| Plugin inventory | `configs/nvim/dotfyle.json` (via DotfyleGenerate) |
| Homebrew packages | `configs/homebrew/homebrew_bundle_file` (auto-dumped by `update`) |
| Zsh plugins | `lamina/plugins.toml` + lock if added later |
| Yazi flavor/plugin | under `configs/yazi/` |
| Sprint / phase progress | `GAME-PLAN.md`, `WORKLOG.md` |

---

## Post-update verification checklist

**Shell**
- [ ] `lamina health` — no new failures
- [ ] New shell session — prompt, completions, tmux integration OK

**Neovim**
- [ ] `:checkhealth` — no new errors in touched plugins
- [ ] Open representative buffers (md, norg, ts, py) — LSP + format on save

**Yazi**
- [ ] Launch from nvim — flavor loads, no TOML errors

---

## Roadmap — unify into `lamina update` (Phase 2)

Today update logic is split across `update()`, `deploy.zsh`, and manual Neovim commands. Target shape:

```bash
lamina update              # safe routine: git pull, deploy, lazy sync, TSUpdate
lamina update --full       # + brew, mason, npm (opt-in heavy)
lamina update --check      # dry-run / report only
```

Until then, use this doc + `update` + manual Neovim steps above.

---

## Related docs

- [GAME-PLAN.md](./GAME-PLAN.md) — what's done / what's next
- [WORKLOG.md](./WORKLOG.md) — what shipped and when
- [ARCHITECTURE-SKETCH.md](./ARCHITECTURE-SKETCH.md) — layer model (deploy + diagnostics)
- [DIAGNOSTICS-VISION.md](./DIAGNOSTICS-VISION.md) — health checks after updates