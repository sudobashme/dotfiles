#!/usr/bin/env zsh
set -euo pipefail

LAMINA_CMD="${0}"
DOTFILES="$(lamina_root "${LAMINA_CMD}")" || exit 1

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

exec python3 "${DOTFILES}/lamina/lib/sync_plugins.py" "${sync_args[@]}"