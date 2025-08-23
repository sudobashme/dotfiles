#!/usr/bin/env zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#               repo: https://github.com/sudobashme/dotfiles
#               file: 00_tmux.zsh
#           filepath: ${ZDOTDIR}/rc.d/00_tmux.zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Start tmux, if it's first terminal tab, skip this on remote sessions and root/sudo
# Handoff to tmux early, as rest of the rc config isn't needed for this

if [[ -v TMUX ]]; then
    # if tmux socket exists
    if [[ $TERM_PROGRAM != "tmux" ]]; then
        # if term_program is not tmux (meaning tmux exists but you are not attached)
        tmux attach-session -t workspace
    fi
    # which obviously means you are already attached to tmux
else
    # since the tmux socket doesn't exist create it and attach
    tmux new-session -As workspace
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# EOF