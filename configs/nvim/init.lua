-- Provider paths must be absolute; Neovim does not expand ${HOME}.
local python_host = vim.fn.expand("~/.pyenv/versions/neovim/bin/python")
if vim.fn.executable(python_host) == 1 then
  vim.g.python3_host_prog = python_host
end

local ruby_host = vim.fn.expand("~/.rbenv/versions/3.3.6/bin/neovim-ruby-host")
if vim.fn.executable(ruby_host) == 1 then
  vim.g.ruby_host_prog = ruby_host
else
  vim.g.loaded_ruby_provider = 0
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
