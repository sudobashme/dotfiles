#!/usr/bin/env zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#               repo: https://github.com/sudobashme/dotfiles
#               file: 185_zsh_navigation_tools.zsh
#           filepath: ${ZDOTDIR}/rc.d/185_zsh_navigation_tools.zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


fpath+=( ${ZDOTDIR}/plugins/zsh-navigation-tools )
source "${ZDOTDIR}/plugins/zsh-navigation-tools/zsh-navigation-tools.plugin.zsh"

autoload n-list n-cd n-env n-kill n-panelize n-options n-aliases n-functions n-history n-help

alias naliases=n-aliases ncd=n-cd nenv=n-env nfunctions=n-functions nhistory=n-history
alias nkill=n-kill noptions=n-options npanelize=n-panelize nhelp=n-help