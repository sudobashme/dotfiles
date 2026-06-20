#!/usr/bin/env zsh
# Version manager + language package update helpers for lamina update

# Git-pull a *-build plugin so install -l lists fresh runtimes.
__lamina_env_pull_build_plugin__() {
    local plugin_dir="$1"
    [[ -d "${plugin_dir}/.git" ]] || return 0
    git -C "${plugin_dir}" pull --ff-only 2>/dev/null
}

__lamina_env_refresh_definitions__() {
    local manager="$1" root="$2" build_plugin="$3"
    [[ -d "${root}" ]] || return 0
    if ! command -v "${manager}" >/dev/null 2>&1; then
        lamina_warn "${manager} not found — skipping definition refresh"
        return 0
    fi
    __lamina_env_pull_build_plugin__ "${root}/plugins/${build_plugin}"
    command "${manager}" rehash 2>/dev/null || true
}

__lamina_env_latest_stable__() {
    local manager="$1"
    case "${manager}" in
        pyenv)
            command pyenv install --list 2>/dev/null \
                | sed 's/^[[:space:]]*//' \
                | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
                | tail -1
            ;;
        nodenv)
            command nodenv install -l 2>/dev/null \
                | sed 's/^[[:space:]]*//' \
                | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
                | tail -1
            ;;
        rbenv)
            command rbenv install -l 2>/dev/null \
                | sed 's/^[[:space:]]*//' \
                | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
                | tail -1
            ;;
        luaenv)
            command luaenv install -l 2>/dev/null \
                | sed 's/^[[:space:]]*//' \
                | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
                | tail -1
            ;;
        goenv)
            command goenv install -l 2>/dev/null \
                | sed 's/^[[:space:]]*//' \
                | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
                | tail -1
            ;;
    esac
}

__lamina_env_install_latest__() {
    local manager="$1"
    command -v "${manager}" >/dev/null 2>&1 || return 0

    local latest installed
    latest="$(__lamina_env_latest_stable__ "${manager}")"
    [[ -n "${latest}" ]] || {
        lamina_warn "${manager}: could not determine latest stable version"
        return 0
    }

    installed="$(command "${manager}" versions --bare 2>/dev/null | grep -Fx "${latest}" || true)"
    if [[ -n "${installed}" ]]; then
        lamina_ok "${manager}: ${latest} already installed"
        return 0
    fi

    print -r -- "  ${manager}: installing ${latest} (latest stable; global version unchanged)"
    command "${manager}" install -s "${latest}"
}

__lamina_envs_refresh_definitions__() {
    __lamina_env_refresh_definitions__ pyenv "${PYENV_ROOT:-${HOME}/.pyenv}" python-build
    __lamina_env_refresh_definitions__ nodenv "${NODENV_ROOT:-${HOME}/.nodenv}" node-build
    __lamina_env_refresh_definitions__ rbenv "${RBENV_ROOT:-${HOME}/.rbenv}" ruby-build
    __lamina_env_refresh_definitions__ luaenv "${LUAENV_ROOT:-${HOME}/.luaenv}" lua-build
    __lamina_env_refresh_definitions__ goenv "${GOENV_ROOT:-${HOME}/.goenv}" go-build
}

__lamina_envs_install_latest__() {
    __lamina_env_install_latest__ pyenv
    __lamina_env_install_latest__ nodenv
    __lamina_env_install_latest__ rbenv
    __lamina_env_install_latest__ luaenv
    __lamina_env_install_latest__ goenv
}

__lamina_pip_update__() {
    command -v python >/dev/null 2>&1 || return 0
    command -v pip >/dev/null 2>&1 || return 0

    local pyver
    pyver="$(python -c 'import sys; print(".".join(map(str, sys.version_info[:3])))' 2>/dev/null || true)"
    print -r -- "  pip (${pyver:-active python})"

    python -m pip install --upgrade pip setuptools wheel 2>/dev/null || true

    local -a outdated
    outdated=("${(@f)$(python -m pip list --outdated --format=freeze 2>/dev/null \
        | cut -d= -f1 \
        | grep -v '^pip$' \
        | grep -v '^setuptools$' \
        | grep -v '^wheel$' || true)}")

    if (( ${#outdated[@]} == 0 )); then
        lamina_ok "pip packages up to date"
        return 0
    fi

    print -r -- "  upgrading ${#outdated[@]} pip package(s)"
    python -m pip install --upgrade "${outdated[@]}"
}

__lamina_gem_update__() {
    command -v gem >/dev/null 2>&1 || return 0

    local ruby_ver
    ruby_ver="$(ruby -e 'print RUBY_VERSION' 2>/dev/null || true)"
    print -r -- "  gem (${ruby_ver:-active ruby})"

    gem update --document= 2>/dev/null
    gem cleanup 2>/dev/null || true
}

__lamina_npm_global_update__() {
    command -v npm >/dev/null 2>&1 || return 0
    npm update -g
    npm fund 2>/dev/null || true
}

__lamina_npm_local_update__() {
    local modules_dir="${NODE_MODULES_BIN:h}"
    [[ -f "${modules_dir}/package.json" ]] || return 0
    command -v npm >/dev/null 2>&1 || return 0

    print -r -- "  npm (${modules_dir})"
    (cd "${modules_dir}" && npm update)
}

