-- Register compound / specialized filetypes used by nvim-lspconfig + LazyVim.
-- Neovim 0.12+ :checkhealth vim.lsp warns for any LSP `filetypes` entry that is
-- not in vim.filetype's known set ("Unknown filetype …").
--
-- Also wires real filename/extension detection so servers like yamlls and
-- docker_compose_language_service attach to the right buffers.

vim.filetype.add({
  extension = {
    mdx = "markdown.mdx",
    -- lemminx lists "xsl"; stock Neovim only knows "xslt"
    xsl = "xsl",
  },

  filename = {
    ["docker-compose.yml"] = "yaml.docker-compose",
    ["docker-compose.yaml"] = "yaml.docker-compose",
    ["compose.yml"] = "yaml.docker-compose",
    ["compose.yaml"] = "yaml.docker-compose",
    [".gitlab-ci.yml"] = "yaml.gitlab",
    [".gitlab-ci.yaml"] = "yaml.gitlab",
  },

  pattern = {
    -- compose overrides: docker-compose.prod.yml, compose.override.yaml, …
    [".*/docker%-compose[^/]*%.ya?ml"] = "yaml.docker-compose",
    [".*/compose%.[^/]*%.ya?ml"] = "yaml.docker-compose",

    -- GitLab CI includes
    [".*/%.gitlab%-ci[^/]*%.ya?ml"] = "yaml.gitlab",

    -- Helm values (yamlls language id)
    [".*/values%.ya?ml"] = "yaml.helm-values",
    [".*/values%..+%.ya?ml"] = "yaml.helm-values",
    [".*/charts/.+/templates/.*%.ya?ml"] = "yaml.helm-values",

    -- VS Code-style language IDs listed by LazyVim / clangd.
    -- Paths never match these markers; registration only makes them "known"
    -- for health checks and explicit :setfiletype use. Real .jsx/.tsx stay
    -- javascriptreact / typescriptreact.
    ["\\v\\@lsp/javascript%.jsx"] = "javascript.jsx",
    ["\\v\\@lsp/typescript%.tsx"] = "typescript.tsx",
    ["\\v\\@lsp/c%.doxygen"] = "c.doxygen",
    ["\\v\\@lsp/cpp%.doxygen"] = "cpp.doxygen",
  },
})

vim.treesitter.language.register("json", "jsonc")
