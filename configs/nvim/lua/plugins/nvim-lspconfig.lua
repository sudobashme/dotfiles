return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      bashls = {
        settings = {
          filetypes = { "sh", "zsh", "typescript", "typescriptreact", "typescript.tsx" },
        },
      },
      biome = {},
      html = {},
      jsonls = {
        before_init = function(_, config)
          config.settings = config.settings or {}
          config.settings.json = config.settings.json or {}
          config.settings.json.schemas = config.settings.json.schemas or {}

          -- vim.lsp.config does not run neoconf's lspconfig on_setup hooks.
          if package.loaded["neoconf"] then
            require("neoconf.plugins.jsonls").on_new_config(config, vim.fn.getcwd())
          end

          local ok, schemastore = pcall(require, "schemastore")
          if ok then
            vim.list_extend(config.settings.json.schemas, schemastore.json.schemas())
          end
        end,
      },
      lua_ls = {
        before_init = function(_, config)
          if package.loaded["neoconf"] then
            require("neoconf.plugins.lua_ls").on_new_config(config, vim.fn.stdpath("config"))
          end
        end,
      },
      lemminx = {},
      yamlls = {},
    },
  },
}

