-- Provider paths must be absolute; Neovim does not expand ${HOME}.
vim.g.python3_host_prog = vim.fn.expand("~/.pyenv/versions/neovim/bin/python")
vim.g.rbenv_host_prog = vim.fn.expand("~/.rbenv/versions/3.3.6/bin/neovim-ruby-host")

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
