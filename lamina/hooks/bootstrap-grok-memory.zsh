#!/usr/bin/env zsh
# Enable Grok cross-session memory and seed global MEMORY.md on first deploy.
set -euo pipefail

typeset -r grok_dir="${HOME}/.grok"
typeset -r grok_cfg="${grok_dir}/config.toml"
typeset -r grok_mem="${grok_dir}/memory"
typeset -r grok_global="${grok_mem}/MEMORY.md"
typeset -r seed="${DOTFILES}/lamina/grok/MEMORY.seed.md"

zf_mkdir -p "${grok_mem}"

if [[ -f "${grok_cfg}" ]]; then
    if ! grep -q '^\[memory\]' "${grok_cfg}" 2>/dev/null; then
        lamina_note "enabling Grok memory in ${grok_cfg}"
        print -r -- '' >>"${grok_cfg}"
        print -r -- '[memory]' >>"${grok_cfg}"
        print -r -- 'enabled = true' >>"${grok_cfg}"
    elif ! grep -q '^enabled = true' "${grok_cfg}" 2>/dev/null; then
        # [memory] exists but may be disabled — ensure enabled (idempotent append if no enabled key in section is hard; patch simply)
        if grep -A5 '^\[memory\]' "${grok_cfg}" | grep -q '^enabled = false'; then
            lamina_note "setting Grok memory enabled=true in ${grok_cfg}"
            # shellcheck disable=SC2016
            sed -i '' '/^\[memory\]/,/^\[/ s/^enabled = false/enabled = true/' "${grok_cfg}" 2>/dev/null || \
                sed -i '/^\[memory\]/,/^\[/ s/^enabled = false/enabled = true/' "${grok_cfg}"
        fi
    fi
else
    lamina_warn "no ${grok_cfg} — install Grok CLI first; memory not configured"
fi

if [[ ! -f "${grok_global}" && -f "${seed}" ]]; then
    cp -f "${seed}" "${grok_global}"
    lamina_note "seeded Grok global memory from lamina/grok/MEMORY.seed.md"
fi