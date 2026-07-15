return {
  "nvim-neorg/neorg",
  lazy = false,
  version = "*",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    -- Rockspec deps: must load before neorg configures treesitter parsers.
    { "nvim-neorg/tree-sitter-norg", lazy = false },
    { "nvim-neorg/tree-sitter-norg-meta", lazy = false },
  },
  config = function()
    require("neorg").setup({
      load = {
        ["core.defaults"] = {},
        ["core.keybinds"] = {
          config = {
            default_keybinds = true,
            preset = "neorg",
          },
        },
      },
    })

    -- gO (vim builtin symbol outline) and <C-Space> (blink.cmp) are taken globally.
    -- Bind Neorg actions to <LocalLeader> keys in .norg buffers instead.
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("user_neorg_keymaps", { clear = true }),
      pattern = "norg",
      callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }
        vim.keymap.set(
          "n",
          "<LocalLeader>no",
          "<cmd>Neorg toc<CR>",
          vim.tbl_extend("force", opts, { desc = "[neorg] Table of Contents" })
        )
        vim.keymap.set(
          "n",
          "<LocalLeader>ts",
          "<Plug>(neorg.qol.todo-items.todo.task-cycle)",
          vim.tbl_extend("force", opts, { desc = "[neorg] Cycle Task" })
        )
      end,
    })
  end,
}