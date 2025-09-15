[dev.to /phantas0s/understanding-and-configuring-zsh-3jnd](https://dev.to/phantas0s/understanding-and-configuring-zsh-3jnd)

Understanding and Configuring Zsh
=================================

Matthieu Cneude 21-27 minutes 8/24/2020

* * *

There are many boring tasks we repeat day after day: creating, copying, moving or searching files, launching again and again the same tools, docker containers, and whatnot.

For a developer, the shell is a precious asset which can increase your efficiency over time. It will bring powerful tools at your fingertips, and, more importantly, it will allow you to automate many parts of your workflow.

To leverage these functionalities, you'll need a powerful and flexible shell. Today, I would like to present your next best friend: the Z shell, or Zsh.

If you look at the documentation (around 450 pages for the [PDF version](http://zsh.sourceforge.net/Doc/zsh_a4.pdf)), Zsh can feel daunting. There are so many options available, it can be difficult to come up with a basic configuration you can build upon.

We'll build, in this article, a basic Zsh config. I'll explain the meaning of (almost) everything along the way, including:

*   What's a Unix shell.
*   Why Zsh is a good choice.
*   How to install Zsh.
*   A brief overview of:
    *   Useful environment variables.
    *   Aliases.
    *   The Zsh options.
    *   The Zsh completion.
    *   The Zsh prompt.
    *   The Zsh directory stack.
*   How to configure Zsh to make it Vim-like.
*   How to add external plugins to Zsh.
*   External programs you can use to improve your Zsh experience.

Are your keyboard ready? Are you fingers warm? Did you stretch your arms? Let's begin, then!

[](#brief-unix-shell-overview)Brief Unix Shell Overview
-------------------------------------------------------

A shell _interpret_ command lines. You can type them using a prompt in an _interactive shell_, or you can run shell scripts using a _non-interactive shell_.

The shell run just after you logged in with your user. You can imagine the shell as the layer directly above the kernel of Unix-based operating systems (including Linux). Here's the charismatic [Brian Kernighan explaining it casually with his feet on a table](https://youtu.be/tc4ROCJYbm0?t=248).

When you use a graphical interface (or GUI), you click around with your mouse to perform tasks. When you use a shell, you use plain text instead.

If you use a graphical interface (like a windows manager or a desktop environment), you'll need a _terminal emulator_ to access the shell. In the old days, a [terminal was a real device](https://en.wikipedia.org/wiki/Computer_terminal). Nowadays, it's a program.

The shell gives you access to many powerful programs. They are called CLIs, or Command Line Interfaces.

At that point, you might wonder: why using a shell, instead of a graphical interface?

*   It's difficult to get a graphical interface right, especially if your software has many functionalities. It can be simpler to build a CLI to avoid some complexity.
*   CLIs are usually faster.
*   A developer deals often with plain text. CLIs are great for that.
*   Many shells, like Linux shells, allow you to pipe CLIs together in order to create a powerful transformation flow.
*   It's easier to automate textual commands rather than actions on a graphical interface.

> Play around with your command shell, and you'll be surprised at how much more productive it makes you.  
> _The Pragmatic Programmer_

A shell is the keystone of a Mouseless Development Environment, and the most powerful tool you can use as a developer.

* * *

_I'm currently writing a [book to build your own Mouseless Development Environment](https://themouseless.dev/), where I explain how to combine powerful tools to improve and customize your development worklow._

* * *

[](#why-zsh)Why Zsh?
--------------------

There are other Linux shells available out there, including the famous [Bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)). Why using Zsh?

*   The level of flexibility and customization of Zsh is crazy.
*   You have access to a powerful auto-completion for your favorite CLIs.
*   The Vi mode is golden for every Vim lovers.
*   There is an important and active community around Zsh.
*   Bash scripts are (mostly) compatible with Zsh.

[](#framework-or-no-framework)Framework Or No Framework?
--------------------------------------------------------

You'll see many advising you to install a Zsh framework with a crazy number of plugins, options, aliases, all already configured. The famous ones are [Oh My Zsh](https://ohmyz.sh/) and [prezto](https://github.com/sorin-ionescu/prezto).

I tried this approach for years and I think the drawbacks outweigh the benefits:

*   I have no clue what's included in these frameworks. When I read their documentations, I can't possibly remember everything it sets. Therefore, I barely use 10% of the functionalities.
*   Zsh has already many functionalities and options, it's even more daunting to have a framework on top.
*   A framework is a big external dependency which brings more complexity. If there is a conflict with my own configuration or a bug, it can take a long time to figure out what's happening.
*   A framework impose rules and way of doing I don't necessarily want, or need.

Don't get me wrong: these frameworks are incredible feats. They can be useful to get some inspiration for your own configuration. But I wouldn't use them directly.

[](#let-the-party-begin)Let The Party Begin
-------------------------------------------

We'll now configure Zsh. If the files or folders I'm speaking about don't exist, you need to create them.

This configuration was tested with a Linux based system. I have no idea about macOS, but it should work.

### [](#installing-zsh)Installing Zsh

You can install Zsh like everything else:

*   Debian / Ubuntu: `sudo apt install zsh`
*   Red Hat: `sudo yum install zsh`
*   Arch Linux: `sudo pacman -S zsh`
*   macOS (with brew): `brew install zsh`

Then, run it in a terminal by typing `zsh`.

### [](#zsh-config-files)Zsh Config Files

To configure Zsh for your user's session, you can use the following files:

*   `$ZDOTDIR/.zshenv`
*   `$ZDOTDIR/.zprofile`
*   `$ZDOTDIR/.zshrc`
*   `$ZDOTDIR/.zlogin`
*   `$ZDOTDIR/.zlogout`

In case you wonder what `$ZDOTDIR` stands for, we'll come back to it soon.

Zsh read these files in the following order:

1.  `.zshenv` - Should only contain user's environment variables.
2.  `.zprofile` - Can be used to execute commands just after logging in.
3.  `.zshrc` - Should be used for the shell configuration and for executing commands.
4.  `.zlogin` - Same purpose than `.zprofile`, but read just after `.zshrc`.
5.  `.zlogout` - Can be used to execute commands when a shell exit.

We'll use only `.zshenv` and `.zshrc` in this article.

### [](#zsh-configuration-path)Zsh Configuration Path

By default, Zsh will try to find the user's configuration files in the `$HOME` directory. You can change it by setting the environment variable `$ZDOTDIR`.

Personally, I like to have all my configuration files in `$HOME/.config`. To do so:

1.  I set the variable `$XDG_CONFIG_HOME` as following: `export XDG_CONFIG_HOME="$HOME/.config"`.
2.  I set the environment variable `$ZDOTDIR`: `export $ZDOTDIR="$XDG_CONFIG_HOME/zsh"`.
3.  I put the file `.zshrc` in the `$ZDOTDIR` directory.

Most software will use the path in `$XDG_CONFIG_HOME` to install their own config files. As a result, you'll have a clean `$HOME` directory.

Unfortunately, the file `.zshenv` **needs to be in your home directory**. It's where you'll set `$ZDOTDIR`. Then, every file read after `.zshenv` can go into your `$ZDOTDIR` directory.

[](#zsh-basic-configuration)Zsh Basic Configuration
---------------------------------------------------

### [](#environment-variables)Environment Variables

As we saw, you can set the environment variables you need for your user's session in the file `$HOME/.zshenv`. This file should only define environment variables.

For example, you can set up the [XDG Base directory](https://wiki.archlinux.org/index.php/XDG_Base_Directory) there, as seen above:  

    export XDG_CONFIG_HOME="$HOME/.config"
    export XDG_DATA_HOME="$XDG_CONFIG_HOME/local/share"
    export XDG_CACHE_HOME="$XDG_CONFIG_HOME/cache"
    

Enter fullscreen mode Exit fullscreen mode

You can as well make sure that any program requiring a text editor use your favorite one:  

    export EDITOR="nvim"
    export VISUAL="nvim"
    

Enter fullscreen mode Exit fullscreen mode

You can set some Zsh environment variables, too:  

    export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
    
    export HISTFILE="$ZDOTDIR/.zhistory"    # History filepath
    export HISTSIZE=10000                   # Maximum events for internal history
    export SAVEHIST=10000                   # Maximum events in history file
    

Enter fullscreen mode Exit fullscreen mode

I already explained the first line. For the other ones, they will:

*   Store your command line history in the file `.zhistory`.
*   Allows you to have a history of 10000 entries maximum.

[Here's my .zshenv file](https://github.com/Phantas0s/.dotfiles/blob/master/zsh/zshenv), if you need some inspiration.

### [](#aliases)Aliases

Aliases are crucial to improve your efficiency. For example, I have a bunch of aliases for git I use all the time. It's always easier to type when it's shorter:  

    alias gs='git status'
    alias ga='git add'
    alias gp='git push'
    alias gpo='git push origin'
    alias gtd='git tag --delete'
    alias gtdr='git tag --delete origin'
    alias gr='git branch -r'
    alias gplo='git pull origin'
    alias gb='git branch '
    alias gc='git commit'
    alias gd='git diff'
    alias gco='git checkout '
    alias gl='git log'
    alias gr='git remote'
    alias grs='git remote show'
    alias glo='git log --pretty="oneline"'
    alias glol='git log --graph --oneline --decorate'
    

Enter fullscreen mode Exit fullscreen mode

I like to have my aliases in one separate file (called, surprisingly, `aliases`), and I source it in my `.zshrc`:  

    `source /path/to/my/aliases`
    

Enter fullscreen mode Exit fullscreen mode

Here are [all my aliases](https://github.com/Phantas0s/.dotfiles/blob/master/aliases/aliases).

### [](#zsh-options)Zsh Options

You can set or unset many [Zsh options](http://zsh.sourceforge.net/Doc/Release/Options.html) using `setopt` or `unsetopt`. For example:  

    setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
    unsetopt HIST_SAVE_NO_DUPS       # Write a duplicate event to the history file
    

Enter fullscreen mode Exit fullscreen mode

You can already do a lot of customization only using these options.

### [](#zsh-completion-system)Zsh Completion System

The completion system of Zsh is one of its bigger strength, compared to other shells.

To initialize the completion for the current Zsh session, you'll need to call the function `compinit`. More precisely, you'll need to add this in your `zshrc`:  

    autoload -Uz compinit; compinit
    

Enter fullscreen mode Exit fullscreen mode

What does it mean?

The `autoload` command load a file containing shell commands. To find this file, Zsh will look in the directories of the _Zsh file search path_, defined in the variable `$fpath`, and search a file called `compinit`.

When `compinit` is found, its content will be loaded as a _function_. The function name will be the name of the file. You can then call this function like any other shell function.

Why using autoload, and not sourcing the file by doing `source ~/path/of/compinit`?

*   It avoids name conflicts if you have an executable with the same name.
*   It doesn't expand aliases thanks to the `-U` option.
*   It will load the function only when it's needed (lazy-loading). It comes in handy to speed up Zsh startup.

The `-z` option tells Zsh that your function is written using "Zsh style". I'm not sure what's the "Zsh style", but it's an idiomatic way to autoload functions.

Then, let's add the following;  

    _comp_options+=(globdots) # With hidden files
    source /my/path/to/zsh/completion.zsh
    

Enter fullscreen mode Exit fullscreen mode

The first line will auto-complete [dotfiles](https://wiki.archlinux.org/index.php/Dotfiles).

The second line source [this file](https://github.com/Phantas0s/.dotfiles/blob/master/zsh/plugins/completion.zsh) which is from the Zsh framework [prezto](https://github.com/sorin-ionescu/prezto). I basically pruned everything I didn't want. The original file is [here](https://github.com/sorin-ionescu/prezto/blob/master/modules/completion/init.zsh).

If you open this completion file, you'll see many instances of the command `zstyle`. It can be used to [define and lookup styles for Zsh](http://zsh.sourceforge.net/Doc/Release/Zsh-Modules.html#The-zsh_002fzutil-Module). You can play around with it to understand what it does.

Now, the auto-completion should work:

*   If you type `cp` and hit the tab key, you'll see that Zsh will auto-complete the command.
*   If you type `cp -` and hit the tab key, Zsh will display the possible arguments for the command.

[![Zsh auto-completion in action](https://media2.dev.to/dynamic/image/width=800%2Cheight=%2Cfit=scale-down%2Cgravity=auto%2Cformat=auto/https%3A%2F%2Fthevaluable.dev%2Fimages%2F2020%2Fzsh%2Fauto_complete.png)](https://media2.dev.to/dynamic/image/width=800%2Cheight=%2Cfit=scale-down%2Cgravity=auto%2Cformat=auto/https%3A%2F%2Fthevaluable.dev%2Fimages%2F2020%2Fzsh%2Fauto_complete.png)

### [](#pimp-my-zsh-prompt)Pimp My Zsh Prompt

What would be the shell experience without a nice prompt? Dull. Tasteless. Depressing.

Let's be honest here: Zsh default prompt is ugly. We need to change it, before our eyes start crying some blood. My needs are simple:

*   The prompt needs to be on one line. I had display problems with two lines.
*   The prompt needs to display some git info when necessary.

From there, I created [my own prompt](https://github.com/Phantas0s/purification/blob/master/prompt_purification_setup) from [another one](https://github.com/therealklanni/purity). It looks like that:

[![Zsh prompt](https://media2.dev.to/dynamic/image/width=800%2Cheight=%2Cfit=scale-down%2Cgravity=auto%2Cformat=auto/https%3A%2F%2Fthevaluable.dev%2Fimages%2F2020%2Fzsh%2Fprompt.png)](https://media2.dev.to/dynamic/image/width=800%2Cheight=%2Cfit=scale-down%2Cgravity=auto%2Cformat=auto/https%3A%2F%2Fthevaluable.dev%2Fimages%2F2020%2Fzsh%2Fprompt.png)

If you open the prompt script, you'll see that it's pretty simple:

*   I set two environment variables: `$PROMPT` and `$RPROMPT`. The first one format the left prompt, the second display git information on the far right.
*   You can add some formatting styles using, for example, `%F{blue}%f` to change the color, or `%Bmy-cool-prompt%b` to make everything bold.

This prompt doesn't need any external dependency. You can copy it right away and modify it as much as you want.

[Here's everything you need, to create the prompt of your dream](http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html).

To load the prompt, you need to add something like that in your `zshrc`:  

    fpath=(/my/path/to/zsh/prompt $fpath)
    autoload -Uz name_of_the_prompt_file; name_of_the_prompt_file
    

Enter fullscreen mode Exit fullscreen mode

The first line will add the folder containing the prompt to `$fpath`, as discussed above. It will ensure as well that any function declared in the folder `/my/path/to/zsh/prompt` will overwrite every other ones with the same name, in other `fpath` folders.

The second line autoload the prompt itself.

This prompt require [font awesome 4](https://fontawesome.com/v4.7.0/) for the git icons. You can download the font and install it, or you can change the icons.

### [](#zsh-directory-stack)Zsh Directory Stack

Zsh has commands to [push and pop directory on a directory stack](http://zsh.sourceforge.net/Intro/intro_6.html). Bash as well, if you didn't know.

By manipulating this stack, you can set up an history of directory visited, and be able to jump back to these directories.

First, let's set some options in your `.zshrc`:  

    setopt AUTO_PUSHD           # Push the current directory visited on the stack.
    setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
    setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.
    

Enter fullscreen mode Exit fullscreen mode

Then, you can create these aliases:  

    alias d='dirs -v'
    for index ({1..9}) alias "$index"="cd +${index}"; unset index
    

Enter fullscreen mode Exit fullscreen mode

What does it do?

*   Every directory visited will populate the stack.
*   When you use the alias `d`, it will display the directories on the stack prefixed with a number.
*   The line `for index ({1..9}) alias "$index"="cd +${index}"; unset index` will create aliases from 1 to 9. They will allow you to jump directly in whatever directory on your stack.

For example, if you execute `1` in Zsh, you'll jump to the directory prefixed with `1` in your stack list.

You can as well increase `index ({1..9})` to `index ({1..100})` for example, if you want to be able to jump back to 100 directories.

Here's how it looks like:

[![Zsh directory stack example](https://media2.dev.to/dynamic/image/width=800%2Cheight=%2Cfit=scale-down%2Cgravity=auto%2Cformat=auto/https%3A%2F%2Fthevaluable.dev%2Fimages%2F2020%2Fzsh%2Fdirectory_stack.png)](https://media2.dev.to/dynamic/image/width=800%2Cheight=%2Cfit=scale-down%2Cgravity=auto%2Cformat=auto/https%3A%2F%2Fthevaluable.dev%2Fimages%2F2020%2Fzsh%2Fdirectory_stack.png)

### [](#zsh-by-default)Zsh By Default

When you're ready psychologically to set Zsh as your default shell, you can run these commands:

*   For Linux: `chsh -s $(which zsh)`
*   For macOS: `sudo sh -c "echo $(which zsh) >> /etc/shells" && chsh -s $(which zsh)`

Zsh is now part of your life. Congratulation!

[](#zsh-with-vim-flavors)Zsh With Vim Flavors
---------------------------------------------

For editing purposes, [Vim is my best friend](https://thevaluable.dev/phpstorm-vs-vim/). I love when CLIs use some Vim key binding, and Zsh gives you even more than that.

### [](#activating-vi-mode)Activating Vi Mode

Zsh has a Vi mode you can enable by adding the following in your `.zshrc`:  

    bindkey -v
    export KEYTIMEOUT=1
    

Enter fullscreen mode Exit fullscreen mode

You can now switch between INSERT and NORMAL mode (called as well COMMAND mode) with `esc`. I write the different modes in uppercase here for clarity, but it doesn't have to be.

The second line `export KEYTIMEOUT=1` makes the switch between modes quicker.

### [](#changing-cursor)Changing Cursor

A visual indicator to show the current mode (NORMAL or INSERT) could be nice. In Vim, my cursor is a beam `|` when I'm in INSERT mode, and a block `█` when I'm in NORMAL mode. I wanted the same for Zsh.

You can add the following in your `zshrc`, or autoload it from a file, [as I did](https://github.com/Phantas0s/.dotfiles/blob/master/zsh/plugins/cursor_mode).  

    cursor_mode() {
        # See https://ttssh2.osdn.jp/manual/4/en/usage/tips/vim.html for cursor shapes
        cursor_block='\e[2 q'
        cursor_beam='\e[6 q'
    
        function zle-keymap-select {
            if [[ ${KEYMAP} == vicmd ]] ||
                [[ $1 = 'block' ]]; then
                echo -ne $cursor_block
            elif [[ ${KEYMAP} == main ]] ||
                [[ ${KEYMAP} == viins ]] ||
                [[ ${KEYMAP} = '' ]] ||
                [[ $1 = 'beam' ]]; then
                echo -ne $cursor_beam
            fi
        }
    
        zle-line-init() {
            echo -ne $cursor_beam
        }
    
        zle -N zle-keymap-select
        zle -N zle-line-init
    }
    
    cursor_mode
    

Enter fullscreen mode Exit fullscreen mode

You can now speak about beam and block with passion and verve.

### [](#vim-mapping-for-completion)Vim Mapping For Completion

To give Zsh even more of a Vim taste, we can set up the keys `hjkl` to navigate the auto-completion menu.

First, add the following to your `zshrc`:  

    zmodload zsh/complist
    bindkey -M menuselect 'h' vi-backward-char
    bindkey -M menuselect 'k' vi-up-line-or-history
    bindkey -M menuselect 'l' vi-forward-char
    bindkey -M menuselect 'j' vi-down-line-or-history
    

Enter fullscreen mode Exit fullscreen mode

We load here the Zsh module `complist`. Modules have functionalities which are not part of the Zsh's core, but they can be loaded on demand. [Many different modules are available](http://zsh.sourceforge.net/Doc/Release/Zsh-Modules.html).

Here, the module `complist` give you access to `menuselect`, to customize the way you can move your completion cursor around.

The command `bindkey -M` bind a key to the command `menuselect`.

### [](#editing-command-lines-in-vim)Editing Command Lines In Vim

You can use as well your favorite editor to edit Zsh commands:  

    autoload -Uz edit-command-line
    zle -N edit-command-line
    bindkey -M vicmd v edit-command-line
    

Enter fullscreen mode Exit fullscreen mode

Here, we autoload `edit-command-line`, a function from [zshcontrib](https://linux.die.net/man/1/zshcontrib), a melting pot of contributions from Zsh users.

The function `edit-command-line` let you edit a command line in a text editor. Great! That's what we wanted.

We already saw `bindkey -M`. If you add `vicmd` to it, the keystroke will only work when you're in NORMAL mode (called COMMAND mode in the Zsh documentation). You can find [all possible Zsh modes (keymaps) here](http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Keymaps).

[](#zsh-plugins)Zsh Plugins
---------------------------

The term "plugin", as I use it, has nothing official. People often speak about Zsh plugins as external pieces of configuration you can add to your own.

There are many of these plugins available for Zsh. Many of them are part of Zsh frameworks.

### [](#zsh-completions)Zsh Completions

By default, Zsh can auto-complete already many popular CLIs like `cd`, `cp`, `git`, and so on.

The plugin [zsh-completions](https://github.com/zsh-users/zsh-completions) add even more auto-completions. The [list of the newly supported CLIs is here](https://github.com/zsh-users/zsh-completions/tree/master/src)

If you don't use any of the program listed, you don't need this plugin.

I added `zsh-completion` as a [git submodule in my dotfiles](https://github.com/Phantas0s/.dotfiles/blob/master/.gitmodules). Then, you can automatically add every auto-completions to your `fpath`, in your zshrc:  

    fpath=(/path/to/my/zsh/plugins/zsh-completions/src $fpath)
    

Enter fullscreen mode Exit fullscreen mode

You don't need to load every completion file, one by one. If you look at the beginning of one of these files, you'll see `compdef`. It's a function from Zsh which load automagically the completion when it's needed. The completion file itself only needs to be included in your `fpath`.

You can as well cherry-pick the specific completions you want.

### [](#zsh-syntax-highlighting)Zsh Syntax Highlighting

What about syntax highlighting in Zsh? That's what [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) is about.

You can source it directly:  

    source /path/to/my/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    

Enter fullscreen mode Exit fullscreen mode

You should source this plugin at the bottom of your `zshrc`. Everything loaded before will then be able to use syntax highlighting if needed.

### [](#jumping-to-a-parent-directory-with-bd)Jumping To A Parent Directory With bd

Do you like to type `cd ../../..` to come back to the great-grand-parent of the current folder?

Me neither.

It's where [bd](https://github.com/Tarrasch/zsh-bd) can help you. Imagine that you're in the folder `~/a/b/c/d`. You can jump directly to `a` with the command `bd a`.

The Zsh auto-completion is even included. Awesomeness!

To use it, you need to source the file [bd.zsh](https://github.com/Tarrasch/zsh-bd/blob/master/bd.zsh).

I created in my config a file [bd](https://github.com/Phantas0s/.dotfiles/blob/master/zsh/plugins/bd), which source the file `bd.zsh`. Then, I can autoload `bd` in my `zshrc`: `autoload -Uz bd; bd`. It's the same technique used by Zsh Syntax Highlighting.

[](#custom-scripts)Custom Scripts
---------------------------------

Using a shell allows you to automate many parts of your workflow with shell scripts. That's a huge benefit you should take advantage of.

I keep most of [my scripts in one file](https://github.com/Phantas0s/.dotfiles/blob/master/zsh/scripts.zsh) and I [document them](https://github.com/Phantas0s/.dotfiles/tree/master/zsh) (roughly) for me to remember what's in there, and for others to get inspired.

I source the functions in my `.zshrc`, but you could autoload them too.

While working, ask yourself what tasks you do again and again, to automate them as much as you can. This is the real power of the shell, and it will make your whole workflow more fun.

[](#external-programs)External Programs
---------------------------------------

A shell without CLIs would be useless. Here are my personal favorites to expand Zsh functionalities.

### [](#multiplex-your-zsh-with-tmux)Multiplex Your Zsh With tmux

I've already [written about tmux here](https://thevaluable.dev/tmux-boost-productivity-terminal/). It's a terminal multiplexer with a ton of functionalities.

It allows you to split your terminal in different shells, in different windows, synchronize them, and much more. You can even extend it with plugins, which can automate tmux itself.

### [](#fuzzy-search-with-fzf)Fuzzy Search With fzf

The fuzzy finder `fzf` is a fast and powerful tool. You can use it to search anything you want, like a file, an entry in your command line history, or a specific git commit message.

I wrote (or copied and pasted) a bunch of [scripts using zsh](https://github.com/Phantas0s/.dotfiles/blob/master/zsh/scripts_fzf.zsh) too, to search through git logs or `tmuxp` projects.

There are different ways to install `fzf`. You'll need first the executable. Then, I would recommend sourcing the files:

*   `key-bindings.zsh`, which will include some practical keystrokes like `Ctrl-h` or `Ctrl-t`
*   `completion.zsh`, for `fzf` auto-completion.

If you use Arch Linux, you'll need to install the package `fzf` and simply source these two files in your `zshrc`:  

    source /usr/share/fzf/completion.zsh
    source /usr/share/fzf/key-bindings.zsh
    

Enter fullscreen mode Exit fullscreen mode

Otherwise, you'll need to follow the installation process from fzf's README file.

[](#the-zshell-is-now-yours)The Z-Shell Is Now Yours
----------------------------------------------------

You should now have a clean and lean Zsh configuration, and you should understand enough of it to customize it.

What did we learn with this article?

*   Zsh reads its configuration files in a precise order.
*   You can set (or unset) many Zsh options depending on your needs.
*   The completion system of Zsh is one of its best feature.
*   Zsh directory stack allow you to jump easily in directories you've already visited.
*   If you like Vim, Zsh allows you to use keystrokes from the Vim world. You can even edit your commands directly in Vim.
*   External plugins can be found on The Internet, to improve even further the Zsh experience.
*   You should go crazy on shell scripting, to automate your workflow as much as you can.
*   External programs can enhance your experience with the shell, like `tmux` or `fzf`.

All your colleagues will be jealous. Guaranteed.

[](#related-sources)Related Sources
-----------------------------------

*   [Zsh official documentation](http://zsh.sourceforge.net/)
*   [Awesome Zsh plugins](https://project-awesome.org/unixorn/awesome-zsh-plugins)
*   [Profiling Zsh](https://htr3n.github.io/2018/07/faster-zsh/)