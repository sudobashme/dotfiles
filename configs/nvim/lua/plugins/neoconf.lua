return {
  "folke/neoconf.nvim",
  cmd = "Neoconf",
  priority = 11000, -- before lspconfig / vim.lsp.config
  opts = {
    plugins = {
      lspconfig = { enabled = true },
      jsonls = {
        enabled = true,
        -- neoconf's has_lspconfig() is stale on Nvim 0.11+; register all schemas.
        configured_servers_only = false,
      },
      lua_ls = { enabled = true },
    },
  },
  config = true,
}