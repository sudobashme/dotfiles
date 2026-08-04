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
  config = function(_, opts)
    require("neoconf").setup(opts)

    -- neoconf's health check still asks lspconfig.util for legacy server names,
    -- but nvim-lspconfig now exposes configs through vim.lsp.config.
    local ok, util = pcall(require, "lspconfig.util")
    if ok and util.available_servers then
      local available_servers = util.available_servers
      util.available_servers = function(...)
        local servers = available_servers(...)
        for _, server in ipairs({ "jsonls", "lua_ls" }) do
          if vim.lsp.config[server] and not vim.tbl_contains(servers, server) then
            table.insert(servers, server)
          end
        end
        return servers
      end
    end
  end,
}
