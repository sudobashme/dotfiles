---
tags: [dotfiles, lamina, neovim, zsh]
title: Dotfiles
aliases: [Dotfiles]
date created: Friday, February 28th 2025, 11:25:46 pm
date modified: Sunday, June 21st 2026, 9:37:19 pm
---
# Dotfiles

These are my dotfiles that I use on my mac mini m4 pro. So first let me state that this repo will always be a work in progress and its direction will likely vary based on whatever stage of my own personal development I am in at the moment.

> It's about the journey, and not the destination

that's my take on it anyway. If it works for you today it might not tomorrow and I apologize for that. But feel free to fork and make it your own.

- [xcode developer tools](https://developer.apple.com/xcode/resources/)
- [homebrew](https://brew.sh/)
- [this repo](https://github.com/sudobashme/dotfiles)
- [powerline fonts](https://github.com/powerline/fonts?tab=readme-ov-file)
- [starship](https://starship.rs/) (prompt)
- [lamina](./bin/lamina) (deploy, update, and health CLI)
- [my neovim configuration](https://github.com/sudobashme/dotfiles/tree/main/configs/nvim)

Deployment is handled by lamina deploy. Symlinks and zsh plugins are declared in [lamina/plugins.toml](./lamina/plugins.toml).

And then all the applications I install via homebrew of which a list can be found [here](./configs/homebrew/homebrew_bundle_file)

_*New:*_ I am actually working on new documentation. [see here](./docs/personal-os-layer/README.md)

---

## Install

```
lamina deploy 
```

---

## Reasoning

---

I think zinit is cool as shit. But there seems to be a couple warring factions around it

[https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/](https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/)
and then 
[https://wiki.zshell.dev/](https://wiki.zshell.dev/)

Somehow through all that I stumbled on this:
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

Some plugins I really like (see [lamina/plugins.toml](./lamina/plugins.toml) for the canonical list):

- [zsh navigation tools](https://github.com/z-shell/zsh-navigation-tools)
- [zsh-abbr](https://github.com/olets/zsh-abbr)
- [fzf-tab](https://github.com/Aloxaf/fzf-tab)

Zoxide is integrated directly via `evalcache zoxide init zsh` in `zsh/.zshrc` (not the z-shell zsh-zoxide plugin wrapper).

Some plugins I hope to try in the future:

- [zsh editing workbench](https://github.com/z-shell/zsh-editing-workbench)
- [zsh cmd architecture](https://github.com/z-shell/zsh-cmd-architect)

---
