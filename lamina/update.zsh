#!/usr/bin/env zsh
set -euo pipefail

DOTFILES="$(lamina_dotfiles)" || exit 1
export DOTFILES

source "${DOTFILES}/lamina/lib/update-brew.zsh"
source "${DOTFILES}/lamina/lib/update-envs.zsh"

typeset -i CHECK=0 QUICK=0 INSTALL_LATEST=0
typeset -i NO_PULL=0 NO_NVIM=0 NO_BREW=0 NO_ENVS=0 NO_PACKAGES=0 SKIP_HEALTH=0
typeset -i failures=0

while (( $# > 0 )); do
    case "${1}" in
        --check) CHECK=1 ;;
        --quick) QUICK=1 ;;
        --full) ;;  # backward compat; comprehensive is now the default
        --install-latest) INSTALL_LATEST=1 ;;
        --no-pull) NO_PULL=1 ;;
        --no-nvim) NO_NVIM=1 ;;
        --no-brew) NO_BREW=1 ;;
        --no-envs) NO_ENVS=1 ;;
        --no-packages) NO_PACKAGES=1 ;;
        --no-health) SKIP_HEALTH=1 ;;
        -h|--help)
            cat <<'EOF'
lamina update — keep dotfiles, platform, runtimes, and packages current

Usage:
  lamina update [options]

Default (comprehensive):
  git pull → deploy → Neovim → Homebrew (+ Brewfile dump) → version-manager
  definitions → pip/gem/npm → health

Options:
  --quick           Dotfiles + deploy + Neovim only (fast path)
  --install-latest  Also compile/install latest stable pyenv/nodenv/rbenv/luaenv/goenv
  --check           Print planned steps without running them

Skip flags:
  --no-pull         Skip git pull
  --no-nvim         Skip Neovim / Lazy / treesitter / mason
  --no-brew         Skip Homebrew update/upgrade/Brewfile dump
  --no-envs         Skip version-manager definition refresh
  --no-packages     Skip pip/gem/npm package upgrades
  --no-health       Skip lamina health at the end

Legacy:
  --full            No-op (comprehensive update is now the default)

See: docs/personal-os-layer/UPDATE-STRATEGY.md
EOF
            exit 0
            ;;
        *)
            print -u2 "lamina update: unknown option: ${1}"
            exit 1
            ;;
    esac
    shift
done

lamina_update_banner() {
    print -r -- ""
    print -r -- "▸ $*"
}

lamina_update_run() {
    local label="$1"
    shift
    if (( CHECK )); then
        print -r -- "  → ${label}"
        return 0
    fi
    lamina_update_banner "${label}"
    if "$@"; then
        lamina_ok "${label}"
    else
        lamina_fail "${label}"
        failures+=1
    fi
}

__lamina_git_pull__() {
    if (( NO_PULL )); then
        lamina_ok "git pull skipped (--no-pull)"
        return 0
    fi
    if ! command -v git >/dev/null 2>&1; then
        lamina_warn "git not found — skipping pull"
        return 0
    fi
    if [[ -n "$(git -C "${DOTFILES}" status --porcelain 2>/dev/null)" ]]; then
        lamina_warn "uncommitted changes in ${DOTFILES} — skipping git pull"
        return 0
    fi
    git -C "${DOTFILES}" pull --ff-only
}

__lamina_deploy__() {
    LAMINA_DEPLOY_MODE=deploy source "${DOTFILES}/lamina/deploy.zsh"
}

__lamina_xcode_update__() {
    if [[ "$(uname -s)" != Darwin ]]; then
        return 0
    fi
    if ! command -v xcode-select >/dev/null 2>&1; then
        lamina_warn "xcode-select not found"
        return 0
    fi
    if ! xcode-select -p >/dev/null 2>&1; then
        print -r -- "  Installing Command Line Tools..."
        xcode-select --install 2>/dev/null || true
        return 0
    fi
    local updates
    updates="$(softwareupdate --list 2>&1)" || true
    if echo "${updates}" | grep -qi "no updates available"; then
        lamina_ok "no macOS software updates"
        return 0
    fi
    print -r -- "  Software updates available — run: sudo softwareupdate --install --all"
    lamina_warn "skipped automatic softwareupdate (requires sudo)"
}

__lamina_nvim_lazy_sync__() {
    command nvim --headless "+Lazy! sync" +qa 2>/dev/null
}

__lamina_nvim_tsupdate__() {
    command nvim --headless "+Lazy! load nvim-treesitter" "+TSUpdate" +qa 2>/dev/null
}

__lamina_nvim_mason_update__() {
    command nvim --headless "+Lazy! load mason.nvim" "+MasonUpdate" +qa 2>/dev/null
}

print -r -- "lamina update — ${DOTFILES}"
if (( CHECK )); then
    print -r -- "lamina update — check mode (no changes)"
fi
if (( QUICK )); then
    print -r -- "lamina update — quick mode"
fi
if (( INSTALL_LATEST )); then
    print -r -- "lamina update — will install latest stable runtimes"
fi

lamina_update_run "git pull (ff-only if working tree clean)" __lamina_git_pull__
lamina_update_run "lamina deploy (symlinks + zsh plugins)" __lamina_deploy__

if (( ! NO_NVIM )) && command -v nvim >/dev/null 2>&1; then
    lamina_update_run "Neovim Lazy sync" __lamina_nvim_lazy_sync__
    lamina_update_run "Neovim TSUpdate" __lamina_nvim_tsupdate__
    if (( ! QUICK )); then
        lamina_update_run "Neovim MasonUpdate" __lamina_nvim_mason_update__
    fi
elif (( ! NO_NVIM )); then
    lamina_warn "nvim not found — skipping editor updates"
fi

if (( ! QUICK )); then
    lamina_update_run "Xcode / CLT check" __lamina_xcode_update__

    if (( ! NO_BREW )); then
        local brew_bin
        brew_bin="$(lamina_update_brew_bin)"
        if [[ -x "${brew_bin}" ]]; then
            lamina_update_run "Homebrew update + upgrade + Brewfile dump" __lamina_brew_update__
        else
            lamina_warn "brew not found — skipping Homebrew"
        fi
    fi

    if (( ! NO_ENVS )); then
        lamina_update_run "version-manager build definitions (pyenv/nodenv/rbenv/luaenv/goenv)" __lamina_envs_refresh_definitions__
        if (( INSTALL_LATEST )); then
            lamina_update_run "install latest stable runtimes (does not change global)" __lamina_envs_install_latest__
        fi
    fi

    if (( ! NO_PACKAGES )); then
        lamina_update_run "pip (active python)" __lamina_pip_update__
        lamina_update_run "gem (active ruby)" __lamina_gem_update__
        if command -v npm >/dev/null 2>&1; then
            lamina_update_run "npm global update" __lamina_npm_global_update__
            lamina_update_run "npm local update (~/.node_modules)" __lamina_npm_local_update__
        fi
    fi
fi

if (( ! CHECK && ! SKIP_HEALTH )); then
    lamina_update_banner "lamina health"
    if "${DOTFILES}/bin/lamina" health; then
        :
    else
        failures+=1
    fi
fi

print -r -- ""
if (( CHECK )); then
    print -r -- "lamina update — check complete"
    exit 0
fi

if (( failures > 0 )); then
    print -r -- "lamina update — finished with ${failures} failure(s)"
    exit 1
fi

print -r -- "lamina update — done"
exit 0