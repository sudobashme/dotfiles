return {
  "stevearc/conform.nvim",
  optional = true,
  ---@param opts conform.setupOpts
  opts = function(_, opts)
    local with_biome = { "biome-check", "prettierd" }
    local biome_fts = {
      "astro",
      "css",
      "graphql",
      "javascript",
      "javascriptreact",
      "json",
      "jsonc",
      "scss",
      "svelte",
      "typescript",
      "typescriptreact",
      "vue",
    }

    opts.formatters_by_ft = opts.formatters_by_ft or {}
    for _, ft in ipairs(biome_fts) do
      opts.formatters_by_ft[ft] = with_biome
    end

    opts.formatters_by_ft.less = { "prettierd" }
    opts.formatters_by_ft.html = { "prettierd" }
    opts.formatters_by_ft.yaml = { "prettierd" }
    opts.formatters_by_ft.markdown = { "prettierd" }
    opts.formatters_by_ft["markdown.mdx"] = { "prettierd" }
    opts.formatters_by_ft.handlebars = { "prettierd" }
    opts.formatters_by_ft.conf = { "prettierd" }
    opts.formatters_by_ft.python = { "black" }
    opts.formatters_by_ft.sh = { "shfmt" }
    opts.formatters_by_ft.bash = { "shfmt" }
    opts.formatters_by_ft.zsh = { "shfmt" }

    opts.formatters = opts.formatters or {}
    opts.formatters["biome-check"] = vim.tbl_extend("force", opts.formatters["biome-check"] or {}, {
      require_cwd = true,
    })
  end,
}