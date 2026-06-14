#!/usr/bin/env zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#               repo: https://github.com/sudobashme/dotfiles
#               file: 00_tmux.zsh
#           filepath: ${ZDOTDIR}/rc.d/00_tmux.zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Early tmux handoff for interactive shells.
#
# This runs as the very first rc file so we can skip loading the rest
# of the (heavy) configuration until we're inside tmux.
#
# Behavior:
# - Respects NO_TMUX or TMUX_AUTO_OFF to disable auto-start
# - Skips on SSH / root / non-interactive shells
# - Attaches to (or creates) a session named "workspace"
# - If you want a plain shell, just run: NO_TMUX=1 zsh  or  export NO_TMUX=1

# Only for interactive shells
[[ $- != *i* ]] && return

# Opt-out support
[[ -n $NO_TMUX || -n $TMUX_AUTO_OFF ]] && return

# Already inside tmux → nothing to do
[[ -n $TMUX ]] && return

# Don't force tmux on remote sessions or when running as root
[[ -n $SSH_CONNECTION || -n $SSH_TTY || $USER == root ]] && return

# Attach to existing "workspace" session or create it
exec tmux new-session -A -s workspace
# (using exec so we fully replace the shell process)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# EOF