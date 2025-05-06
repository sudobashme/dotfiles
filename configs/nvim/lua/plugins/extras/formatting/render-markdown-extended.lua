return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
  config = function()
    require("render-markdown").setup({
      latex = {
        enabled = true,
        converter = "python3 $HOME/.local/tools/tex2text/tex2text.py --unicxode",
        render_modes = { "n", "v", "i", "c" },
      },
    })
  end,
}