#!/usr/bin/env zsh
# repo: https://github.com/sudobashme/dotfiles
# file: 650_update.zsh
# filepath: ${ZDOTDIR}/rc.d/650_update.zsh

# Routine system update — delegates to lamina when available.
# See: docs/personal-os-layer/UPDATE-STRATEGY.md

update() {
    local lamina_bin
    lamina_bin="$(command -v lamina 2>/dev/null || true)"
    if [[ -n "${lamina_bin}" && -x "${lamina_bin}" ]]; then
        "${lamina_bin}" update "$@"
        return $?
    fi

    print -P "%F{red}lamina not found — install dotfiles bin symlinks first%F{reset}" >&2
    return 1
}

alias up=update

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# nvim: ft=zsh
# EOF