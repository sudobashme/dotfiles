-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Compound filetypes for LSP (yamlls, lemminx, clangd, LazyVim TS extras)
require("config.filetypes")

-- Drop empty Neovim 0.12 vim.pack shell so lazy.nvim doesn't WARN about it.
-- (vim.pack.get() mkdir's site/pack/core/opt even with zero plugins.)
do
  local pack = vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", "core")
  local opt = vim.fs.joinpath(pack, "opt")
  if vim.fn.isdirectory(opt) == 1 then
    local entries = vim.fn.readdir(opt)
    if not entries or #entries == 0 then
      vim.fn.delete(pack, "rf")
      local parent = vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack")
      if vim.fn.isdirectory(parent) == 1 then
        local pentries = vim.fn.readdir(parent)
        if not pentries or #pentries == 0 then
          vim.fn.delete(parent, "rf")
        end
      end
    end
  end
end

local o = vim.opt
local g = vim.g
local u = vim.ui
vim.loader.enable()
--u.select = "Snacks.picker"
o.statuscolumn = "%!v:lua.require'snacks.statuscolumn'.get()"
g.mapleader = " "
g.maplocalleader = "\\"
--g.lazyvim_picker = "fzf"
g.autoformat = true
g.editorconfig = true
g.root_spec = {
  "lsp",
  { ".git", "lua", "package.json", "Makefile", "go.mod", "cargo.toml", "pyproject.toml", "src", ".conf", ".zsh" },
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
o.termguicolors = true
g.lazyvim_python_lsp = "pyright"
g.lazyvim_python_ruff = "ruff"
g.loaded_perl_provider = 0
g.lazyvim_prettier_needs_config = true
g.lazyvim_rust_diagnostics = "rust-analyzer"
g.lazyvim_picker = "snacks"
-- Enable this option to avoid conflicts with Prettier.
