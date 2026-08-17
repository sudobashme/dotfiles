#!/usr/bin/env sh
# Ensure target parent directories exist before dotter creates symlinks.
set -eu

home="${HOME:-$(eval echo ~$(id -u -n))}"

# dotter may execute this hook from .dotter/cache/.dotter/ — walk up to the repo root.
dotfiles="${DOTFILES:-}"
if [ -z "${dotfiles}" ]; then
  dir="$(cd "$(dirname "$0")" && pwd)"
  while [ "${dir}" != "/" ]; do
    if [ -d "${dir}/configs/bat" ] && [ -d "${dir}/lamina" ]; then
      dotfiles="${dir}"
      break
    fi
    dir="$(dirname "${dir}")"
  done
fi
if [ -z "${dotfiles}" ] || [ ! -d "${dotfiles}/configs/bat" ]; then
  echo "pre_deploy: could not locate dotfiles repository" >&2
  exit 1
fi

mkdir -p \
  "${home}/.zsh" \
  "${home}/.config" \
  "${home}/.local/bin" \
  "${home}/.cache/zsh" \
  "${home}/.tmux" \
  "${home}/.grok/skills" \
  "${home}/.grok/memory" \
  "${home}/.config/lamina"

# bat + lazygit ship light/dark variants; link the active config before dotter runs.
if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -qi '^Dark'; then
  variant=dark
else
  variant=light
fi

ln -sf "config-${variant}.conf" "${dotfiles}/configs/bat/config"
ln -sf "config-${variant}.yml" "${dotfiles}/configs/lazygit/config.yml"
