#!/usr/bin/env zsh
set -euo pipefail

LAMINA_CMD="${0}"
DOTFILES="$(lamina_root "${LAMINA_CMD}")" || exit 1
export ZDOTDIR="${ZDOTDIR:-${HOME}/.zsh}"

typeset -i issues=0

check_stray_file() {
    local path="$1" reason="$2"
    if [[ -e "${path}" || -L "${path}" ]]; then
        lamina_fail "stray ${path} — ${reason}"
        issues+=1
    else
        lamina_ok "no stray ${path}"
    fi
}

check_stale_path() {
    local path="$1" reason="$2"
    if [[ -e "${path}" || -d "${path}" ]]; then
        lamina_warn "stale ${path} — ${reason}"
        issues+=1
    else
        lamina_ok "no stale ${path}"
    fi
}

check_required_bin() {
    local name="$1" path="$2"
    path="$(lamina_expand "${path}")"
    if [[ -x "${path}" ]]; then
        if [[ -L "${path}" ]]; then
            lamina_ok "${name} → ${path:A}"
        else
            lamina_ok "${name} (executable at ${path})"
        fi
    else
        lamina_fail "missing ${name} at ${path}"
        issues+=1
    fi
}

check_dotter_symlink() {
    local source_rel="$1" target="$2"
    local source="${DOTFILES}/${source_rel}"
    target="$(lamina_expand "${target}")"

    if [[ ! -e "${source}" ]]; then
        lamina_fail "source missing: ${source_rel}"
        issues+=1
        return
    fi

    if [[ -L "${target}" ]]; then
        if [[ "${target:A}" == "${source:A}" ]]; then
            lamina_ok "${target} → ${source_rel}"
        else
            lamina_fail "${target} → ${target:A} (expected ${source})"
            issues+=1
        fi
    elif [[ -e "${target}" ]]; then
        lamina_fail "${target} exists but is not a symlink to dotfiles"
        issues+=1
    else
        lamina_fail "missing symlink ${target}"
        issues+=1
    fi
}

print -r -- "lamina health — ${DOTFILES}"
print -r -- ""

print -r -- "Stray files"
check_stray_file "${HOME}/.zshrc" "installer wrote a real ~/.zshrc; ZDOTDIR owns config"
print -r -- ""

print -r -- "Stale artifacts"
check_stale_path "${HOME}/.zsh/plugins/powerlevel10k" "replaced by starship"
check_stale_path "${HOME}/.zsh/plugins/archive" "legacy broken URL"
check_stale_path "${HOME}/.zsh/plugins/iterm2-shell-integration" "not in rc.d"
check_stale_path "${HOME}/.zsh/plugins/autocomplete" "disabled in rc.d/720_autosuggest.zsh"
check_stale_path "${HOME}/.zsh/plugins/zsh-zoxide" "redundant; use zoxide init in .zshrc"
check_stale_path "${HOME}/.colima" "removed; Tart (lamina vm-test) is the VM stack"
check_stale_path "${HOME}/.lima" "removed; Tart (lamina vm-test) is the VM stack"
print -r -- ""

print -r -- "Zsh plugins"
if (( ${+commands[python3]} )); then
    while IFS= read -r line; do
        [[ -z "${line}" ]] && continue
        local pname="${line%%|*}"
        local pdest="${line#*|}"
        if [[ -d "${pdest}/.git" ]]; then
            lamina_ok "${pname}"
        else
            lamina_fail "missing plugin ${pname} at ${pdest}"
            issues+=1
        fi
    done < <(python3 - "${DOTFILES}/lamina/plugins.toml" <<'PY'
import sys, tomllib
from pathlib import Path
home = Path.home()
data = tomllib.loads(Path(sys.argv[1]).read_text())
section = data.get("plugins", {})
root = home / section.get("root", "~/.zsh/plugins")[2:]
for entry in section.get("repo", []):
    dest = root / entry["dir"]
    print(f"{entry['name']}|{dest}")
PY
)
else
    lamina_warn "python3 not found — skipping plugin checks"
fi
print -r -- ""

print -r -- "Required binaries"
check_required_bin "launch-os-layer" "~/.local/bin/launch-os-layer"
check_required_bin "grok-acp" "~/.local/bin/grok-acp"
check_required_bin "lamina" "~/.local/bin/lamina"
print -r -- ""

print -r -- "Core symlinks"
check_dotter_symlink "zsh/env.d" "~/.zsh/env.d"
check_dotter_symlink "zsh/rc.d" "~/.zsh/rc.d"
check_dotter_symlink "zsh/.zshrc" "~/.zsh/.zshrc"
check_dotter_symlink "zsh/.zshenv" "~/.zshenv"
check_dotter_symlink "configs/nvim" "~/.config/nvim"
check_dotter_symlink "configs/kitty" "~/.config/kitty"
check_dotter_symlink "configs/starship/starship.toml" "~/.config/starship.toml"
check_dotter_symlink "configs/tmux/tmux.conf" "~/.tmux.conf"

# Dual-link check (.zshenv → both HOME and ZDOTDIR)
local zdot_zshenv="${ZDOTDIR}/.zshenv"
local repo_zshenv="${DOTFILES}/zsh/.zshenv"
if [[ -L "${zdot_zshenv}" ]] && [[ "${zdot_zshenv:A}" == "${repo_zshenv:A}" ]]; then
    lamina_ok "${zdot_zshenv} → zsh/.zshenv (dual-link)"
else
    lamina_fail "${zdot_zshenv} dual-link missing or wrong"
    issues+=1
fi

print -r -- ""
if (( issues == 0 )); then
    print -r -- "lamina health — all checks passed"
    exit 0
fi

print -r -- "lamina health — ${issues} issue(s) found (run: lamina deploy)"
exit 1