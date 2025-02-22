# install powerline fonts
---

```
ls ${HOME}/Library/Fonts | grep -q powerline
if [[ $? == 1 ]]; then
    mkdir -p ${XDG_CACHE_HOME}/fonts;
    git clone https://github.com/powerline/fonts.git --depth=1 ${XDG_CACHE_HOME}/fonts;
    cd ${XDG_CACHE_HOME}/fonts;
    ./install.sh;
    cd ${HOME};
    rm -rf ${XDG_CACHE_HOME}/fonts
fi
```

---
