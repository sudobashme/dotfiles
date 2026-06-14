#!/usr/bin/env zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#               repo: https://github.com/sudobashme/dotfiles
#               file: 070_aliases.zsh
#           filepath: ${ZDOTDIR}/rc.d/070_aliases.zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Some handy suffix aliases
alias -s log=less
alias -s tex=nvim

# Override regular 'clear' with custom one, that puts promt at bottom
alias clear=clear-screen-soft-bottom

# Prefer nvim when installed
(( ${+commands[nvim]} )) && {
    alias e="nvim"
    alias nv="nvim"
    alias vi="nvim"
    alias vim="nvim"
    alias lu='''nvim --headless "+Lazy! sync" +qa'''
}

# Human file sizes
(( ${+commands[gdf]} )) && alias df="gdf --human-readable --print-type"
(( ${+commands[gdu]} )) && alias du="gdu --human-readable --total"

(( ${+commands[ggrep]} )) && alias grep="ggrep --color=auto --binary-files=without-match --devices=skip"
(( ${+commands[wget]} )) && alias wget="wget --hsts-file=${XDG_CACHE_HOME}/wget-hsts"
(( ${+commands[gls]} )) && {
    alias ls="gls --group-directories-first --color=auto --classify"
    #  alias ls="ls --group-directories-first --color=auto --hyperlink=auto --classify"
    alias ll="LC_COLLATE=C ls -l -v --almost-all --human-readable"
    alias lhat="ls -lhat"
    alias lha="ls -lha"
    alias la="ls -a"
}

# History suppression
(( ${+commands[clear]} )) && alias clear=" clear"
(( ${+commands[pwd]} )) && alias pwd=" pwd"
(( ${+commands[exit]} )) && alias exit=" exit"

# Safety
(( ${+commands[grm]} )) && alias rm="grm -I --preserve-root=all"

# Suppress suggestions and globbing, enable wrappers
(( ${+commands[gfind]} )) && alias find="noglob gfind"

(( ${+commands[gtouch]} )) && alias touch="nocorrect gtouch"
(( ${+commands[gmkdir]} )) && alias mkdir="nocorrect gmkdir"
(( ${+commands[cp]} )) && alias cp="cp --progress"
(( ${+commands[mv]} )) && alias mv="mv --progress"
(( ${+commands[ag]} )) && alias ag="noglob ag"
(( ${+commands[/opt/homebrew/bin/fd]} )) && alias fd="noglob fd --color=auto --unrestricted --show-errors"
(( ${+commands[man]} )) && alias man="nocorrect wrap-man"
(( ${+commands[sudo]} )) && alias sudo="noglob wrap-sudo " # trailing space is needed to enable alias expansion
(( ${+commands[grm]} )) && alias rm="grm" && alias rmd="grm -rf"
(( ${+commands[echo]} )) && alias path='echo -e ${PATH//:/\\n}'
(( ${+commands[history]} )) && alias h="history"
(( ${+commands[jobs]} )) && alias j="jobs"
(( ${+commands[open]} )) && alias o="open"
(( ${+commands[python]} )) && alias serve='python -m http.server'

[[ "$(command -v bat)" ]] && alias cat="bat"
[[ "$(command -v prettyping)" ]] && alias pping="prettyping --nolegend"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# GUI apps launched via the command line

# google chrome
[[ -n "/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome" ]] && {
    alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
    alias -s html=chrome
    alias -s org=chrome
    alias -s md=chrome
}
    
if [[ -f "${ZDOTDIR}/more.zsh.md" ]]; then
    alias morezsh='open "${ZDOTDIR}/more.zsh.md"'
    alias nfo='open "${ZDOTDIR}/more.zsh.md"'
fi

# sublime text
(( ${+commands[subl]} )) && {
    alias s="subl"
    alias dotfiles="subl --project ${DOTFILES}/.sublime/dotfiles.sublime-project"
    alias nvim_project="subl --project ${XDG_CONFIG_HOME}/nvim/.sublime/nvim.sublime-project"
    alias exabgp="subl --project ${HOME}/IBM/Repos/github.com/exabgp/.sublime/exabgp.sublime-project"
}

# OpenClaw + Grok integration
# OpenClaw already supports Grok models via xAI, but we can bridge this local Grok TUI (with full local tools, subagents, skills, ACP)
# using OpenClaw's built-in ACP client support.
(( ${+commands[openclaw]} )) && {
    alias oc="openclaw"
    alias oct="openclaw tui"
    alias oc-tui="openclaw tui"
    alias oc-chat="openclaw chat 2>/dev/null || openclaw terminal 2>/dev/null || openclaw tui"
    alias oc-doctor="openclaw doctor"
    alias oc-mcp="openclaw mcp"
    alias oc-agents="openclaw agents"

    # Bridge this Grok (local powerful instance) into OpenClaw via ACP
    # Usage: oc-grok [optional-cwd]
    # This lets OpenClaw's interface/agent system use this Grok's full local capabilities (file edits, commands, our skills, plan mode, etc.)
    oc-grok() {
        local cwd="${1:-.}"
        echo "Starting OpenClaw ACP client bridged to local Grok (cwd: $cwd)..."
        echo "This runs Grok's ACP server under the hood for full local tool access."
        echo "Note: Some xAI-specific extensions may cause protocol warnings/errors (partial integration)."
        openclaw acp --provenance off client --server grok-acp --cwd "$cwd"
    }

    # Quick alias for current dir
    oc-grok-here() {
        echo "Note: the ACP bridge to local Grok is partial (xAI extension mismatch)."
        echo "Recommended: use side-by-side (os-layer or oc-tui + grok in another pane)."
        echo "Trying the bridge anyway for experimentation..."
        oc-grok .
    }

    # Note: requires the grok-acp wrapper in ~/.local/bin (created as part of integration)
    # If not in PATH, add: export PATH="$HOME/.local/bin:$PATH" early in your zshenv or profile.

    # Launch OpenClaw TUI with a note about using Grok
    oc-with-grok() {
        echo "Tip: Inside OpenClaw you can use cloud Grok models (already configured), or use 'oc-grok' / acp client for this local instance."
        openclaw tui
    }
}

# Bonus: one-command side-by-side launcher for the Personal OS Layer (tmux-aware)
(( ${+commands[launch-os-layer]} )) && alias os-layer='launch-os-layer'

# Grok ACP helpers (for use with OpenClaw or other ACP clients like Neovim)
(( ${+commands[grok]} )) && {
    alias grok-acp="grok agent stdio"
    alias grok-acp-serve="grok agent serve"
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g CA="2>&1 | cat -A"
#alias -g C='| wc -l'
alias -g D="DISPLAY=:0.0"
alias -g DN=/dev/null
alias -g ED="export DISPLAY=:0.0"
alias -g EG='|& egrep'
alias -g EH='|& head'
alias -g EL='|& less'
alias -g ELS='|& less -S'
alias -g ETL='|& tail -20'
alias -g ET='|& tail'
alias -g F=' | fmt -'
alias -g G='| egrep'
alias -g H='| head'
alias -g HL='|& head -20'
alias -g Sk="*~(*.bz2|*.gz|*.tgz|*.zip|*.z)"
alias -g LL="2>&1 | less"
alias -g L="| less"
alias -g LS='| less -S'
alias -g MM='| most'
alias -g M='| more'
alias -g NE="2> /dev/null"
alias -g NS='| sort -n'
alias -g NUL="> /dev/null 2>&1"
alias -g PIPE='|'
alias -g R=' > /c/aaa/tee.txt '
alias -g RNS='| sort -nr'
alias -g S='| sort'
alias -g TL='| tail -20'
alias -g T='| tail'
alias -g US='| sort -u'
alias -g VM=/var/log/messages
alias -g X0G='| xargs -0 egrep'
alias -g X0='| xargs -0'
alias -g XG='| xargs egrep'
alias -g X='| xargs'

alias sa='source "${ZDOTDIR}/rc.d/250_aliases.zsh"'
alias grealpath="/usr/local/bin/realpath"

