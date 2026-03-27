return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      bashls = {
        settings = {
          filetypes = { "sh", "zsh", "typescript", "typescriptreact", "typescript.tsx" },
        },
      },
      html = {},
      jsonls = {},
      lemminx = {},
      yamlls = {},
    },
  },
}

