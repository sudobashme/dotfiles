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
            default_keybinds = false,
          },
        },
      },
    })

    -- Bind the Neorg actions you use without fighting global Vim/completion keys.
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("user_neorg_keymaps", { clear = true }),
      pattern = "norg",
      callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }
        vim.keymap.set(
          "n",
          "<LocalLeader>nn",
          "<Plug>(neorg.dirman.new-note)",
          vim.tbl_extend("force", opts, { desc = "[neorg] New Note" })
        )
        vim.keymap.set(
          "n",
          "<LocalLeader>no",
          "<cmd>Neorg toc<CR>",
          vim.tbl_extend("force", opts, { desc = "[neorg] Table of Contents" })
        )
        for key, plug in pairs({
          ta = "<Plug>(neorg.qol.todo-items.todo.task-ambiguous)",
          tc = "<Plug>(neorg.qol.todo-items.todo.task-cancelled)",
          td = "<Plug>(neorg.qol.todo-items.todo.task-done)",
          th = "<Plug>(neorg.qol.todo-items.todo.task-on-hold)",
          ti = "<Plug>(neorg.qol.todo-items.todo.task-important)",
          tp = "<Plug>(neorg.qol.todo-items.todo.task-pending)",
          tr = "<Plug>(neorg.qol.todo-items.todo.task-recurring)",
          tu = "<Plug>(neorg.qol.todo-items.todo.task-undone)",
        }) do
          vim.keymap.set("n", "<LocalLeader>" .. key, plug, vim.tbl_extend("force", opts, { desc = "[neorg] Task " .. key }))
        end
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
