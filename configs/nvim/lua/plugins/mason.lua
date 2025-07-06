return {
  {
    "mason-org/mason.nvim", version = "v2.0.0",
    opts = {
      ensure_installed = {
        "lua-language-server",
        -- Add other LSP servers you need
      },
    },
  },
}