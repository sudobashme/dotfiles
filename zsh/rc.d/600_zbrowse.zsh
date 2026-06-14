#!/usr/bin/env zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#               repo: https://github.com/sudobashme/dotfiles
#               file: 200_zbrowse.zsh
#           filepath: ${ZDOTDIR}/rc.d/200_zbrowse.zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

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
# EOF