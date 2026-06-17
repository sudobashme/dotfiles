#!/usr/bin/env zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#               repo: https://github.com/sudobashme/dotfiles
#               file: zshrc
#           filepath: ${DOTFILES}/zsh/zshrc
#      symbolic link: ${ZDOTDIR}/.zshrc
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Source all modular config first (env.d was already handled by .zshenv)
for conffile in ${ZDOTDIR}/rc.d/*; do
  source ${conffile}
done
unset conffile

# ------------------------------------------------------------------
# Tool initializers (cached where possible for faster startup)
# ------------------------------------------------------------------

# Starship instant prompt (must be sourced very early, before anything that prints)
# This dramatically speeds up the first prompt after shell startup.
_starship_instant_prompt="${XDG_CACHE_HOME}/starship/init.zsh"
if [[ ! -d "${XDG_CACHE_HOME}/starship" ]]; then
    mkdir -p "${XDG_CACHE_HOME}/starship"
fi

if [[ -r $_starship_instant_prompt ]]; then
    source "$_starship_instant_prompt"
else
    # First time: generate the cache (one-time cost)
    starship init zsh --print-full-init >| "$_starship_instant_prompt"
    source "$_starship_instant_prompt"
fi
unset _starship_instant_prompt

# Version managers and other inits — wrapped with evalcache when available
if (( ${+functions[evalcache]} )); then
    evalcache goenv init -
    evalcache luaenv init -
    evalcache nodenv init - zsh
    evalcache pyenv init -
    evalcache pyenv virtualenv-init -
    evalcache rbenv init - --no-rehash zsh
    evalcache zoxide init zsh
else
    # Fallback if evalcache isn't ready for some reason
    eval "$(goenv init -)"
    eval "$(luaenv init -)"
    eval "$(nodenv init - zsh)"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
    eval "$(rbenv init - --no-rehash zsh)"
    eval "$(zoxide init zsh)"
fi

# Starship is already fully initialized via the instant-prompt cache above.
# Running `starship init` again duplicates precmd hooks and can confuse ZLE redraw.

# eval "$(tree-sitter complete --shell zsh)"
# eval "$(atuin init zsh)"

# Start prettierd if present (fixed redirection)
(( ${+commands[prettierd]} )) && prettierd start >/dev/null 2>&1
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# nvim: ft=zsh
# EOF
