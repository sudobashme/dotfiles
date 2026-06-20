#!/usr/bin/env zsh
# Homebrew update helpers for lamina update

lamina_update_brewfile_path() {
    print -r -- "${DOTFILES}/configs/homebrew/homebrew_bundle_file"
}

lamina_update_brew_bin() {
    command -v brew 2>/dev/null || print -r -- /opt/homebrew/bin/brew
}

__lamina_brewfile_dump__() {
    local bundle_file
    bundle_file="$(lamina_update_brewfile_path)"
    export HOMEBREW_BUNDLE_FILE="${bundle_file}"

    if [[ ! -d "$(dirname "${bundle_file}")" ]]; then
        lamina_warn "Brewfile directory missing — skipping dump"
        return 0
    fi

    cp -f "${bundle_file}"{,.bak} 2>/dev/null || true
    rm -f "${bundle_file}"

    if brew bundle dump --force --describe; then
        rm -f "${bundle_file}.bak"
        if git -C "${DOTFILES}" diff --quiet -- "${bundle_file}" 2>/dev/null; then
            lamina_ok "Brewfile unchanged"
        else
            lamina_warn "Brewfile changed — commit: git -C ${DOTFILES} add ${bundle_file}"
        fi
    else
        if [[ -f "${bundle_file}.bak" ]]; then
            mv -f "${bundle_file}.bak" "${bundle_file}"
        fi
        return 1
    fi
}

__lamina_brew_update__() {
    local brew_bin
    brew_bin="$(lamina_update_brew_bin)"
    [[ -x "${brew_bin}" ]] || { lamina_warn "Homebrew not found"; return 0; }

    export HOMEBREW_BUNDLE_FILE="$(lamina_update_brewfile_path)"
    export HOMEBREW_HISTORY_FILE="${HOMEBREW_HISTORY_FILE:-${HOME}/.homebrew_history}"

    "${brew_bin}" update 2>&1 | tee -a "${HOMEBREW_HISTORY_FILE}"
    "${brew_bin}" upgrade 2>&1 | tee -a "${HOMEBREW_HISTORY_FILE}"
    "${brew_bin}" autoremove 2>&1 | tee -a "${HOMEBREW_HISTORY_FILE}" || true
    __lamina_brewfile_dump__
}