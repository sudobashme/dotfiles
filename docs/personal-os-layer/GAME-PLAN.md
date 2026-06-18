# Game Plan — Personal OS Layer

Living agenda for the project. Update this when a sprint lands or priorities shift.

**Last updated:** 2026-06-17

---

## Phase 0 — Editor Cohesion Sprint ✅ (Jun 2026)

Stabilize the Neovim layer so it behaves like a first-class part of the Personal OS (health checks pass, no plugin fights, dotfyle accurate).

| Item | Status | Notes |
|------|--------|-------|
| Neorg loader + tree-sitter deps | ✅ Done | Removed `luarocks.nvim`; explicit `tree-sitter-norg` / `norg-meta` deps |
| Biome formatting | ✅ Done | `conform.nvim` prefers `biome-check`, falls back to `prettierd` |
| Neoconf bridge | ✅ Done | `neoconf.lua` + `neoconf.json`; `before_init` on jsonls/lua_ls |
| Yazi catppuccin flavor | ✅ Done | Removed invalid `{ name = "*" }` rules from `flavor.toml` |
| Duplicate keymaps | ✅ Done | Removed misplaced `keys` block from `nvim-lspconfig.lua`; `which-key.lua` filters `<Plug>` maps |
| render-markdown conflicts | ✅ Done | Obsidian `ui.enable = false` moved into `opts`; snacks `image.math` disabled |
| Dotfyle sync | ✅ Done | `:DotfyleGenerate`, committed + pushed (`bcb779a`) |

### Smoke tests (user verification)

- [ ] Open a `.norg` file — parsing + keybinds work
- [ ] Open an Obsidian vault `.md` — render-markdown renders; toggle `<leader>um`
- [ ] Launch Yazi from Neovim — catppuccin flavor loads
- [ ] Save a JS/TS file — Biome or prettierd formats

### Optional follow-ups (only if something feels off)

- [ ] Drop `norg` from render-markdown `ft` if Neorg + render-markdown fight on `.norg` buffers
- [ ] Re-enable partial Obsidian UI if render-markdown alone isn't enough for vault notes

---

## Phase 1 — Self-Awareness (Diagnostics) 🎯 **Next major focus**

Per [DIAGNOSTICS-VISION.md](./DIAGNOSTICS-VISION.md) and [PROJECT-CHARTER.md](./PROJECT-CHARTER.md): build LazyHealth-quality diagnostics for the terminal + deploy stack.

| Item | Status | Notes |
|------|--------|-------|
| Lamina `health` command | 🟡 Started | `lamina/health.zsh` — symlink/bin/stray-path checks |
| Replace OMZ diag dump | ⬜ Not started | Current `omz_diagnostic_dump` is high-volume, low-signal |
| Actionable, categorized output | ⬜ Not started | OK / warn / fail with fix hints (like `:checkhealth`) |
| Component registration | ⬜ Not started | zsh, deploy, nvim, yazi, starship each contribute checks |
| Shell prompt health surfacing | ⬜ Not started | e.g. `lamina health --brief` in starship or dedicated command |

**Exit criteria:** Running `lamina health` tells you what's wrong *and* what to do — not just a data dump.

---

## Phase 2 — Deployment / Bootstrap

| Item | Status | Notes |
|------|--------|-------|
| Lamina deploy CLI | 🟡 Started | `bin/lamina`, `lamina/deploy.zsh`, `manifest.toml` |
| Update strategy doc | ✅ Done | [UPDATE-STRATEGY.md](./UPDATE-STRATEGY.md) — cadence + gaps documented |
| `lamina update` command | ✅ Done | `lamina/update.zsh`; `up` → `lamina update --full` |
| VM deploy sandbox (Tart) | ✅ Scaffold | `lamina vm-test` + Brewfile; run `setup-base` once |
| Declarative desired state | ⬜ Not started | Single source of truth for packages, symlinks, plugins |
| `deploy.zsh` retirement / shrink | ⬜ Not started | Large imperative script; hard to trust on fresh machine |
| Fresh-machine bootstrap test | 🟡 Planned | Tart VM Phase B; `deploy-testing.zsh` is interim |

---

## Phase 3 — Shell Layer Re-founding

| Item | Status | Notes |
|------|--------|-------|
| Beyond OMZ-derivative patterns | ⬜ Not started | See [CURRENT-STATE.md](./CURRENT-STATE.md) |
| zsh autosuggest / prompt stability | 🟡 Recent | Prompt/backspace fix in `zsh/rc.d/000_tmux.zsh` (Jun 2026) |
| Cohesion with editor + yazi | ⬜ Not started | Same "family" feel as LazyVim health UX |

---

## Phase 4 — Integrations & Future

| Item | Status | Notes |
|------|--------|-------|
| OpenClaw bridge | 🟡 Documented | [OPENCLAW-INTEGRATION.md](./OPENCLAW-INTEGRATION.md) — blocked on xAI API credits for TUI |
| Editor ↔ shell health bridge | ⬜ Idea | `:PersonalHealth` or nvim command surfacing `lamina health` |
| Window management | ⬜ Out of scope | Per charter, unless clearly needed |

---

## How to use this doc

1. **Starting a session** — read Phase 0 smoke tests + current phase table.
2. **Finishing work** — mark items done, add a line to [WORKLOG.md](./WORKLOG.md), bump "Last updated".
3. **Changing priorities** — edit phase order here; don't let stale docs lie.
4. **Updating the machine** — follow [UPDATE-STRATEGY.md](./UPDATE-STRATEGY.md) (not just `git pull`).