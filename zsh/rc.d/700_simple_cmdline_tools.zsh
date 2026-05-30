
HISTFILE="${XDG_CACHE_HOME}/zsh/history"
HISTSIZ=500000
SAVEHIST=500000



# Make less more friendly
if (( $#commands[(i)lesspipe(|.sh)] )); then
    export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
    export LESS_ADVANCED_PREPROCESSOR=1
fi



# Set cursor shape as I-beam before prompt, switch to block before executing commands
# https://invisible-island.net/ncurses/terminfo.ti.html#toc-_X_T_E_R_M__Features
# Ss - set cursor shape, usually 6 as argument means I-beam
# Se - reset cursor shape, which is usually block
if (( ${+terminfo[Ss]} && ${+terminfo[Se]} )); then
    _zsh_cursor_shape_reset() {
        echoti Se
    }

    _zsh_cursor_shape_ibeam() {
        echoti Ss 6
    }

    add-zsh-hook preexec _zsh_cursor_shape_reset
    add-zsh-hook precmd _zsh_cursor_shape_ibeam
fi




# Enable autoenv plugin
source "${ZDOTDIR}/plugins/autoenv/autoenv.zsh"



source "${ZDOTDIR}/plugins/window-title/zsh-window-title.zsh"
export MANPATH=${ZDOTDIR}/plugins/window-title/man:$MANPATH



# Autopairs plugin
source "${ZDOTDIR}/plugins/autopair/autopair.zsh"


# Highlighting plugin
source "${ZDOTDIR}/plugins/syntax-highlighting/zsh-syntax-highlighting.zsh"
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets regexp cursor)
# Highlight known abbrevations
typeset -A ZSH_HIGHLIGHT_REGEXP
ZSH_HIGHLIGHT_REGEXP+=('^[[:blank:][:space:]]*('${(j:|:)${(Qk)ABBR_REGULAR_USER_ABBREVIATIONS}}')$' 'fg=blue')


alias tldr="nocorrect noglob ${LOCAL_TOOLS}/tldr-bash-client/tldr"
alias tldr-lint="${LOCAL_TOOLS}/tldr-bash-client/tldr-lint"

source "${ZDOTDIR}/plugins/zsh-colored-man-pages/colored-man-pages.plugin.zsh"

source "${ZDOTDIR}/plugins/zsh-colorize-functions/zsh-colorize-functions.plugin.zsh"