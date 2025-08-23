#!/usr/bin/env zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#               repo: https://github.com/sudobashme/dotfiles
#               file: 04_editor.zsh
#           filepath: ${ZDOTDIR}/env.d/04_editor.zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# prefer nvim over vim
if (( ${+commands[nvim]} )); then
    export EDITOR=nvim
    export VISUAL=nvim
elif (( ${+commands[subl]} )); then
    export EDITOR=subl
    export VISUAL=subl
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# EOF