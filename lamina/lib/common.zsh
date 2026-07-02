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

lamina_color_enabled() {
    [[ -z "${NO_COLOR:-}" && -t 1 ]]
}

lamina_header() {
    local cmd="$1" detail="${2:-}"
    if lamina_color_enabled; then
        print -P "%B%F{6}lamina ${cmd}%f%b %F{8}—%f ${detail}"
    else
        print -r -- "lamina ${cmd} — ${detail}"
    fi
}

lamina_note() {
    if lamina_color_enabled; then
        print -P "%F{8}$*%f"
    else
        print -r -- "$*"
    fi
}

lamina_section() {
    if lamina_color_enabled; then
        print -P "%B%F{4}$*%f%b"
    else
        print -r -- "$*"
    fi
}

lamina_banner() {
    if lamina_color_enabled; then
        print -r -- ""
        print -P "%F{6}▸%f %B$*%b"
    else
        print -r -- ""
        print -r -- "▸ $*"
    fi
}

lamina_step() {
    if lamina_color_enabled; then
        print -P "%F{4}  →%f $*"
    else
        print -r -- "  → $*"
    fi
}

lamina_ok() {
    if lamina_color_enabled; then
        print -P "%F{2}  ✓%f $*"
    else
        print -r -- "  ✓ $*"
    fi
}

lamina_warn() {
    if lamina_color_enabled; then
        print -P "%F{3}  ⚠%f $*"
    else
        print -r -- "  ⚠ $*"
    fi
}

lamina_fail() {
    if lamina_color_enabled; then
        print -P "%F{1}  ✗%f $*"
    else
        print -r -- "  ✗ $*"
    fi
}

lamina_summary_ok() {
    if lamina_color_enabled; then
        print -P "%B%F{2}$*%f%b"
    else
        print -r -- "$*"
    fi
}

lamina_summary_fail() {
    if lamina_color_enabled; then
        print -P "%B%F{1}$*%f%b"
    else
        print -r -- "$*"
    fi
}

lamina_need_cmd() {
    local cmd="$1"
    if (( ! ${+commands[$cmd]} )); then
        if lamina_color_enabled; then
            print -u2 -P "%F{1}lamina:%f required command not found: %B${cmd}%b"
        else
            print -u2 "lamina: required command not found: ${cmd}"
        fi
        return 1
    fi
}