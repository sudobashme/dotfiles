#!/usr/bin/env zsh
set -euo pipefail

LAMINA_CMD="${0}"
DOTFILES="$(lamina_root "${LAMINA_CMD}")" || exit 1

export DOTFILES
export ZDOTDIR="${ZDOTDIR:-${HOME}/.zsh}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"

lamina_need_cmd dotter || exit 1
zmodload zsh/files 2>/dev/null || true

print -r -- "lamina deploy — ${DOTFILES}"

# Prerequisites (dotter pre_deploy.sh also runs, but be explicit)
zf_mkdir -p \
    "${ZDOTDIR}" \
    "${XDG_CONFIG_HOME}" \
    "${HOME}/.local/bin" \
    "${XDG_CACHE_HOME}/zsh" \
    "${HOME}/.tmux"

# Symlinks via dotter (forward extra args, e.g. --dry-run, --force)
typeset -a dotter_args
dotter_args=("$@")

# Replace copied bin scripts with symlinks when repairing
if [[ "${LAMINA_DEPLOY_MODE:-}" == repair ]]; then
    for binpath in "${HOME}/.local/bin/launch-os-layer" "${HOME}/.local/bin/grok-acp"; do
        if [[ -e "${binpath}" && ! -L "${binpath}" ]]; then
            print -r -- "lamina: replacing copied file with symlink: ${binpath}"
            zf_rm -f "${binpath}"
        fi
    done
    if (( ! ${dotter_args[(I)--force]} )); then
        dotter_args+=(--force)
    fi
fi

(
    cd "${DOTFILES}" || exit 1
    dotter deploy "${dotter_args[@]}"
)

# Dual-link .zshenv into ZDOTDIR (dotter handles ~/.zshenv)
zf_ln -sf "${DOTFILES}/zsh/.zshenv" "${ZDOTDIR}/.zshenv"

print -r -- "lamina deploy — done"