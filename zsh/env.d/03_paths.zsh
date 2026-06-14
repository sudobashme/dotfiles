#!/usr/bin/env zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#               repo: https://github.com/sudobashme/dotfiles
#               file: 03_paths.zsh
#           filepath: ${ZDOTDIR}/env.d/03_paths.zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Add custom functions and completions
fpath=(${ZDOTDIR}/fpath ${fpath})

# Ensure we have local paths enabled
path=(/bin /sbin /usr/bin /usr/sbin ${path})

if [[ "${OSTYPE}" = darwin* ]]; then
    # Check whether homebrew available under new path
    if (( ! ${+commands[brew]} )) || [[ -x /opt/homebrew/bin/brew ]]; then
        path=(/opt/homebrew/bin ${path})
        path=(/opt/homebrew/sbin ${path})
    fi

    if (( ${+commands[brew]} )); then
        autoload -z evalcache
        evalcache brew shellenv

        # Enable gnu version of utilities on macOS, if installed
        for gnuutil in gnu-sed gnu-tar grep; do
            if [[ -d ${HOMEBREW_PREFIX}/opt/${gnuutil}/libexec/gnubin ]]; then
                path=(${HOMEBREW_PREFIX}/opt/${gnuutil}/libexec/gnubin ${path})
            fi
            if [[ -d ${HOMEBREW_PREFIX}/opt/${gnuutil}/libexec/gnuman ]]; then
                MANPATH="${HOMEBREW_PREFIX}/opt/${gnuutil}/libexec/gnuman:${MANPATH}"
            fi
        done
        # Prefer curl installed via brew
        if [[ -d ${HOMEBREW_PREFIX}/opt/curl/bin ]]; then
            path=(${HOMEBREW_PREFIX}/opt/curl/bin ${path})
        fi
        if [[ -d ${HOMEBREW_PREFIX}/opt/whois/bin ]]; then
            path=(${HOMEBREW_PREFIX}/opt/whois/bin ${path})
        fi
        if [[ -d ${HOMEBREW_PREFIX}/opt/openjdk/bin ]]; then
            path=(${HOMEBREW_PREFIX}/opt/openjdk/bin ${path})
        fi
    fi
fi

if [[ -f /usr/local/ibmcloud/bin/ibmcloud ]]; then
    path=(/usr/local/ibmcloud/bin ${path})
fi

# Enable local binaries and man pages
path=(${HOME}/.local/bin ${path})
export MANPATH="${XDG_DATA_HOME}/man:/usr/local/share/man:/usr/share/man:${MANPATH}"


# Add go binaries to paths
path=(${GOPATH}/bin ${path})
path=(${HOME}/.cargo/bin ${path})

if [[ -d ${NODE_MODULES_BIN} ]]; then
    path=(${NODE_MODULES_BIN} ${path})
fi

if [[ -d ${GOENV_ROOT} ]]; then
    path=(${GOENV_ROOT}/bin ${path})
fi
if [[ -d ${LUAENV_ROOT} ]]; then
    path=(${LUAENV_ROOT}/bin ${path})
fi
if [[ -d ${NODENV_ROOT} ]]; then
    path=(${NODENV_ROOT}/bin ${path})
fi
if [[ -d ${PYENV_ROOT} ]]; then
    path=(${PYENV_ROOT}/bin ${path})
fi
if [[ -d ${RBENV_ROOT} ]]; then
    path=(${RBENV_ROOT}/bin ${path})
fi

# add grok to path
if [[ -d ${HOME}/.grok ]]; then
    path=(${HOME}/.grok/bin ${path})
fi

# grok zsh completions (from official grok CLI installer)
if [[ -d ${HOME}/.grok/completions/zsh ]]; then
    fpath=(${HOME}/.grok/completions/zsh $fpath)
fi

path=(/usr/local/bin /usr/local/sbin ${path})

#. "${HOME}/.atuin/bin/env"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# EOF

