-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Neovim 0.12 `vim.pack.get()` creates an empty site/pack/core/opt tree even when
-- you don't use vim.pack. lazy.nvim then health-warns about "existing packages".
-- Drop that empty shell if nothing was actually installed there.
local function cleanup_empty_vim_pack()
  local pack = vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", "core")
  local opt = vim.fs.joinpath(pack, "opt")
  if vim.fn.isdirectory(opt) ~= 1 then
    return
  end
  local entries = vim.fn.readdir(opt)
  if entries and #entries > 0 then
    return
  end
  vim.fn.delete(pack, "rf")
  local parent = vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack")
  if vim.fn.isdirectory(parent) == 1 then
    local pentries = vim.fn.readdir(parent)
    if not pentries or #pentries == 0 then
      vim.fn.delete(parent, "rf")
    end
  end
end
cleanup_empty_vim_pack()
vim.api.nvim_create_autocmd("User", {
  pattern = { "LazyDone", "LazyVimStarted" },
  group = vim.api.nvim_create_augroup("cleanup_empty_vim_pack", { clear = true }),
  callback = cleanup_empty_vim_pack,
})
