-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local o = vim.opt
local g = vim.g
local u = vim.ui
vim.loader.enable()
u.select = "Snacks.picker"
o.statuscolumn = "%!v:lua.require'snacks.statuscolumn'.get()"
g.mapleader = " "
g.maplocalleader = "\\"
g.lazyvim_picker = "Snacks"
g.autoformat = true
g.editorconfig = true
g.root_spec = {
  "lsp",
  { ".git", "lua", "package.json", "Makefile", "go.mod", "cargo.toml", "pyproject.toml", "src", ".conf" },
  "cwd",
}

o.showcmd = false
o.laststatus = 0
o.cmdheight = 0
o.spell = true
o.spelllang = { "en" }
o.backspace = { "start", "eol", "indent" }
o.breakindent = true
o.smoothscroll = true
o.conceallevel = 2
o.clipboard = "unnamedplus"
o.nu = true
o.relativenumber = true
g.rbenv_host_prog = "${HOME}/.rbenv/versions/3.3.6/bin/neovim-ruby-host"
g.python3_host_prog = "${HOME}/.pyenv/versions/neovim/bin/python"
g.lazyvim_python_lsp = "pyright"
g.lazyvim_python_ruff = "ruff"
g.loaded_perl_provider = 0
g.lazyvim_prettier_needs_config = false
g.lazyvim_rust_diagnostics = "rust-analyzer"
g.lazyvim_blink_main = true
