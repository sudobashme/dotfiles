#!/usr/bin/env zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#               repo: https://github.com/sudobashme/dotfiles
#               file: zshenv
#           filepath: ${DOTFILES}/zsh/zshenv
#      symbolic link: ${ZDOTDIR}/.zshenv; ${HOME}/.zshenv
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# `.zshenv' is sourced on all invocations of the shell, unless the -f option is
# set. It should contain commands to set the command search path, plus other
# important environment variables. `.zshenv' should not contain commands that
# produce output or assume the shell is attached to a tty.
#
# ref: https://zsh.sourceforge.io/Intro/intro_3.html

# Determine own path if ZDOTDIR isn't set or home symlink exists

if [[ -z ${ZDOTDIR} ]]; then
    export ZDOTDIR="${HOME}/.zsh"
fi
# DOTFILES dir is parent to ZDOTDIR
if [[ -z ${DOTFILES} ]]; then
    local homezshenv="${HOME}/.zshenv"
    export DOTFILES=${homezshenv:A:h:h}
fi
# Disable global zsh configuration
# We're doing all configuration ourselves
unsetopt GLOBAL_RCS

# Source local env files
for envfile in ${ZDOTDIR}/env.d/*; do
    source ${envfile}
done
unset envfile

# once that is complete, if this is an interactive shell then we do
if [[ "$-" == *i* ]]; then
  source ${ZDOTDIR}/.zshrc
fi