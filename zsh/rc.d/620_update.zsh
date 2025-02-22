#!/usr/bin/env zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#               repo: https://github.com/sudobashme/dotfiles
#               file: 62_updates.zsh
#           filepath: ${ZDOTDIR}/rc.d/62_updates.zsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #



function __xcode_update__() {
  if [[ -d $(xcode-select -p) ]]; then
    softwareupdate --all --install --force
    if [[ -z $? ]]; then
      # note this typically fails but it happens so little that I have never bothered to fix it
      # I found this article I think would fix it but just have not bothered implemenmting it
      # https://brettterpstra.com/2021/04/06/scripting-with-sudo-on-mac/
      sudo xcodebuild -license accept;
      sudo rm -rf /Library/Developer/CommandLineTools;
      sudo xcode-select --install;
    fi
  fi
}

__manage_brewfile__() {
  if [[ -f $HOMEBREW_BUNDLE_FILE ]]; then
    mv $HOMEBREW_BUNDLE_FILE{,.bak};
    brew bundle dump;
    if [[ $? == 0 ]]; then
      if [[ -f $HOMEBREW_BUNDLE_FILE ]]; then
        rm $HOMEBREW_BUNDLE_FILE.bak;
      fi
    fi
  fi
}

function __brew_update_upgrade__() {
  if command -v $(which brew) >/dev/null; then
    brew update && brew upgrade
  else
    /opt/homebrew/bin/brew update
    /opt/homebrew/bin/brew upgrade
  fi
  __manage_brewfile__
}

function update() {
    GREEN=$(tput setaf 2)
    NOCOLOR=$(tput sgr0)
    printf "${GREEN}\n\n\t...starting update process...\n\n${NOCOLOR}"
    wherewasi=$(pwd)
    cd ${HOME}
    printf "${GREEN}\n\n\t...updating xcode...\n\n${NOCOLOR}"
    __xcode_update__
    if [[ brew ]]; then
        printf "${GREEN}\n\n\t...updating homebrew...\n\n${NOCOLOR}"
        __brew_update_upgrade__
    fi
#    if [[ node ]]; then
#        printf "${GREEN}\n\n\t...updating node...\n\n${NOCOLOR}"
#        npm update -g && npm fund
#    fi
#    if [[ ruby ]]; then
#        printf "${GREEN}\n\n\t...updating ruby...\n\n${NOCOLOR}"
#        gem update
#    fi
#    if [[ omz ]]; then
#        printf "${GREEN}\n\n\t...updating Oh My ZSH...\n\n${NOCOLOR}"
#        omz update
#        printf "${GREEN}\n\n\t...reloading ohmyzsh...\n\n${NOCOLOR}"
#        omz reload
#    fi
    if [[ nvim ]]; then
        printf "${GREEN}\n\n\t...updating NeoVim via Lazy.nvim...\n\n${NOCOLOR}"
        lu
    fi
    printf "${GREEN}\n\n\t...adding new update timestamp...\n\n${NOCOLOR}"
    #update_timestamp
    cd $wherewasi
    printf "${GREEN}\n\n\t...done...\n\n${NOCOLOR}"
}
alias up=update;
