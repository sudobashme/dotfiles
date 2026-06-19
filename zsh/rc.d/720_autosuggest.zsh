# Abbreviations (zsh-abbr)
ABBR_USER_ABBREVIATIONS_FILE="${ZDOTDIR}/plugins/abbreviations-store"
source "${ZDOTDIR}/plugins/abbr/zsh-abbr.zsh"
export MANPATH=${ZDOTDIR}/plugins/abbr/man:$MANPATH

# Autosuggestions are opt-in: they caused POSTDISPLAY to wedge the prompt in
# kitty/tmux until ^C.  Enable with: export ENABLE_ZSH_AUTOSUGGEST=1
[[ -n $ENABLE_ZSH_AUTOSUGGEST ]] || return 0

# === Autosuggestions ===
# NOTE: We deliberately do NOT load zsh-autocomplete here.
# It is a very heavy plugin that provides its own live completion/suggestion
# system and conflicts with zsh-autosuggestions + fzf-tab.
# If you ever want to experiment with it, load it *instead of* autosuggestions,
# not alongside it.

# Configuration — strategy/options before sourcing; clear-widgets after (so we
# keep the plugin defaults and only append ours).
# history + abbreviations only: the completion strategy spawns a zpty per
# keystroke and can stall or leave ghost text on empty/short buffers.
ZSH_AUTOSUGGEST_STRATEGY=(abbreviations history)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#5f5f5f"

source "${ZDOTDIR}/plugins/autosuggestions/zsh-autosuggestions.zsh"

# Sync mode: the plugin sets ZSH_AUTOSUGGEST_USE_ASYNC if the var exists at all.
# Async fetches can wedge ZLE until ^C in kitty/tmux when rapidly backspacing.
unset ZSH_AUTOSUGGEST_USE_ASYNC

# Bridge so that zsh-abbr abbreviations also appear in autosuggestions
source "${ZDOTDIR}/plugins/autosuggestions-abbreviations-strategy/zsh-autosuggestions-abbreviations-strategy.zsh"

# Treat deletes as "clear", not "modify". The modify wrapper restores
# POSTDISPLAY while KEYS_QUEUED_COUNT > 0 (rapid backspace), which makes the
# line look frozen when you erase a mistyped first character.
# autopair rebinds ^?/^H to autopair-delete — that is the real backspace path.
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(
    bracketed-paste
    autopair-delete
    autopair-delete-word
    backward-delete-char
    delete-char
    backward-kill-word
    kill-word
    backward-kill-line
    kill-line
)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# nvim: ft=zsh
# EOF