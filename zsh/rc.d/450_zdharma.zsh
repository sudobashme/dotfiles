#!/usr/bin/env zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#               repo: https://github.com/sudobashme/dotfiles
#               file: 185_zsh_navigation_tools.zsh
#           filepath: ${ZDOTDIR}/rc.d/185_zsh_navigation_tools.zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


# zsh-navigation-tools (n-cd, n-kill, n-history, etc.)
# A set of TUI helpers. Quite old but some people love the n-* commands.
# These add noticeable startup cost. Disable with: export NO_ZSH_NAV_TOOLS=1
if [[ -z $NO_ZSH_NAV_TOOLS ]]; then
    fpath+=( ${ZDOTDIR}/plugins/zsh-navigation-tools )
    source "${ZDOTDIR}/plugins/zsh-navigation-tools/zsh-navigation-tools.plugin.zsh"

    autoload n-list n-cd n-env n-kill n-panelize n-options n-aliases n-functions n-history n-help

    alias naliases=n-aliases ncd=n-cd nenv=n-env nfunctions=n-functions nhistory=n-history
    alias nkill=n-kill noptions=n-options npanelize=n-panelize nhelp=n-help
fi
# zui + zbrowse are supporting libraries for zsh-navigation-tools.
# We skip them entirely if navigation tools are disabled.
if [[ -n $NO_ZSH_NAV_TOOLS ]]; then
    return
fi

__local_zplug=${ZDOTDIR}/plugins/zui/zui.plugin.zsh
__plugin_dir=${ZDOTDIR}/plugins/zui

if [[ -f $__local_zplug ]]; then
    source $__local_zplug
else
    if [[ ! -d $__plugin_dir ]]; then
        git clone https://github.com/zdharma-continuum/zui.git $__plugin_dir
    fi
    if [[ -f $__local_zplug ]]; then
        source $__local_zplug
    else
        echo "Warning: Failed to load ZUI plugin; file $__local_zplug not found after setup."
    fi
fi
unset __local_zplug __plugin_dir

__local_zplug=${ZDOTDIR}/plugins/zbrowse/zbrowse.plugin.zsh
__plugin_dir=${ZDOTDIR}/plugins/zbrowse

if [[ -f $__local_zplug ]]; then
    source $__local_zplug
else
    if [[ ! -d $__plugin_dir ]]; then
        git clone https://github.com/zdharma-continuum/zbrowse.git $__plugin_dir
    fi
    if [[ -f $__local_zplug ]]; then
        source $__local_zplug
    else
        echo "Warning: Failed to load ZBrowse plugin; file $__local_zplug not found after setup."
    fi
fi
unset __local_zplug __plugin_dir

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# nvim: ft=zsh
# EOF
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# nvim: ft=zsh
# EOF