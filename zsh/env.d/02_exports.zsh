#!/usr/bin/env zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#               repo: https://github.com/sudobashme/dotfiles
#               file: 02_exports.zsh
#           filepath: ${ZDOTDIR}/env.d/02_exports.zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


# XDG basedir spec compliance
export XDG_CACHE_HOME="${HOME}/.cache";
export XDG_CONFIG_HOME="${HOME}/.config";
export XDG_DATA_HOME="${HOME}/.local/share";
export XDG_STATE_HOME="${HOME}/.state";
export XDG_DATA_DIRS="${XDG_DATA_HOME}:${XDG_CONFIG_HOME}:${XDG_STATE_HOME}";
export XDG_CONFIG_DIRS="${XDG_CONFIG_HOME}";

export LOCAL_TOOLS="${HOME}/.local/tools"

# best effort to make tools compliant to XDG basedir spec
export GNUPGHOME="${XDG_CONFIG_HOME}/gnupg"
export GPG_TTY=${TTY}

# less
export PAGER=less
export LESS="--RAW-CONTROL-CHARS --ignore-case --hilite-unread --LONG-PROMPT --window=-4 --tabs=4 --mouse --wheel-lines=3"
export READNULLCMD=${PAGER}
export LESSHISTFILE="${XDG_CACHE_HOME}/lesshst"

# node
export NODENV_ROOT="${HOME}/.nodenv"
export NODENV_PLUGINS="${NODENV_ROOT}/plugins"
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npm/config"
export NPM_CONFIG_CACHE="${XDG_CACHE_HOME}/npm"
export YARNRC="${XDG_CONFIG_HOME}/yarn/yarnrc"
export NODE_MODULES_BIN="${HOME}/.node_modules/bin"
#export NODE_PATH="${XDG_DATA_HOME}/node_modules"

# ruby
export RBENV_ROOT="${HOME}/.rbenv"
export RBENV_PLUGINS="${RBENV_ROOT}/plugins"
export GEMRC="${XDG_CONFIG_HOME}/gem/gemrc"
#export GEM_HOME="${XDG_DATA_HOME}/gem"
export GEM_SPEC_CACHE="${XDG_CACHE_HOME}/gem"
export BUNDLE_USER_CONFIG="${XDG_CONFIG_HOME}/bundle"
export BUNDLE_USER_CACHE="${XDG_CACHE_HOME}/bundle"
export BUNDLE_USER_PLUGIN="${XDG_DATA_HOME}/bundle"

# docker
# export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"
# export MACHINE_STORAGE_PATH="${XDG_DATA_HOME}/docker/machine"

# top
export BTOPRC="${XDG_CONFIG_HOME}/btop/btop.conf"
#export HTOPRC="${XDG_CONFIG_HOME}/htop/htoprc"

# httpie
# export HTTPIE_CONFIG_DIR="${XDG_CONFIG_HOME}/httpie"

# ansible
# export ANSIBLE_LOCAL_TEMP="${XDG_RUNTIME_DIR}/ansible/tmp"

# go
#export GOPATH="${XDG_DATA_HOME}/go"
export GOENV_ROOT="${HOME}/.goenv"

# python
export PYENV_ROOT="${HOME}/.pyenv"
export PYENV_PLUGINS="${PYENV_ROOT}/plugins"
#export TASKDATA="${XDG_DATA_HOME}/task"
#export TASKRC="${XDG_CONFIG_HOME}/task/taskrc"

# homebrew
export HOMEBREW_BUNDLE_FILE="${DOTFILES}/configs/homebrew/homebrew_bundle_file"

# Obsidian Rest API Key
export OBSIDIAN_REST_API_KEY=$(cat ~/.ssh/obsidian_local_rest_api_key)

#lua
export LUAENV_ROOT="${HOME}/.luaenv"
export LUAENV_PLUGINS="${LUAENV_ROOT}/plugins"

if (( ${+commands[xcodebuild]} )); then
    export MACOSX_DEPLOYMENT_TARGET=$(xcodebuild -version | grep Xcode | sed 's/Xcode\ //')
fi

if [[ -d "${XDG_CONFIG_HOME}" ]]; then
    export CONFIG="${XDG_CONFIG_HOME}"
fi

if [[ -d "${HOME}/IBM/NoteBooks/Current_Projects" ]]; then
    export PROJECTS="${HOME}/IBM/NoteBooks/Current_Projects"
fi

if [[ -d "${HOME}/Dropbox" ]]; then
    export DROPBOX="${HOME}/Dropbox"
    export GraphicsProjects="${DROPBOX}/Family\ Room/2DProjects"
    export DBPictures="${DROPBOX}/Pictures"
    export WALLPAPER="${DROPBOX}/Wallpaper"
fi
