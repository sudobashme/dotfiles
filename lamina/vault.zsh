#!/usr/bin/env zsh
set -euo pipefail

DOTFILES="$(lamina_dotfiles)" || exit 1
typeset -r VAULT_HOME="${LAMINA_VAULT_HOME:-${HOME}}"
typeset -r VAULT_CONFIG="${LAMINA_VAULT_CONFIG:-${HOME}/.config/lamina/vault.zsh}"

vault_usage() {
    cat <<'EOF'
lamina vault — encrypted, versioned recovery for private AI state

Usage:
  lamina vault plan
      Show what is protected and what is deliberately reproducible.
  lamina vault stage [--output DIR]
      Create a filtered, database-consistent local recovery tree.
  lamina vault health
      Check tools, configuration, password source, and repository access.
  lamina vault init
      Initialize the configured encrypted restic repository.
  lamina vault backup [--dry-run]
      Stage private state and create one encrypted snapshot.
  lamina vault snapshots
      List available snapshots.
  lamina vault restore [SNAPSHOT] --target DIR
      Restore into a review directory; never overwrites live state.
  lamina vault retain
      Keep 7 daily, 8 weekly, 12 monthly, and 3 yearly snapshots.
  lamina vault verify [--full]
      Check repository structure, or all stored data with --full.

Local configuration: ~/.config/lamina/vault.zsh
Example:             lamina/vault/config.example.zsh
Recovery guide:      docs/personal-os-layer/AI-STATE-RECOVERY.md
EOF
}

typeset -a VAULT_SOURCES
VAULT_SOURCES=(
    "${VAULT_HOME}/.codex/config.toml|codex/config.toml"
    "${VAULT_HOME}/.codex/AGENTS.md|codex/AGENTS.md"
    "${VAULT_HOME}/.codex/rules|codex/rules"
    "${VAULT_HOME}/.codex/skills|codex/skills"
    "${VAULT_HOME}/.codex/sessions|codex/sessions"
    "${VAULT_HOME}/.codex/session_index.jsonl|codex/session_index.jsonl"
    "${VAULT_HOME}/.codex/sqlite|codex/sqlite"
    "${VAULT_HOME}/.codex/state_5.sqlite|codex/state_5.sqlite"
    "${VAULT_HOME}/.codex/goals_1.sqlite|codex/goals_1.sqlite"
    "${VAULT_HOME}/.codex/memories_1.sqlite|codex/memories_1.sqlite"
    "${VAULT_HOME}/.codex/queue_1.sqlite|codex/queue_1.sqlite"
    "${VAULT_HOME}/.codex/transcription-history.jsonl|codex/transcription-history.jsonl"
    "${VAULT_HOME}/.grok/config.toml|grok/config.toml"
    "${VAULT_HOME}/.grok/memory|grok/memory"
    "${VAULT_HOME}/.grok/sessions|grok/sessions"
    "${VAULT_HOME}/.grok/projects|grok/projects"
    "${VAULT_HOME}/.grok/installed-plugins/registry.json|grok/installed-plugins/registry.json"
    "${VAULT_HOME}/.grok/skills|grok/skills"
    "${VAULT_HOME}/.grok/worktrees.db|grok/worktrees.db"
    "${VAULT_HOME}/.cursor/argv.json|cursor/argv.json"
    "${VAULT_HOME}/.cursor/agents|cursor/agents"
    "${VAULT_HOME}/.cursor/plugins/local|cursor/plugins/local"
    "${VAULT_HOME}/Library/Application Support/Cursor/User/settings.json|cursor/User/settings.json"
    "${VAULT_HOME}/Library/Application Support/Cursor/User/snippets|cursor/User/snippets"
    "${VAULT_HOME}/Library/Application Support/Cursor/User/globalStorage|cursor/User/globalStorage"
    "${VAULT_HOME}/.openclaw/openclaw.json|openclaw/openclaw.json"
    "${VAULT_HOME}/.openclaw/workspace|openclaw/workspace"
    "${VAULT_HOME}/.openclaw/agents/main/agent|openclaw/agents/main/agent"
    "${VAULT_HOME}/.openclaw/agents/main/sessions|openclaw/agents/main/sessions"
    "${VAULT_HOME}/.openclaw/state|openclaw/state"
    "${VAULT_HOME}/.openclaw/memory|openclaw/memory"
    "${VAULT_HOME}/.openclaw/tasks|openclaw/tasks"
    "${VAULT_HOME}/.openclaw/flows|openclaw/flows"
    "${VAULT_HOME}/.openclaw/identity|openclaw/identity"
    "${VAULT_HOME}/.openclaw/devices|openclaw/devices"
    "${VAULT_HOME}/.openclaw/service-env|openclaw/service-env"
)

typeset -a VAULT_RSYNC_EXCLUDES
VAULT_RSYNC_EXCLUDES=(
    '--exclude=.DS_Store'
    '--exclude=*.lock'
    '--exclude=*.sock'
    '--exclude=*-shm'
    '--exclude=*-wal'
    '--exclude=*.bak-*'
    '--exclude=*.bak.*'
    '--exclude=*.sqlite-import.*.bak'
    '--exclude=*.log'
    '--exclude=logs/'
    '--exclude=cache/'
    '--exclude=tmp/'
    '--exclude=downloads/'
    '--exclude=extensions/'
    '--exclude=.system/'
)

vault_load_config() {
    if [[ -r "${VAULT_CONFIG}" ]]; then
        source "${VAULT_CONFIG}"
    fi

    if [[ -n "${LAMINA_VAULT_REPOSITORY:-}" ]]; then
        export RESTIC_REPOSITORY="${LAMINA_VAULT_REPOSITORY}"
    fi
    if [[ -n "${LAMINA_VAULT_PASSWORD_FILE:-}" ]]; then
        export RESTIC_PASSWORD_FILE="${LAMINA_VAULT_PASSWORD_FILE}"
    fi
    if [[ -n "${LAMINA_VAULT_PASSWORD_COMMAND:-}" ]]; then
        export RESTIC_PASSWORD_COMMAND="${LAMINA_VAULT_PASSWORD_COMMAND}"
    fi
}

vault_restic() {
    restic "$@"
}

vault_copy_source() {
    local source_path="$1" destination_path="$2"
    mkdir -p "${destination_path:h}"

    if [[ -d "${source_path}" ]]; then
        mkdir -p "${destination_path}"
        /usr/bin/rsync -a "${VAULT_RSYNC_EXCLUDES[@]}" "${source_path}/" "${destination_path}/"
    else
        /bin/cp -p "${source_path}" "${destination_path}"
    fi
}

vault_snapshot_sqlite_files() {
    local source_path="$1" destination_path="$2"
    local db_file relative_path db_destination escaped_destination
    local -a candidates

    if [[ -d "${source_path}" ]]; then
        candidates=("${(@f)$(find "${source_path}" -type f \( -name '*.sqlite' -o -name '*.db' -o -name '*.vscdb' \) 2>/dev/null)}")
    elif [[ "${source_path}" == *.(sqlite|db|vscdb) ]]; then
        candidates=("${source_path}")
    else
        return 0
    fi

    for db_file in "${candidates[@]}"; do
        [[ -n "${db_file}" ]] || continue
        if ! /usr/bin/sqlite3 "${db_file}" 'PRAGMA schema_version;' >/dev/null 2>&1; then
            continue
        fi

        if [[ -d "${source_path}" ]]; then
            relative_path="${db_file#${source_path}/}"
            db_destination="${destination_path}/${relative_path}"
        else
            db_destination="${destination_path}"
        fi
        mkdir -p "${db_destination:h}"
        escaped_destination="${db_destination//\'/\'\'}"
        /bin/rm -f -- "${db_destination}" "${db_destination}-shm" "${db_destination}-wal"
        # VACUUM INTO reads a transactional snapshot and does not inherit the
        # source database's WAL/SHM files. It is also reliably bounded for
        # WAL-heavy agent stores where sqlite3's .backup can wait indefinitely.
        /usr/bin/sqlite3 "${db_file}" ".timeout 3000" "VACUUM INTO '${escaped_destination}';"
        /usr/bin/sqlite3 "${db_destination}" 'PRAGMA journal_mode=DELETE;' >/dev/null
        /bin/rm -f -- "${db_destination}-shm" "${db_destination}-wal"
    done
}

vault_write_manifest() {
    local staging_root="$1"
    {
        print -r -- "format=1"
        print -r -- "created_at=$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
        print -r -- "source_host=$(hostname -s)"
        print -r -- "dotfiles_commit=$(git -C "${DOTFILES}" rev-parse --short HEAD 2>/dev/null || print unknown)"
        print -r -- "restoration=review-first"
    } > "${staging_root}/VAULT-MANIFEST"
}

vault_stage() {
    local output_dir=""
    while (( $# )); do
        case "$1" in
            --output)
                [[ $# -ge 2 ]] || { print -u2 'lamina vault: --output requires a directory'; return 1; }
                output_dir="$2"
                shift 2
                ;;
            *) print -u2 "lamina vault: unknown stage argument: $1"; return 1 ;;
        esac
    done

    if [[ -z "${output_dir}" ]]; then
        output_dir="$(mktemp -d "${TMPDIR:-/tmp}/lamina-vault-stage.XXXXXXXX")"
    else
        output_dir="${output_dir:A}"
        if [[ -e "${output_dir}" && -n "$(find "${output_dir}" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]; then
            print -u2 "lamina vault: stage target must be empty: ${output_dir}"
            return 1
        fi
        mkdir -p "${output_dir}"
    fi

    lamina_header 'vault stage' "${output_dir}"
    local entry source_path destination_rel destination_path
    local -i copied=0 missing=0
    for entry in "${VAULT_SOURCES[@]}"; do
        source_path="${entry%%|*}"
        destination_rel="${entry#*|}"
        destination_path="${output_dir}/${destination_rel}"
        if [[ ! -e "${source_path}" ]]; then
            missing+=1
            continue
        fi
        lamina_step "${destination_rel}"
        vault_copy_source "${source_path}" "${destination_path}"
        vault_snapshot_sqlite_files "${source_path}" "${destination_path}"
        copied+=1
    done
    vault_write_manifest "${output_dir}"
    lamina_ok "staged ${copied} source(s); ${missing} not present on this machine"
    print -r -- "${output_dir}"
}

vault_plan() {
    lamina_header 'vault plan' 'private AI state'
    local entry source_path destination_rel size
    local -i present=0 missing=0
    for entry in "${VAULT_SOURCES[@]}"; do
        source_path="${entry%%|*}"
        destination_rel="${entry#*|}"
        if [[ -e "${source_path}" ]]; then
            size="$(du -sh "${source_path}" 2>/dev/null | awk '{print $1}')"
            printf '  + %-8s %-42s ~%s\n' "${size:-?}" "${destination_rel}" "${source_path#${VAULT_HOME}}"
            present+=1
        else
            printf '  - %-8s %-42s ~%s\n' missing "${destination_rel}" "${source_path#${VAULT_HOME}}"
            missing+=1
        fi
    done
    print -r -- ""
    lamina_note "Included: ${present}; absent: ${missing}"
    lamina_note 'Excluded: auth tokens, caches, downloads, bundled/system skills, logs, locks, sockets, WAL/SHM files, and OpenClaw rolling .bak files.'
    lamina_note 'SQLite files are copied through the SQLite backup interface.'
}

vault_require_repository() {
    vault_load_config
    lamina_need_cmd restic || return 1
    if [[ -z "${RESTIC_REPOSITORY:-}" ]]; then
        print -u2 "lamina vault: repository is not configured in ${VAULT_CONFIG}"
        return 1
    fi
    if [[ -z "${RESTIC_PASSWORD_FILE:-}" && -z "${RESTIC_PASSWORD_COMMAND:-}" && -z "${RESTIC_PASSWORD:-}" ]]; then
        print -u2 'lamina vault: configure a restic password file or password command'
        return 1
    fi
}

vault_health() {
    vault_load_config
    lamina_header 'vault health' "${VAULT_CONFIG}"
    local -i issues=0
    for tool_name in restic rclone sqlite3 rsync; do
        if (( ${+commands[${tool_name}]} )); then
            lamina_ok "${tool_name}: ${commands[${tool_name}]}"
        else
            lamina_fail "missing ${tool_name}"
            issues+=1
        fi
    done
    if [[ -r "${VAULT_CONFIG}" ]]; then
        lamina_ok 'local configuration present'
    else
        lamina_fail "missing ${VAULT_CONFIG}"
        issues+=1
    fi
    if [[ -n "${RESTIC_REPOSITORY:-}" ]]; then
        lamina_ok 'encrypted repository configured'
    else
        lamina_fail 'repository not configured'
        issues+=1
    fi
    if [[ -n "${RESTIC_PASSWORD_FILE:-}" && -r "${RESTIC_PASSWORD_FILE}" ]]; then
        local password_mode
        password_mode="$(/usr/bin/stat -f '%Lp' "${RESTIC_PASSWORD_FILE}" 2>/dev/null || print unknown)"
        if [[ "${password_mode}" == 600 ]]; then
            lamina_ok 'password file present with mode 600'
        else
            lamina_fail "password file permissions are ${password_mode}; expected 600"
            issues+=1
        fi
    elif [[ -n "${RESTIC_PASSWORD_COMMAND:-}" ]]; then
        lamina_ok 'password command configured'
    else
        lamina_fail 'password source unavailable'
        issues+=1
    fi
    if (( issues == 0 )); then
        local health_timeout="${LAMINA_VAULT_HEALTH_TIMEOUT:-20s}"
        local -a snapshots_cmd
        snapshots_cmd=(restic snapshots --compact)
        if (( ${+commands[timeout]} )); then
            snapshots_cmd=(timeout "${health_timeout}" "${snapshots_cmd[@]}")
        elif (( ${+commands[gtimeout]} )); then
            snapshots_cmd=(gtimeout "${health_timeout}" "${snapshots_cmd[@]}")
        fi
        if "${snapshots_cmd[@]}" >/dev/null 2>&1; then
            lamina_ok 'repository accessible'
        else
            lamina_warn "configuration is complete, but repository is not initialized, reachable, or responsive within ${health_timeout}"
        fi
        return 0
    fi
    return 1
}

vault_backup() {
    vault_require_repository || return 1
    local dry_run=0
    if [[ "${1:-}" == --dry-run ]]; then
        dry_run=1
        shift
    fi
    (( $# == 0 )) || { print -u2 "lamina vault: unknown backup argument: $1"; return 1; }

    local staging_root
    staging_root="$(mktemp -d "${TMPDIR:-/tmp}/lamina-vault-backup.XXXXXXXX")"
    trap '/bin/rm -rf -- "${staging_root}"' EXIT INT TERM
    vault_stage --output "${staging_root}"
    local -a backup_args
    backup_args=(backup "${staging_root}" --tag lamina-vault --host "${LAMINA_VAULT_HOST:-$(hostname -s)}" --one-file-system)
    (( dry_run )) && backup_args+=(--dry-run)
    vault_restic "${backup_args[@]}"
    /bin/rm -rf -- "${staging_root}"
    trap - EXIT INT TERM
}

vault_restore() {
    vault_require_repository || return 1
    local snapshot=latest target_dir=""
    if [[ -n "${1:-}" && "${1:-}" != --target ]]; then
        snapshot="$1"
        shift
    fi
    while (( $# )); do
        case "$1" in
            --target)
                [[ $# -ge 2 ]] || { print -u2 'lamina vault: --target requires a directory'; return 1; }
                target_dir="$2"
                shift 2
                ;;
            *) print -u2 "lamina vault: unknown restore argument: $1"; return 1 ;;
        esac
    done
    [[ -n "${target_dir}" ]] || { print -u2 'lamina vault: restore requires --target DIR'; return 1; }
    target_dir="${target_dir:A}"
    if [[ -e "${target_dir}" && -n "$(find "${target_dir}" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]; then
        print -u2 "lamina vault: restore target must be empty: ${target_dir}"
        return 1
    fi
    mkdir -p "${target_dir}"
    vault_restic restore "${snapshot}" --target "${target_dir}"
    lamina_ok "restored for review at ${target_dir}"
    lamina_note 'No live application state was overwritten.'
}

vault_main() {
    local command_name="${1:-help}"
    shift || true
    case "${command_name}" in
        plan) vault_plan "$@" ;;
        stage) vault_stage "$@" ;;
        health|status) vault_health "$@" ;;
        init) vault_require_repository && vault_restic init "$@" ;;
        backup) vault_backup "$@" ;;
        snapshots) vault_require_repository && vault_restic snapshots "$@" ;;
        restore) vault_restore "$@" ;;
        retain) vault_require_repository && vault_restic forget --keep-daily 7 --keep-weekly 8 --keep-monthly 12 --keep-yearly 3 --prune "$@" ;;
        verify)
            vault_require_repository || return 1
            if [[ "${1:-}" == --full ]]; then
                shift
                vault_restic check --read-data "$@"
            else
                vault_restic check "$@"
            fi
            ;;
        help|-h|--help|'') vault_usage ;;
        *) print -u2 "lamina vault: unknown command: ${command_name}"; vault_usage >&2; return 1 ;;
    esac
}

vault_main "$@"
