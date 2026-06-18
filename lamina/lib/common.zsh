#!/usr/bin/env zsh

lamina_root() {
    # bin/lamina -> repo root; also works when invoked as ~/.local/bin/lamina
    local script="${1:-${0:A}}"
    if [[ "${script:t}" == lamina && "${script:h:t}" == bin ]]; then
        print -r -- "${script:h:h}"
        return 0
    fi
    if [[ -d "${HOME}/.local/share/dotfiles/lamina" ]]; then
        print -r -- "${HOME}/.local/share/dotfiles"
        return 0
    fi
    print -u2 "lamina: cannot locate dotfiles repository"
    return 1
}

lamina_dotfiles() {
    # Prefer caller context (bin/lamina sets DOTFILES/LAMINA_BIN before sourcing)
    if [[ -n "${DOTFILES:-}" && -d "${DOTFILES}/lamina" ]]; then
        print -r -- "${DOTFILES}"
        return 0
    fi
    if [[ -n "${LAMINA_BIN:-}" ]]; then
        lamina_root "${LAMINA_BIN}"
        return $?
    fi
    lamina_root "${1:-}"
}

lamina_expand() {
    local path="${1}"
    path="${path/#\~/$HOME}"
    print -r -- "${path}"
}

lamina_ok() {
    print -r -- "  ✓ $*"
}

lamina_warn() {
    print -r -- "  ⚠ $*"
}

lamina_fail() {
    print -r -- "  ✗ $*"
}

lamina_need_cmd() {
    local cmd="$1"
    if (( ! ${+commands[$cmd]} )); then
        print -u2 "lamina: required command not found: ${cmd}"
        return 1
    fi
}