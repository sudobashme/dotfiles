#!/usr/bin/env zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#               repo: https://github.com/sudobashme/dotfiles
#               file: zshrc
#           filepath: ${DOTFILES}/zsh/zshrc
#      symbolic link: ${ZDOTDIR}/.zshrc
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# `.zshrc' is sourced in interactive shells. It should contain commands to set
# up aliases, functions, options, key bindings, etc.
#
# ref: https://zsh.sourceforge.io/Intro/intro_3.html

for conffile in ${ZDOTDIR}/rc.d/*; do
    source ${conffile}
done
unset conffile

eval "$(carapace init zsh)"
eval "$(goenv init -)"
eval "$(luaenv init -)"
eval "$(nodenv init - zsh)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
eval "$(rbenv init - --no-rehash zsh)"
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(tree-sitter complete --shell zsh)"


