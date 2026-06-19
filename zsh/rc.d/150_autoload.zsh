


# Initialize colors
autoload -Uz colors
colors

# Fullscreen command line edit
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# Ctrl+W stops on path delimiters
autoload -Uz select-word-style
select-word-style bash

# Enable run-help module
(( $+aliases[run-help] )) && unalias run-help
autoload -Uz run-help
alias help=run-help

# enable bracketed paste
autoload -Uz bracketed-paste-url-magic
zle -N bracketed-paste bracketed-paste-url-magic

# enable url-quote-magic
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# Use default provided history search widgets
autoload -Uz up-line-or-beginning-search
zle -N up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N down-line-or-beginning-search

# Ensure add-zsh-hook is loaded, as it's used in rc files
autoload -Uz add-zsh-hook

# Custom personal functions
# Don't use -U as we need aliases here
autoload -z lspath bag fgb fgd fgl fz ineachdir psg vpaste evalcache compdefcache

# Enable wrapper, if original command is available
(( ${+commands[man]} )) && autoload -z wrap-man
(( ${+commands[sudo]} )) && autoload -z wrap-sudo

# Lazy loader for the old OMZ diagnostics (omz_diagnostic_dump).
# We moved the heavy script out of rc.d/ so it no longer loads on every shell.
# This stub only sources the real file the first time you actually call it.
omz_diagnostic_dump() {
    local _diag_file="${DOTFILES}/zsh/legacy/850_omz_diagnostics.zsh"
    if [[ -f $_diag_file ]]; then
        source "$_diag_file"
        # Call the real function that was just defined by sourcing the file.
        # We do NOT unfunction here — the sourced file has already installed
        # the proper definition in the function table.
        omz_diagnostic_dump "$@"
    else
        print -u2 "omz_diagnostic_dump: diagnostics file not found at $_diag_file"
        return 1
    fi
}
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# nvim: ft=zsh
# EOF