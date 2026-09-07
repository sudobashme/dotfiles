


export FZF_THEME="
--color=fg: #EBDBB2 \
--color=bg: #282828 \
--color=hl: #FABD2F\\
--color=fg+:bold: #EBDBB2 \
--color=bg+: #665C54 \
--color=hl+: #FABD2F \
--color=gutter: #282828 \
--color=info: #D65D0E \
--color=separator: #282828 \
--color=border: #E7D7AD \
--color=label: #EEBD35 \
--color=prompt: #7FA2AC \
--color=spinner: #FABD2F \
--color=pointer:bold: #FABD2F \
--color=marker: #CC241D \
--color=header: #D65D0E \
--color=preview-fg: #EBDBB2 \
--color=preview-bg: #282828 \
"
export FZF_DEFAULT_OPTS='--ansi -m --height 40% --tmux bottom,40% --layout reverse --border top'
#export FZF_DEFAULT_OPTS="--ansi -m --height 50% --border"
# Try to use fd or ag, if available as default fzf command
if (( ${+commands[fd]} )); then
    export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --exclude .git --color=always'
    export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
elif (( ${+commands[rg]} )); then
    export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --color=always --glob "!.git/*"'
    export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
elif (( ${+commands[ag]} )); then
    export FZF_DEFAULT_COMMAND='ag --ignore .git --color -g ""'
    export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
fi
_fzf_key_bindings="${HOME}/.local/tools/fzf/shell/key-bindings.zsh"
if [[ -r "${_fzf_key_bindings}" ]]; then
    # fzf snapshots ${options} and restores it with eval; zsh 5.9.2 includes
    # the read-only zle option in that hash, which makes new shells print
    # "can't change option: zle". Strip only that option from the restore.
    source <(
        sed '/__fzf_key_bindings_options="options=/a\
  __fzf_key_bindings_options=${__fzf_key_bindings_options// zle on/}\
  __fzf_key_bindings_options=${__fzf_key_bindings_options// zle off/}' "${_fzf_key_bindings}"
    )
fi
unset _fzf_key_bindings

#export FZF_DEFAULT_COMMAND='rg --files'
#export FZF_DEFAULT_OPTS='-m --height 50% --border'

alias search='fzf --print0 --tmux | xargs -0 -o nvim'

# Open in tmux popup if on tmux, otherwise use --height mode
#export FZF_DEFAULT_OPTS='--height 40% --tmux bottom,40% --layout reverse --border top'

# Use fzf for tab completions
source "${ZDOTDIR}/plugins/fzf-tab/fzf-tab.zsh"

zstyle ':fzf-tab:*' prefix ''

if [[ -v TMUX ]]; then
    zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
fi


zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# nvim: ft=zsh
# EOF
