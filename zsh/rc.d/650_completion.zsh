# Keep this in mind from zsh lovers
#
# https://gist.githubusercontent.com/jheidt/e8e7df15bc15d8b9faee/raw/cc7e59b121623b6f120c96294f91ed0aabb615f1/zsh-lovers
#
# See also man 1 zshcompctl zshcompsys zshcompwid.
# zshcompctl is the old style of zsh programmable completion, zshcompsys is the new completion system, zshcompwid are the zsh completion widgets.


zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'

# Completion tweaks
zstyle ':completion:*'              list-colors             "${(s.:.)LS_COLORS}"
zstyle ':completion:*'              list-dirs-first         true
zstyle ':completion:*'              verbose                 true
zstyle ':completion:*'              menu                    no
zstyle ':completion:*'              matcher-list            'm:{[:lower:]}={[:upper:]}'
zstyle ':completion::complete:*'    use-cache               true
zstyle ':completion::complete:*'    cache-path              "${XDG_CACHE_HOME}/zsh/compcache"
zstyle ':completion:*:descriptions' format                  [%d]
zstyle ':completion:*:manuals'      separate-sections       true
zstyle ':completion:*:cd:*'         ignore-parents parent   pwd

# Enable cached completions, if present
if [[ -d "${XDG_CACHE_HOME}/zsh/fpath" ]]; then
    fpath=("${XDG_CACHE_HOME}/zsh/fpath" ${fpath})
fi

# Additional completions
fpath=("${ZDOTDIR}/plugins/completions/src" ${fpath})
fpath=("${ZDOTDIR}/plugins/git-completion/src" ${fpath})


source "${HOME}/.local/tools/git-extras/etc/git-extras-completion.zsh"
zmodload zsh/complist

# Completion initialization with smart caching.
#
# We only fully rebuild the compdump roughly once a day.
# This avoids the expensive compinit on every shell startup.
#
# We deliberately use find -mtime here instead of zsh glob qualifiers
# because the qualifier approach is fragile across zsh versions and
# was previously broken in this file for a long time.
autoload -Uz compinit zrecompile

local compdump="${XDG_CACHE_HOME}/zsh/compdump"

# Rebuild if the dump is missing or older than 1 day (mtime +1)
if [[ ! -f $compdump || -n $(find "$compdump" -mtime +1 2>/dev/null) ]]; then
    compinit -i -u -d "$compdump"
    # Recompile the dump in the background for faster future startups
    { zrecompile -pq "$compdump" } &!
else
    compinit -i -u -C -d "$compdump"
fi

# Prevent other random compinit calls (e.g. from installers) from
# polluting ZDOTDIR or $HOME with stray .zcompdump files.
# We force the canonical location above.
export COMPDUMPFILE="$compdump"

# Enable bash completions too
autoload -Uz bashcompinit
bashcompinit
