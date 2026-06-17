# Line-editor fixes (loads last).
# Symptom: mistype → backspace to empty → line looks frozen until ^C.
# ^C runs send-break (exit ZLE). Mimic that when backspacing to an empty line.

autoload -Uz add-zle-hook-widget

# Application mode (smkx/rmkx) wedges input in tmux/kitty.
add-zle-hook-widget -D zle-line-init zle_application_mode_start 2>/dev/null
add-zle-hook-widget -D zle-line-finish zle_application_mode_stop 2>/dev/null

_zsh_scrub_ghost_suggestion() {
    (( $#BUFFER == 0 )) || return 0
    POSTDISPLAY=
    unset _ZSH_AUTOSUGGEST_LAST_HIGHLIGHT 2>/dev/null
    if (( ${+region_highlight} )); then
        region_highlight=( "${(@)region_highlight:#*memo=zsh-syntax-highlighting*}" )
    fi
}

_zsh_exit_line_edit_if_empty() {
    _zsh_scrub_ghost_suggestion
    BUFFER=
    CURSOR=0
    zle .send-break -w
}

add-zle-hook-widget zle-line-pre-redraw _zsh_scrub_ghost_suggestion

_zsh_backspace_direct() {
    emulate -L zsh

    if (( $#BUFFER <= 1 )); then
        _zsh_exit_line_edit_if_empty
        return 0
    fi

    zle .backward-delete-char -w "$@"
}

zle -N _zsh_backspace_direct

bindkey '^?' _zsh_backspace_direct
bindkey '^H' _zsh_backspace_direct
[[ -n ${terminfo[kbs]:-} ]] && bindkey "${terminfo[kbs]}" _zsh_backspace_direct