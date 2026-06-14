#!/usr/bin/env zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#               repo: https://github.com/sudobashme/dotfiles
#               file: 600_cmdline_web_tools.zsh
#           filepath: ${ZDOTDIR}/rc.d/600_cmdline_web_tools.zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

if [[ -f "${LOCAL_TOOLS}/httpstat/httpstat.sh" ]]; then
	alias httpstat="bash ${LOCAL_TOOLS}/httpstat/httpstat.sh";
fi 

if [[ -f "${LOCAL_TOOLS}/testssl.sh/testssl.sh" ]]; then
	alias testssl="${LOCAL_TOOLS}/testssl.sh/testssl.sh";
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# EOF