#!/usr/bin/env zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#               repo: https://github.com/sudobashme/dotfiles
#               file: deploy.zsh
#           filepath: ${DOTFILES}/deploy.zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

#set -e

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Loading functions until about line 200 roughly

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# eval user
evaluate_user_var() {
    export USER=${USER:-$(id -u -n)}
    echo "${FMT_BLUE} User is: ${FMT_RESET} ${FMT_GREEN} $USER ${FMT_RESET}"
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# eval home
evaluate_home_var() {
    export HOME=${HOME:-/Users/$(id -u -n)}
    echo "${FMT_BLUE} Home is: ${FMT_RESET} ${FMT_GREEN} $HOME ${FMT_RESET}"
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# zdotdir setup
set_zdot_dir() {
    echo "${FMT_BLUE} setting zdotdir, and creating directory if it does not exist... ${FMT_RESET}"
    export ZDOTDIR="${HOME}/.zsh"
    if [[ ! -d $ZDOTDIR ]]; then zf_mkdir -p $ZDOTDIR; fi
    echo "${FMT_BLUE} ZDOTDIR is: ${FMT_RESET} ${FMT_GREEN} $ZDOTDIR ${FMT_RESET}"
    echo ""
    echo "${FMT_GREEN} $(stat $ZDOTDIR) ${FMT_RESET}"
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# xdg common
set_common_xdg_dirs() {
    echo "${FMT_BLUE} setting xdg data structures, including creation if they do not exist... ${FMT_RESET}"
    export XDG_CACHE_HOME="${HOME}/.cache"
    echo "${FMT_BLUE} XDG_CACHE_HOME is set to: ${FMT_RESET} ${FMT_GREEN} ${XDG_CACHE_HOME} ${FMT_RESET}"
    if [[ ! -d $XDG_CACHE_HOME ]]; then zf_mkdir -p $XDG_CACHE_HOME; fi
    echo ""
    echo "${FMT_GREEN} $(stat $XDG_CACHE_HOME) ${FMT_RESET}"
    echo ""
    export XDG_CONFIG_HOME="${HOME}/.config"
    echo "${FMT_BLUE} XDG_CONFIG_HOME is set to: ${FMT_RESET} ${FMT_GREEN} ${XDG_CONFIG_HOME} ${FMT_RESET}"
    if [[ ! -d $XDG_CONFIG_HOME ]]; then zf_mkdir -p $XDG_CONFIG_HOME; fi
    echo ""
    echo "${FMT_GREEN} $(stat $XDG_CONFIG_HOME) ${FMT_RESET}"
    echo ""
    export XDG_DATA_HOME="${HOME}/.local/share"
    echo "${FMT_BLUE} XDG_DATA_HOME is set to: ${FMT_RESET} ${FMT_GREEN} ${XDG_DATA_HOME} ${FMT_RESET}"
    if [[ ! -d $XDG_DATA_HOME ]]; then zf_mkdir -p $XDG_DATA_HOME; fi
    echo ""
    echo "${FMT_GREEN} $(stat $XDG_DATA_HOME) ${FMT_RESET}"
    echo ""
    export XDG_STATE_HOME="${HOME}/.state"
    echo "${FMT_BLUE} XDG_STATE_HOME is set to: ${FMT_RESET} ${FMT_GREEN} ${XDG_STATE_HOME} ${FMT_RESET}"
    if [[ ! -d $XDG_STATE_HOME ]]; then zf_mkdir -p $XDG_STATE_HOME; fi
    echo ""
    echo "${FMT_GREEN} $(stat $XDG_STATE_HOME) ${FMT_RESET}"
    echo ""
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# dotfiles
set_dot_files_repo_location() {
    # maybe I will make this changeable but not today
    echo "${FMT_BLUE} setting dotfiles repo... ${FMT_RESET}"
    export DOTFILES="${XDG_DATA_HOME}/dotfiles"
    echo "${FMT_BLUE} DOTFILES is set to: ${FMT_RESET} ${FMT_GREEN} ${DOTFILES} ${FMT_RESET}"
    if [[ ! -d $DOTFILES ]]; then
        if (( ! ${+commands[brew]} )) || [[ ! -x /opt/homebrew/bin/brew ]]; then
            echo ""
            echo "${FMT_RED} homebrew was not detected and is being installed now... ${FMT_RESET}"
            if (( ! ${+commands[xcodebuild]} )); then
                echo "${FMT_RED} xcode command line tools not detected... ${FMT_RESET}"
                sudo xcodebuild -license accept
                sudo xcode-select --install || softwareupdate -ia
            fi
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh) NONINTERACTIVE=1"
            if [[ ! -x /opt/homebrew/bin/git ]]; then
                echo ""
                echo "${FMT_RED} installing git via homebrew... ${FMT_RESET}"
                /opt/homebrew/bin/brew install git
            fi
            alias git="/opt/homebrew/bin/git"
        fi
        echo ""
        #echo "${FMT_BLUE} Cloning dotfiles repo... ${FMT_RESET}"
        #git clone https://github.com/sudobashme/dotfiles $DOTFILES
    fi
    echo ""
    echo "${FMT_GREEN} $(stat $DOTFILES) ${FMT_RESET}"
    echo ""
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# local tools setup
set_local_tools_dir() {
    echo "${FMT_BLUE} setting local tools directory... ${FMT_RESET}"
    export LOCAL_TOOLS="${HOME}/.local/tools"
    echo "${FMT_BLUE} LOCAL_TOOLS is: ${FMT_RESET} ${FMT_GREEN} ${LOCAL_TOOLS} ${FMT_RESET}"
    if [[ ! -d $LOCAL_TOOLS ]]; then zf_mkdir -p $LOCAL_TOOLS; fi
    echo ""
    echo "${FMT_GREEN} $(stat $LOCAL_TOOLS) ${FMT_RESET}"
    echo ""
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# install fonts commonly required for any modern terminal app
install_fonts_description="install fonts commonly required for any modern terminal app (specifically fonts including glyphs)"
install_fonts() {
    echo ""
    echo "${FMT_YELLOW} Note that all fonts being installed contain glyphs ${FMT_RESET}"
    echo ""
    echo "${FMT_BLUE} installing powerline fonts... ${FMT_RESET}"
    git clone https://github.com/powerline/fonts.git --depth=1 ${XDG_CACHE_HOME}/fonts
    source ${XDG_CACHE_HOME}/fonts/install.sh;
    zf_rm -rf ${XDG_CACHE_HOME}/fonts;
    echo ""
    echo "${FMT_BLUE} installing a subset of nerd fonts... ${FMT_RESET}"
    brew update
    brew install font-blex-mono-nerd-font
    brew install font-code-new-roman-nerd-font
    brew install font-droid-sans-mono-nerd-font
    brew install font-hack-nerd-font
    brew install font-hackgen-nerd
    brew install font-heavy-data-nerd-font
    brew install font-iosevka-nerd-font
    brew install font-m+-nerd-font
    brew install font-mononoki-nerd-font
    brew install font-mplus-nerd-font
    brew install font-sauce-code-pro-nerd-font
    brew install font-ubuntu-mono-nerd-font
    brew install font-ubuntu-nerd-font
    brew install font-victor-mono-nerd-font
    echo ""
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# install apps in my current brewfile https://github.com/sudobashme/dotfiles/blob/main/configs/homebrew/homebrew_bundle_file
install_homebrew_apps_description="install apps in my current brewfile"
install_homebrew_apps() {
    export HOMEBREW_BUNDLE_FILE="${DOTFILES}/configs/homebrew/homebrew_bundle_file"
    /opt/homebrew/bin/brew bundle install --file=$HOMEBREW_BUNDLE_FILE
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# install rust
install_rust_description="install rust"
install_rust() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# install rust apps
install_rust_apps_description="install starship, zoxide, eza, fd, trippy, typescript, dust"
install_rust_apps() {
    for app in cargo-nextest du-dust eza fd-find starship trippy typescript zoxide; do
        echo "${FMT_BLUE} installing $app ${FMT_RESET}"
        echo ""
        ${HOME}/.cargo/bin/cargo install $app
    done
    unset app
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
install_zsh_environment_description="install my zsh environment that I use daily"
install_zsh_environment() {
    echo "${FMT_BLUE} creating required directories... ${FMT_RESET}"
    zf_mkdir -p "${XDG_CACHE_HOME}"/zsh
    #zf_mkdir -p "${HOME}"/{{.goenv,.luaenv,.nodenv,.pyenv,.rbenv}/plugins,zsh,man/man1}
    zf_mkdir -p "${HOME}"/.local/{bin,etc}
    zf_mkdir -p "${HOME}"/.tmux
    echo "${FMT_BLUE} linking configs via lamina (dotter)... ${FMT_RESET}"
    if [[ -x "${DOTFILES}/bin/lamina" ]]; then
        "${DOTFILES}/bin/lamina" deploy
    else
        echo "${FMT_RED} lamina not found at ${DOTFILES}/bin/lamina ${FMT_RESET}" >&2
        return 1
    fi
    cd ${LOCAL_TOOLS}
    git clone https://github.com/so-fancy/diff-so-fancy.git "${LOCAL_TOOLS}/diff-so-fancy"
    git clone https://github.com/junegunn/fzf.git "${LOCAL_TOOLS}/fzf"
    git clone https://github.com/tj/git-extras.git "${LOCAL_TOOLS}/git-extras"
    git clone https://github.com/arzzen/git-quick-stats.git "${LOCAL_TOOLS}/git-quick-stats"
    git clone https://github.com/b4b4r07/httpstat.git "${LOCAL_TOOLS}/httpstat"
    git clone https://github.com/holman/spark.git "${LOCAL_TOOLS}/spark"
    git clone https://github.com/speed47/spectre-meltdown-checker "${LOCAL_TOOLS}/spectre-meltdown-checker"
    git clone https://github.com/drwetter/testssl.sh.git "${LOCAL_TOOLS}/testssl.sh"
    git clone https://github.com/pepa65/tldr-bash-client.git "${LOCAL_TOOLS}/tldr-bash-client"
    if (( ${+commands[make]} )); then
        pushd git-extras
        PREFIX="${HOME}/.local" make install > /dev/null
        popd
        pushd git-quick-stats
        PREFIX="${HOME}/.local" make install > /dev/null
        popd
    fi
    pushd fzf
    if ./install --bin > /dev/null; then
        zf_ln -sf "${LOCAL_TOOLS}/fzf/bin/fzf" "${HOME}/.local/bin/fzf"
        zf_ln -sf "${LOCAL_TOOLS}/fzf/bin/fzf-tmux" "${HOME}/.local/bin/fzf-tmux"
        zf_ln -sf "${LOCAL_TOOLS}/fzf/man/man1/fzf.1" "${XDG_DATA_HOME}/man/man1/fzf.1"
        zf_ln -sf "${LOCAL_TOOLS}/fzf/man/man1/fzf-tmux.1" "${XDG_DATA_HOME}/man/man1/fzf-tmux.1"
    fi
    popd
    if (( ${+commands[perl]} )); then
        zf_ln -sf "${LOCAL_TOOLS}/diff-so-fancy/diff-so-fancy" "${HOME}/.local/bin/diff-so-fancy"
    fi
    if (( ${+commands[nvim]} )); then
        command nvim --headless -c "helptags ALL" -c "qall" &> /dev/null
        command nvim --headless -c "TSUpdate" -c "qall" &> /dev/null
        command nvim --headless -c "MasonUpdate" -c "qall" &> /dev/null
    fi
    ${LOCAL_TOOLS}/tldr-bash-client/tldr -u > /dev/null
    TMUX_PLUGIN_MANAGER_PATH=${HOME}/.tmux/plugins
    zf_mkdir -p ${TMUX_PLUGIN_MANAGER_PATH}
    git clone https://github.com/tmux-plugins/tpm "${TMUX_PLUGIN_MANAGER_PATH}/tpm"
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# install luajit
install_luajit_description="install by way of building it from source"
install_luajit() {
    if (( ${+commands[xcodebuild]} )); then
        export MACOSX_DEPLOYMENT_TARGET=$(xcodebuild -version | grep Xcode | sed 's/Xcode\ //')
    else
        print "must set MACOSX_DEPLOYMENT_TARGET and script was unable to determine"
        break
    fi
    git clone https://github.com/LuaJIT/LuaJIT.git "${LOCAL_TOOLS}/luajit"
    cd "${LOCAL_TOOLS}/luajit"
    if (( ${+commands[gmake]} )); then
        gmake
        sudo gmake install
        gmake clean
    else
        make
        sudo make install
        make clean
    fi
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# install neovium
install_neovim_description="install by way of building it from source"
install_neovim() {
    if (( ! ${+commands[luajit]} )); then print "must install luajit"; exit 1; fi
    if (( ! ${+commands[lua]} )); then print "must install lua"; exit 1; fi
    if [[ -d "${LOCAL_TOOLS}/neovim" ]]; then
        print "neovim appears to have already been downloaded"
        if [[ -d "${LOCAL_TOOLS}/neovim/build" ]]; then
            print "neovim was previously compiled in this directory, removing build dir"
            make clean
            zf_rm -rf "${LOCAL_TOOLS}/neovim/build"
        fi
        print "attempting to update from repo"
        git pull
    else
        git clone https://github.com/neovim/neovim.git "${LOCAL_TOOLS}/neovim"
    fi
    if (( ${+commands[gmake]} )); then
        gmake CMAKE_BUILD_TYPE=RelWithDebInfo
        sudo gmake install
        gmake clean
    else
        make CMAKE_BUILD_TYPE=RelWithDebInfo
        sudo make install
        make clean
    fi
    if (( ${+commands[npm]} )); then npm install -g neovim; npm fund; fi
    if (( ${+commands[pyenv]} )); then pyenv virtualenv neovim; pyenv activate neovim; pip install pip pynvim; fi
    if (( ${+commands[gem]} )); then gem install neovim; fi
    nvim --headless "+Lazy! sync" +qa
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# install language specific environments
__install_goenv() {
    export GOENV_ROOT="${HOME}/.goenv"
    git clone https://github.com/syndbg/goenv.git "${GOENV_ROOT}"
    zf_mkdir -p "${HOME}/.goenv"/{plugins,zsh,man/man1}
    path=(${GOENV_ROOT}/bin ${path})
    eval "$(goenv init -)"
    goenv install -f latest
    goenv global $(goenv versions)
    goenv rehash
}

__install_luaenv() {
    export LUAENV_ROOT="${HOME}/.luaenv"
    export LUAENV_PLUGINS="${LUAENV_ROOT}/plugins"
    git clone https://github.com/cehoffman/luaenv.git "${LUAENV_ROOT}"
    zf_mkdir -p "${HOME}/.luaenv"/{plugins,zsh,man/man1}
    git clone https://github.com/cehoffman/lua-build.git "${LUAENV_ROOT}/plugins/lua-build"
    git clone https://github.com/xpol/luaenv-luarocks.git "${LUAENV_ROOT}/plugins/luaenv-luarocks"
    path=(${LUAENV_ROOT}/bin ${path})
    path=(${LUAENV_ROOT}/plugins/lua-build/bin ${path})
    path=(${LUAENV_ROOT}/plugins/luaenv-luarocks/bin ${path})
    eval "$(luaenv init -)"
    luaenv install 5.1.5
    luaenv global 5.1.5
    luaenv luarocks
    luaenv rehash
}

__install_nodenv() {
    export NODENV_ROOT="${HOME}/.nodenv"
    export NODENV_PLUGINS="${NODENV_ROOT}/plugins"
    git clone https://github.com/nodenv/nodenv.git "${NODENV_ROOT}"
    zf_mkdir -p "${HOME}/.nodenv"/{plugins,zsh,man/man1}
    git clone https://github.com/nodenv/node-build.git "${NODENV_PLUGINS}/node-build"
    git clone https://github.com/nodenv/nodenv-aliases.git "${NODENV_PLUGINS}/nodenv-aliases"
    git clone https://github.com/nodenv/nodenv-env.git "${NODENV_PLUGINS}/nodenv-env"
    git clone https://github.com/nodenv/nodenv-man.git "${NODENV_PLUGINS}/nodenv-man"
    git clone https://github.com/nodenv/nodenv-package-rehash.git "${NODENV_PLUGINS}/nodenv-package-rehash"
    path=(${HOME}/nodenv/bin ${path})
    eval "$(nodenv init -)"
    install_version=$(nodenv install --list | egrep '^[0-9]' | tail -2 | head -1)
    nodenv install $install_version
    nodenv global $install_version
    nodenv alias --auto
    nodenv rehash
}

__install_pyenv() {
    export PYENV_ROOT="${HOME}/.pyenv"
    export PYENV_PLUGINS="${PYENV_ROOT}/plugins"
    git clone https://github.com/yyuu/pyenv.git "${PYENV_ROOT}"
    zf_mkdir -p "${HOME}/.pyenv"/{plugins,zsh,man/man1}
    git clone https://github.com/jawshooah/pyenv-default-packages.git "${PYENV_PLUGINS}/pyenv-default-packages"
    git clone https://github.com/pyenv/pyenv-virtualenv.git "${PYENV_PLUGINS}/pyenv-virtualenv"
    git clone https://github.com/pyenv/pyenv-doctor.git "${PYENV_PLUGINS}/pyenv-doctor"
    git clone https://github.com/pyenv/pyenv-ccache.git "${PYENV_PLUGINS}/pyenv-ccache"
    path=(${PYENV_ROOT}/bin ${path})
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
    pyenv install 3.12.7
    pyenv global 3.12.7
    pyenv rehash
}

__install_rbenv() {
    export RBENV_ROOT="${HOME}/.rbenv"
    export RBENV_PLUGINS="${RBENV_ROOT}/plugins"
    git clone https://github.com/rbenv/rbenv.git "${RBENV_ROOT}"
    zf_mkdir -p "${HOME}/.goenv"/{plugins,zsh,man/man1}
    git clone https://github.com/tpope/rbenv-aliases.git "${RBENV_PLUGINS}/rbenv-aliases"
    git clone https://github.com/ianheggie/rbenv-binstubs.git "${RBENV_PLUGINS}/rbenv-binstubs"
    git clone https://github.com/tpope/rbenv-ctags.git "${RBENV_PLUGINS}/rbenv-ctags"
    git clone https://github.com/rbenv/rbenv-default-gems.git "${RBENV_PLUGINS}/rbenv-default-gems"
    git clone https://github.com/ianheggie/rbenv-env.git "${RBENV_PLUGINS}/rbenv-env"
    git clone https://github.com/mlafeldt/rbenv-man.git "${RBENV_PLUGINS}/rbenv-man"
    git clone https://github.com/rbenv/ruby-build.git "${RBENV_PLUGINS}/ruby-build"
    path=(${HOME}/rbenv/bin ${path})
    # bundle install --binstubs "${HOME}/bundle/bin"
    eval "$(rbenv init -)"
    install_version=$(rbenv install -l | ggrep -E '^[0-9]' | tail -1)
    rbenv install $install_version
    rbenv global $install_version
    rbenv rehash
    rbenv alias --auto
    rbenv ctags
}

install_all_env_managers_description="install goenv, luaenv, nodenv, pyenv, rbenv"
install_env_managers() {
    __install_goenv
    __install_luaenv
    __install_nodenv
    __install_pyenv
    __install_rbenv
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# install rust coreutils

install_rust_coreutils() {
    export COREUTILS="${LOCAL_TOOLS}/coreutils"
    git clone https://github.com/uutils/coreutils "${COREUTILS}"
    cd "${COREUTILS}"
    gmake && gmake install && gmake clean
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# terminal styling happens here
if [ -t 1 ]; then
  is_tty() {
    true
  }
else
  is_tty() {
    false
  }
fi

supports_truecolor() {
  case "$COLORTERM" in
  truecolor|24bit) return 0 ;;
  esac

  case "$TERM" in
  iterm           |\
  tmux-truecolor  |\
  linux-truecolor |\
  xterm-truecolor |\
  screen-truecolor) return 0 ;;
  esac

  return 1
}

supports_hyperlinks() {
  # $FORCE_HYPERLINK must be set and be non-zero (this acts as a logic bypass)
  if [ -n "$FORCE_HYPERLINK" ]; then
    [ "$FORCE_HYPERLINK" != 0 ]
    return $?
  fi

  # If stdout is not a tty, it doesn't support hyperlinks
  is_tty || return 1

  # If $TERM_PROGRAM is set, these terminals support hyperlinks
  case "$TERM_PROGRAM" in
  Hyper|iTerm.app|terminology|WezTerm|vscode|tmux) return 0 ;;
  esac

  # These termcap entries support hyperlinks
  case "$TERM" in
  xterm-kitty|alacritty|alacritty-direct) return 0 ;;
  esac

  return 1
}

fmt_link() {
  # $1: text, $2: url, $3: fallback mode
  if supports_hyperlinks; then
    printf '\033]8;;%s\033\\%s\033]8;;\033\\\n' "$2" "$1"
    return
  fi

  case "$3" in
  --text) printf '%s\n' "$1" ;;
  --url|*) fmt_underline "$2" ;;
  esac
}

fmt_underline() {
  is_tty && printf '\033[4m%s\033[24m\n' "$*" || printf '%s\n' "$*"
}

# shellcheck disable=SC2016 # backtick in single-quote
fmt_code() {
  is_tty && printf '`\033[2m%s\033[22m`\n' "$*" || printf '`%s`\n' "$*"
}

fmt_error() {
  printf '%sError: %s%s\n' "${FMT_BOLD}${FMT_RED}" "$*" "$FMT_RESET" >&2
}

setup_color() {
  # Only use colors if connected to a terminal
  if ! is_tty; then
    FMT_RAINBOW=""
    FMT_RED=""
    FMT_GREEN=""
    FMT_YELLOW=""
    FMT_BLUE=""
    FMT_BOLD=""
    FMT_RESET=""
    return
  fi

  if supports_truecolor; then
    FMT_RAINBOW="
      $(printf '\033[38;2;255;0;0m')
      $(printf '\033[38;2;255;97;0m')
      $(printf '\033[38;2;247;255;0m')
      $(printf '\033[38;2;0;255;30m')
      $(printf '\033[38;2;77;0;255m')
      $(printf '\033[38;2;168;0;255m')
      $(printf '\033[38;2;245;0;172m')
    "
  else
    FMT_RAINBOW="
      $(printf '\033[38;5;196m')
      $(printf '\033[38;5;202m')
      $(printf '\033[38;5;226m')
      $(printf '\033[38;5;082m')
      $(printf '\033[38;5;021m')
      $(printf '\033[38;5;093m')
      $(printf '\033[38;5;163m')
    "
  fi

  FMT_RED=$(printf '\033[31m')
  FMT_GREEN=$(printf '\033[32m')
  FMT_YELLOW=$(printf '\033[33m')
  FMT_BLUE=$(printf '\033[34m')
  FMT_BOLD=$(printf '\033[1m')
  FMT_RESET=$(printf '\033[0m')
}

deploy_menu() {
    echo "${FMT_GREEN} install_fonts ${FMT_RESET} ${FMT_BLUE} - description $install_fonts_description ${FMT_RESET}"
    echo "${FMT_GREEN} install_homebrew_apps ${FMT_RESET} ${FMT_BLUE} - description $install_homebrew_apps_description $(fmt_link https://github.com/sudobashme/dotfiles/blob/main/configs/homebrew/homebrew_bundle_file) ${FMT_RESET}"
    echo "${FMT_GREEN} install_rust ${FMT_RESET} ${FMT_BLUE} - description $install_rust_description ${FMT_RESET}"
    echo "${FMT_GREEN} install_rust_apps ${FMT_RESET} ${FMT_BLUE} - description $install_rust_apps_description ${FMT_RESET}"
    echo "${FMT_GREEN} install_zsh_environment ${FMT_RESET} ${FMT_BLUE} - description $install_zsh_environment_description ${FMT_RESET}"
    echo "${FMT_GREEN} install_luajit ${FMT_RESET} ${FMT_BLUE} - description $install_luajit_description ${FMT_RESET}"
    echo "${FMT_GREEN} install_env_managers ${FMT_RESET} ${FMT_BLUE} - description $install_all_env_managers_description ${FMT_RESET}"
    echo "${FMT_GREEN} install_neovim ${FMT_RESET} ${FMT_BLUE} - description $install_neovim_description ${FMT_RESET}"
}

main() {
    umask g-w,o-w
    setup_color

    echo "${FMT_RED} WARNING ${FMT_RESET}"
    echo ""
    echo "${FMT_BLUE} You are attempting to source the deploy script for my dotfiles repo ${FMT_RESET}"
    echo "${FMT_BLUE} This should only load the installer functions into your environment ${FMT_RESET}"
    echo "${FMT_BLUE} If you chose to continue at a minimum it will at least temporarily ${FMT_RESET}"
    echo "${FMT_BLUE} change your ZDOTDIR/DOTFILES env's as well as set and create common ${FMT_RESET}"
    echo "${FMT_BLUE} XDG directories typically found on *nix based systems. IT is also ${FMT_RESET}"
    echo "${FMT_BLUE} assumed that you would have homebrew installed and if you continue ${FMT_RESET}"
    echo "${FMT_BLUE} it will be installed along with the git package. ${FMT_RESET}"
    echo ""
    echo "${FMT_YELLOW} Everything else is menu driven and requires user input to utilize. ${FMT_RESET}"
    echo ""
    echo "${FMT_BLUE} It is also assumed that you are already running zsh as your native ${FMT_RESET}"
    echo "${FMT_BLUE} shell. Since this script was written with the intent of running on ${FMT_RESET}"
    echo "${FMT_BLUE} macOS, and because macOS ships with zsh as its default shell, There ${FMT_RESET}"
    echo "${FMT_BLUE} is no reason to adapt this script to someone runnng bash for example. ${FMT_RESET}"
    echo ""
    read -r CHOICE\?"Do you want to continue? (y/n): "
    if [[ ${CHOICE} = 'y' ]]; then
        echo "${FMT_BLUE} Continuing... ${FMT_RESET}"
        echo ""
        evaluate_user_var
        evaluate_home_var
        zmodload zsh/files
        echo ""
        set_zdot_dir
        echo ""
        set_common_xdg_dirs
        echo ""
        set_dot_files_repo_location
        echo ""
        set_local_tools_dir
        echo ""
        echo "${FMT_YELLOW} !!! Initial checks completed successfully !!! ${FMT_RESET}"
        echo ""
        echo "${FMT_BLUE} At this point the script is done. ${FMT_RESET}"
        echo "${FMT_BLUE} All the functions are loaded but not yet executed. ${FMT_RESET}"
        echo "${FMT_BLUE} Execute the deploy_menu fuction to see a list of these functions ${FMT_RESET}"
        echo ""
    else
        echo "${FMT_RED} Exiting...  ${FMT_RESET}"
        exit 1
    fi
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# This is where the script actually begins after preloading all of the functions above
if [[ $1 = "--install" ]]; then
    evaluate_user_var
    evaluate_home_var
    zmodload zsh/files
    set_zdot_dir
    set_common_xdg_dirs
    set_dot_files_repo_location
    set_local_tools_dir
    install_fonts
    install_homebrew_apps
    install_rust
    install_rust_apps
    install_rust_coreutils
    install_zsh_environment
    install_luajit
    install_env_managers
    install_neovim
else
    main
fi
