# dotfiles

These are my dotfiles that I use on my company provided macbook pro. So first let me state that this repo will always be a work in progress and its direction will likely vary based on whatever stage of my own personal development I am in at the moment.

> It's about the journey, and not the destination

that's my take on it anyway. If it works for you today it might not tomorrow and I apologize for that. But feel to fork and make it your own.

The accompanying ~~bootstrap script~~ will attempt to install the following:

- [xcode developer tools](https://developer.apple.com/xcode/resources/)
- [homebrew](https://brew.sh/)
- [~~ohmyzsh~~](https://ohmyz.sh/)
- [this repo](https://github.com/sudobashme/dotfiles)
- [powerline fonts](https://github.com/powerline/fonts?tab=readme-ov-file)
- [starship](https://starship.rs/) (prompt)
- [lamina](./bin/lamina) (deploy, update, and health CLI)
- [my neovim configuration](https://github.com/sudobashme/dotfiles/tree/main/configs/nvim)

Bootstrap is handled by [deploy.zsh](./deploy.zsh) and [lamina](./bin/lamina). Symlinks and zsh plugins are declared in [lamina/plugins.toml](./lamina/plugins.toml).

And then all the applications I install via homebrew of which a list can be found [here](./configs/homebrew/homebrew_bundle_file)

## Install

---

is a work in progress [deploy.zsh](./deploy.zsh)

I believe this works at this point but I have not had the oportunity to test on a completely new machine yet. To install without any prompts all you have to do is run `./deploy.zsh --install`. That said, I would not use this yet because I have not debugged each piece yet. But it is there... just saying your mileage may vary.

---

## Reasoning

---

so I used ohmyzsh for soooo long and while it is good I saw all this other stuff that made me curious.

This one was interesting but still bothersome in some ways:
[https://wiki.zshell.dev/](https://wiki.zshell.dev/)

Which eventually lead me to the original implementation:
[https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/](https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/)

Which I honestly liked better and then that brought me to this:
[https://github.com/z0rc/dotfiles](https://github.com/z0rc/dotfiles)

Which I liked even better in most ways but still there were parts that bothered me. So this is my personal implementation largely influenced by the 3 repos above.

It makes use of very important zsh features that a lot of people don't even know about.

- [the zsh completion system](https://zsh.sourceforge.io/Doc/Release/Completion-System.html)

So this is everything completion related. If you see the commands autoload, compinit, compdump, compdef, zle, zstyle, etc in my configs and you want to understand what they do I would suggest you read the above document first.

- [zsh modules](https://zsh.sourceforge.io/Doc/Release/Zsh-Modules.html)

This is all the extra builtin stuff you can load from zsh. If you want to see what is already loaded simply type zmodload.

```
% zmodload
zsh/compctl
zsh/complete
zsh/complist
zsh/computil
zsh/curses
zsh/datetime
zsh/files
zsh/langinfo
zsh/main
zsh/mathfunc
zsh/net/socket
zsh/parameter
zsh/regex
zsh/stat
zsh/system
zsh/termcap
zsh/terminfo
zsh/zle
zsh/zleparameter
zsh/zutil
```

- [zsh startup files](https://zsh.sourceforge.io/Guide/zshguide02.html)

Definitely worth a read:

- [zle](https://zsh.sourceforge.io/Guide/zshguide04.html)
- [zsh substitution](https://zsh.sourceforge.io/Guide/zshguide05.html)
- [zsh completions old and new](https://zsh.sourceforge.io/Guide/zshguide06.html)
- [zsh lovers](https://gist.githubusercontent.com/jheidt/e8e7df15bc15d8b9faee/raw/cc7e59b121623b6f120c96294f91ed0aabb615f1/zsh-lovers)
- [zsh native scripting handbook](https://wiki.zshell.dev/community/zsh_handbook)
- [zsh plugin standard](https://wiki.zshell.dev/community/zsh_plugin_standard)
- [awesome zsh](https://github.com/unixorn/awesome-zsh-plugins)

---

## Plugins

---

Some plugins I really like (see [lamina/plugins.toml](./lamina/plugins.toml) for the canonical list):

- [zsh navigation tools](https://github.com/z-shell/zsh-navigation-tools)
- [zsh-abbr](https://github.com/olets/zsh-abbr)
- [fzf-tab](https://github.com/Aloxaf/fzf-tab)

Zoxide is integrated directly via `evalcache zoxide init zsh` in `zsh/.zshrc` (not the z-shell zsh-zoxide plugin wrapper).

---

Some plugins I hope to try in the future:

- [zsh editing workbench](https://github.com/z-shell/zsh-editing-workbench)
- [zsh cmd architecture](https://github.com/z-shell/zsh-cmd-architect)

---
