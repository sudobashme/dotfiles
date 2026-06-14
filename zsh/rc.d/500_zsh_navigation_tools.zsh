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