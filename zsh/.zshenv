#!/usr/bin/env zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#               repo: https://github.com/sudobashme/dotfiles
#               file: zshenv
#           filepath: ${DOTFILES}/zsh/zshenv
#      symbolic link: ${ZDOTDIR}/.zshenv; ${HOME}/.zshenv
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# checking for the presence of a non zero value for the variable ZDOTDIR
if [[ -z ${ZDOTDIR} ]]; then
    if [[ -d "${HOME}/.zsh" ]]; then
        export ZDOTDIR="${HOME}/.zsh"
    fi
fi

# DOTFILES dir is parent to ZDOTDIR in my setup so if this file is even executing
# then it should be but lets verify
if [[ -z ${DOTFILES} ]]; then
    # and if its not then we will set it here along with this .zshenv file
    local homezshenv="${HOME}/.zshenv"
    # and finish by exporting DOTFILES
    export DOTFILES=${homezshenv:A:h:h}
fi
# Now that we have done that this seems like a good time to unset global rc files
# Disable global zsh configuration
# We're doing all configuration ourselves
unsetopt GLOBAL_RCS
# Next its time to actually set our environmental variaables
# Source local env files
for envfile in ${ZDOTDIR}/env.d/*; do
    source ${envfile}
done
unset envfile
# once that is complete
# if this is an interactive shell then we are
# ready to process our zshrc file
if [[ "$-" == *i* ]]; then
  source ${ZDOTDIR}/.zshrc
fi
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# nvim: ft=zsh
# EOF
