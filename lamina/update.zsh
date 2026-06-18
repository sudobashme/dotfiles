#!/usr/bin/env zsh
set -euo pipefail

DOTFILES="$(lamina_dotfiles)" || exit 1

typeset -i CHECK=0 FULL=0 NO_PULL=0 NO_NVIM=0 SKIP_HEALTH=0
typeset -i failures=0

while (( $# > 0 )); do
    case "${1}" in
        --check) CHECK=1 ;;
        --full) FULL=1 ;;
        --no-pull) NO_PULL=1 ;;
        --no-nvim) NO_NVIM=1 ;;
        --no-health) SKIP_HEALTH=1 ;;
        -h|--help)
            cat <<'EOF'
lamina update — sync dotfiles, deploy, and optional platform upgrades

Usage:
  lamina update [--check] [--full] [--no-pull] [--no-nvim] [--no-health]

Modes:
  (default)   git pull (if clean) → deploy → Lazy sync → TSUpdate
  --full      + Homebrew, Xcode CLT check, npm global, MasonUpdate
  --check     Print planned steps without running them

Options:
  --no-pull   Skip git pull
  --no-nvim   Skip Neovim / Lazy / treesitter / mason steps
  --no-health Skip lamina health at the end

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

__lamina_brewfile_dump__() {
    [[ -n "${HOMEBREW_BUNDLE_FILE:-}" && -f "${HOMEBREW_BUNDLE_FILE}" ]] || return 0
    cp -f "${HOMEBREW_BUNDLE_FILE}"{,.bak}
    rm -f "${HOMEBREW_BUNDLE_FILE}"
    if brew bundle dump; then
        rm -f "${HOMEBREW_BUNDLE_FILE}.bak"
    else
        mv -f "${HOMEBREW_BUNDLE_FILE}"{.bak,} 2>/dev/null || true
        return 1
    fi
}

__lamina_brew_update__() {
    local brew_bin
    brew_bin="$(command -v brew 2>/dev/null || print -r -- /opt/homebrew/bin/brew)"
    [[ -x "${brew_bin}" ]] || { lamina_warn "Homebrew not found"; return 0; }
    "${brew_bin}" update 2>&1 | tee -a "${HOMEBREW_HISTORY_FILE:-/dev/null}"
    "${brew_bin}" upgrade 2>&1 | tee -a "${HOMEBREW_HISTORY_FILE:-/dev/null}"
    __lamina_brewfile_dump__
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

__lamina_npm_update__() {
    command npm update -g && npm fund
}

print -r -- "lamina update — ${DOTFILES}"
if (( CHECK )); then
    print -r -- "lamina update — check mode (no changes)"
fi
if (( FULL )); then
    print -r -- "lamina update — full mode"
fi

lamina_update_run "git pull (ff-only if working tree clean)" __lamina_git_pull__
lamina_update_run "lamina deploy (symlinks + zsh plugins)" __lamina_deploy__

if (( ! NO_NVIM )) && command -v nvim >/dev/null 2>&1; then
    lamina_update_run "Neovim Lazy sync" __lamina_nvim_lazy_sync__
    lamina_update_run "Neovim TSUpdate" __lamina_nvim_tsupdate__
    if (( FULL )); then
        lamina_update_run "Neovim MasonUpdate" __lamina_nvim_mason_update__
    fi
elif (( ! NO_NVIM )); then
    lamina_warn "nvim not found — skipping editor updates"
fi

if (( FULL )); then
    lamina_update_run "Xcode / CLT check" __lamina_xcode_update__
    if command -v brew >/dev/null 2>&1; then
        lamina_update_run "Homebrew update + upgrade + Brewfile dump" __lamina_brew_update__
    fi
    if command -v npm >/dev/null 2>&1; then
        lamina_update_run "npm global update" __lamina_npm_update__
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