return {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bashls = {
          settings = {
            filetypes = { "sh", "zsh" },
          },
        },
        html = {},
        jsonls = {},
        lemminx = {},
        yamlls = {},
      },
    },
  }