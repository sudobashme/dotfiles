#!/usr/bin/env sh
# Ensure target parent directories exist before dotter creates symlinks.
set -eu

home="${HOME:-$(eval echo ~$(id -u -n))}"

mkdir -p \
  "${home}/.zsh" \
  "${home}/.config" \
  "${home}/.local/bin" \
  "${home}/.cache/zsh" \
  "${home}/.tmux"