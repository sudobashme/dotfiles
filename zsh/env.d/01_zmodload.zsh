#!/usr/bin/env zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#               repo: https://github.com/sudobashme/dotfiles
#               file: 01_zmodload.zsh
#           filepath: ${ZDOTDIR}/env.d/01_zmodload.zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Enable profiling, if requested via env var
# do `ZSH_ZPROF_ENABLE=1 exec zsh`
if [[ -v ZSH_ZPROF_ENABLE ]]; then
    zmodload zsh/zprof
fi

# Load zsh/files module to provide some builtins for file modifications
zmodload -F zsh/files b:zf_ln b:zf_mkdir b:zf_rm
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# EOF