return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "bluloco",
    },
  },
  {
    "uloco/bluloco.nvim",
    lazy = false,
    priority = 1000,
    dependencies = { "rktjmp/lush.nvim" },
    config = function()
      require("bluloco").setup({
        style = "auto",
      })
    end,
  },
  -- LazyVim ships catppuccin as a default colorscheme plugin. Its
  -- auto_integrations (default true) calls vim.pack.get(), and Neovim 0.12's
  -- vim.pack mkdir's ~/.local/share/nvim/site/pack/core/opt even when empty.
  -- lazy.nvim then health-warns about "existing packages". You use bluloco;
  -- keep catppuccin available but stop the vim.pack probe.
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      auto_integrations = false,
    },
  },
}
