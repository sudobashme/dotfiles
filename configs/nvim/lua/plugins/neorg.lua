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
  end,
}