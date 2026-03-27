#!/usr/bin/env zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#               repo: https://github.com/sudobashme/dotfiles
#               file: zshrc
#           filepath: ${DOTFILES}/zsh/zshrc
#      symbolic link: ${ZDOTDIR}/.zshrc
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

for conffile in ${ZDOTDIR}/rc.d/*; do
  source ${conffile}
done
unset conffile

eval "$(goenv init -)"
eval "$(luaenv init -)"
eval "$(nodenv init - zsh)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
eval "$(rbenv init - --no-rehash zsh)"
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
# eval "$(tree-sitter complete --shell zsh)"
eval "$(atuin init zsh)"

(( ${+commands[prettierd]} )) && { prettierd start} > /dev/null 2&>1
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#EOF
