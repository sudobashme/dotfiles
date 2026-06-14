# Abbreviations (zsh-abbr)
ABBR_USER_ABBREVIATIONS_FILE="${ZDOTDIR}/plugins/abbreviations-store"
source "${ZDOTDIR}/plugins/abbr/zsh-abbr.zsh"
export MANPATH=${ZDOTDIR}/plugins/abbr/man:$MANPATH

# === Autosuggestions ===
# NOTE: We deliberately do NOT load zsh-autocomplete here.
# It is a very heavy plugin that provides its own live completion/suggestion
# system and conflicts with zsh-autosuggestions + fzf-tab.
# If you ever want to experiment with it, load it *instead of* autosuggestions,
# not alongside it.

source "${ZDOTDIR}/plugins/autosuggestions/zsh-autosuggestions.zsh"

# Bridge so that zsh-abbr abbreviations also appear in autosuggestions
source "${ZDOTDIR}/plugins/autosuggestions-abbreviations-strategy/zsh-autosuggestions-abbreviations-strategy.zsh"

# Configuration
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste)
ZSH_AUTOSUGGEST_STRATEGY=(abbreviations history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20          # avoid slowdown on huge pastes
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#5f5f5f"  # subtle gray (tweak to taste)