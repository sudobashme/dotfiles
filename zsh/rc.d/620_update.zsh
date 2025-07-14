#!/usr/bin/env zsh
# repo: https://github.com/sudobashme/dotfiles
# file: 62_updates.zsh
# filepath: ${ZDOTDIR}/rc.d/62_updates.zsh

# Colors
autoload -U colors && colors
local GREEN=$fg[green]
local NOCOLOR=$reset_color

# Helper function for error handling
__log_error() {
  print -P "%F{red}Error: $1%F{reset}"
}

# Update Xcode and Command Line Tools
__xcode_update__() {
  # Check if CLT installed
  if ! xcode-select -p >/dev/null 2>&1; then
    print -P "${GREEN}Installing Command Line Tools...${NOCOLOR}"
    xcode-select --install 2>/dev/null || __log_error "Failed to install Command Line Tools"
    return
  fi

  # Check for updates without sudo
  local updates=$(softwareupdate --list 2>&1)
  if echo "$updates" | grep -qi "no updates available"; then
    print -P "${GREEN}No software updates available.${NOCOLOR}"
    return
  fi

  # Updates available, try install (may prompt password)
  print -P "${GREEN}Installing software updates...${NOCOLOR}"
  if ! sudo softwareupdate --install --all --force 2>/dev/null; then
    # If failed and CLT update needed
    if echo "$updates" | grep -i "Command Line Tools"; then
      __log_error "Update failed. Removing and reinstalling CLT."
      sudo rm -rf /Library/Developer/CommandLineTools 2>/dev/null
      xcode-select --install 2>/dev/null || __log_error "Failed to reinstall Command Line Tools"
    else
      __log_error "Software update failed"
    fi
  fi

  # Accept Xcode license
  sudo xcodebuild -license accept 2>/dev/null || __log_error "Failed to accept Xcode license"
}

# Manage Homebrew Bundle file
__manage_brewfile__() {
  [[ -z $HOMEBREW_BUNDLE_FILE ]] && return 1
  if [[ -f $HOMEBREW_BUNDLE_FILE ]]; then
    cp -f $HOMEBREW_BUNDLE_FILE{,.bak}
    rm -f $HOMEBREW_BUNDLE_FILE;
    brew bundle dump; 
    if [[ $? == 0 ]]; then
      rm -f $HOMEBREW_BUNDLE_FILE.bak
    else
      __log_error "Failed to dump Brewfile"
      mv -f $HOMEBREW_BUNDLE_FILE{.bak,}
      return 1
    fi
  fi
}

# Update Homebrew
__brew_update_upgrade__() {
  local brew_bin
  brew_bin=$(command -v brew 2>/dev/null || echo "/opt/homebrew/bin/brew")
  
  if [[ ! -x $brew_bin ]]; then
    __log_error "Homebrew not found"
    return 1
  fi

  if ! $brew_bin update 2>&1 | tee -a $HOMEBREW_HISTORY_FILE; then
    __log_error "Homebrew update failed"
    return 1
  fi
  if ! $brew_bin upgrade 2>&1 | tee -a $HOMEBREW_HISTORY_FILE; then
    __log_error "Homebrew upgrade failed"
    return 1
  fi
  __manage_brewfile__
}

# Main update function
update() {
  local wherewasi=$PWD
  cd $HOME || { __log_error "Cannot cd to HOME"; return 1 }

  print -P "${GREEN}\n  Starting update process...${NOCOLOR}"
  
  # Xcode update
  print -P "${GREEN}\n  Updating Xcode...${NOCOLOR}"
  __xcode_update__

  # Homebrew update
  if command -v brew >/dev/null; then
    print -P "${GREEN}\n  Updating Homebrew...${NOCOLOR}"
    __brew_update_upgrade__
  fi

  # NeoVim update
  if command -v nvim >/dev/null; then
    print -P "${GREEN}\n  Updating NeoVim via Lazy.nvim...${NOCOLOR}"
    nvim --headless "+Lazy! sync" +qa 2>/dev/null || __log_error "NeoVim update failed"
  fi

  print -P "${GREEN}\n  Adding new update timestamp...${NOCOLOR}"
  # update_timestamp # Uncomment if implemented

  cd $wherewasi || { __log_error "Cannot return to original directory"; return 1 }
  print -P "${GREEN}\n  Done${NOCOLOR}"
}

alias up=update