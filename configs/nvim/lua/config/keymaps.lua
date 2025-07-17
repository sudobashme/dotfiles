-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Remove conflicting <gc> mappings and reassign comment toggle
-- vim.keymap.del("n", "gc")
-- vim.keymap.del("n", "gcO")
-- vim.keymap.del("n", "gco")
-- vim.keymap.del("n", "gcc")
-- vim.keymap.del("n", "g")
-- vim.keymap.del("n", "gp")
-- vim.keymap.del("n", "g<C-A>")
-- vim.keymap.del("n", "g[")
-- vim.keymap.del("n", "g]")
-- vim.keymap.del("n", "g%")
-- vim.keymap.del("n", "g<C-X>")
-- vim.keymap.del("n", "gP")
-- vim.keymap.del("x", "a")
-- vim.keymap.del("x", "i")
-- vim.keymap.del("o", "a")
-- vim.keymap.del("o", "i")

-- vim.keymap.set(
--   "n",
--   "<leader>c",
--   "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>",
--   { desc = "Toggle comment" }
-- )
-- vim.keymap.set(
--   "x",
--   "<leader>c",
--   "<cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
--   { desc = "Toggle comment" }
-- )

-- vim.keymap.del("n", "g")
-- Retain LSP mappings with <leader>g prefix
-- vim.keymap.set("n", "<leader>gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", { desc = "Go to implementation" })
-- vim.keymap.set("n", "<leader>ga", "<cmd>lua vim.lsp.buf.code_action()<CR>", { desc = "Code action" })
-- vim.keymap.set("n", "<leader>gr", "<cmd>lua vim.lsp.buf.references()<CR>", { desc = "References" })
-- vim.keymap.set("n", "<leader>gn", "<cmd>lua vim.lsp.buf.rename()<CR>", { desc = "Rename" })
-- vim.keymap.set("n", "<leader>go", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", { desc = "Document symbols" })

-- Remove conflicting <a> and <i> in visual and operator-pending modes

-- vim.keymap.set("x", "an", "<cmd>lua require('textobjects').next_around()<CR>", { desc = "Around next" })
-- vim.keymap.set("x", "al", "<cmd>lua require('textobjects').last_around()<CR>", { desc = "Around last" })
-- vim.keymap.set("x", "ai", "<cmd>lua require('textobjects').indent_around()<CR>", { desc = "Around indent" })
-- vim.keymap.set("x", "in", "<cmd>lua require('textobjects').next_inside()<CR>", { desc = "Inside next" })
-- vim.keymap.set("x", "il", "<cmd>lua require('textobjects').last_inside()<CR>", { desc = "Inside last" })
-- vim.keymap.set("x", "ii", "<cmd>lua require('textobjects').indent_inside()<CR>", { desc = "Inside indent" })
-- vim.keymap.set("o", "an", "<cmd>lua require('textobjects').next_around()<CR>", { desc = "Around next" })
-- vim.keymap.set("o", "al", "<cmd>lua require('textobjects').last_around()<CR>", { desc = "Around last" })
-- vim.keymap.set("o", "ai", "<cmd>lua require('textobjects').indent_around()<CR>", { desc = "Around indent" })
-- vim.keymap.set("o", "in", "<cmd>lua require('textobjects').next_inside()<CR>", { desc = "Inside next" })
-- vim.keymap.set("o", "il", "<cmd>lua require('textobjects').last_inside()<CR>", { desc = "Inside last" })
-- vim.keymap.set("o", "ii", "<cmd>lua require('textobjects').indent_inside()<CR>", { desc = "Inside indent" })

-- Remove or remap <gO>
-- vim.keymap.del("n", "l")
-- vim.keymap.set("n", "<leader>lo", vim.lsp.buf.document_symbol, { desc = "LSP Document Symbols" })
-- vim.keymap.set("n", "<leader>ll", "<cmd>Lazy<cr>", { desc = "Lazy" })
-- vim.keymap.del("n", "gO") -- Optional: Remove original mapping

-- vim.keymap.set("n", "<leader>cc", "<Plug>(comment_toggle_linewise_current)", { desc = "Toggle Comment Line" })
-- vim.keymap.set("n", "<leader>cb", "<Plug>(comment_toggle_blockwise_current)", { desc = "Toggle Comment Block" })
-- vim.keymap.set("n", "<leader>fn", ":Nerdy<CR>", { desc = "Browse nerd icons" })
-- vim.keymap.set("n", "<leader>fr", ":NerdyRecents<CR>", { desc = "Browse recent nerd icons" })

local wk = require("which-key")
-- For gc
vim.keymap.del("n", "gc")
wk.add({ "gc", group = "Toggle comment" })
