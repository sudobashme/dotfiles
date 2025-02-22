# !/bin/sh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# designed to bootstrap my entire environment

# 1.] install xcode command line extensions
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
sudo xcodebuild -license accept
sudo xcode-select --install

# 2.] install homebrew
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh) NONINTERACTIVE=1";
/opt/homebrew/bin/brew update;
/opt/homebrew/bin/brew install git zsh;

# 3.] install ohmyzsh
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended";

# 4.] clone my dotfiles repo
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
export XDG_CONFIG_HOME="${HOME}/.config";
/opt/homebrew/bin/git clone https://github.com/sudobashme/dotfiles $XDG_CONFIG_HOME/dotfiles;
export DOTFILE_REPO="$XDG_CONFIG_HOME/dotfiles";

# 5.] Install fonts
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
/opt/homebrew/bin/git clone https://github.com/powerline/fonts.git --depth=1;
/usr/bin/cd fonts;
./install.sh;
/usr/bin/cd .. ;
/bin/rm -rf fonts;

# 6.] Install powerlevel10k
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
/opt/homebrew/bin/git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $DOTFILE_REPO/oh-my-zsh/themes/powerlevel10k

# 7.] sym link nvim configs
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
/bin/ln -s $DOTFILE_REPO/nvim $XDG_CONFIG_HOME/nvim;


# 8.] sym link config files
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
/usr/bin/cd ${HOME};
for config in zshrc zshenv zprofile tmux.conf p10k.zsh iterm2_shell_integration.zsh gitconfig fzfrc;
do
    /bin/rm -rf ./.$config;
    /bin/ln -s $DOTFILE_REPO/$config .$config;
done

# 9.] restore apps via homebrew
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
/opt/homebrew/bin/brew bundle install --file=$DOTFILE_REPO/BrewFile


