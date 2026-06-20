local home = vim.fn.expand("~")
local dropbox = vim.env.DROPBOX or (home .. "/Dropbox")

return {
  "obsidian-nvim/obsidian.nvim",
  version = "3.13.1", -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",

    -- see below for full list of optional dependencies 👇
  },
  opts = {
    workspaces = {
      {
        name = "Family Room",
        path = dropbox .. "/Family Room",
      },
      {
        name = "PluginDev",
        path = home .. "/Workspace/PluginDev",
      },
    },

    notes_subdir = "NewTestNotes",
    log_level = vim.log.levels.INFO,
    completion = {
      -- Set to false to disable completion.
      nvim_cmp = true,
      -- Trigger completion at 2 chars.
      min_chars = 2,
    },
    new_notes_location = "notes_subdir",
    -- Disable obsidian.nvim UI overlays; render-markdown.nvim handles markdown rendering.
    ui = { enable = false },

    -- see below for full list of options 👇
  },
}