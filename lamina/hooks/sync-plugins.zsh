#!/usr/bin/env zsh
set -euo pipefail

DOTFILES="$(lamina_dotfiles)" || exit 1

typeset -a sync_args
sync_args=(--manifest "${DOTFILES}/lamina/plugins.toml")

if [[ "${LAMINA_PLUGINS_DRY_RUN:-}" == 1 ]]; then
    sync_args+=(--dry-run)
fi

if [[ "${LAMINA_PLUGINS_NO_ZRECOMPILE:-}" == 1 ]]; then
    sync_args+=(--no-zrecompile)
fi

lamina_need_cmd python3 || exit 1
lamina_need_cmd git || exit 1

# Do not exec or exit — deploy/update source this file and must continue afterward.
python3 "${DOTFILES}/lamina/lib/sync_plugins.py" "${sync_args[@]}"