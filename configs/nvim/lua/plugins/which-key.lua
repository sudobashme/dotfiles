return {
  "folke/which-key.nvim",
  opts = {
    ---@param mapping wk.Mapping
    filter = function(mapping)
      -- Hide <Plug> targets; keep the real key bindings (e.g. neorg's \nn).
      if mapping.lhs and mapping.lhs:find("<Plug>", 1, true) then
        return false
      end
      return true
    end,
    spec = {
      { "<LocalLeader>n", group = "neorg" },
      { "<LocalLeader>no", desc = "Table of Contents" },
      { "<LocalLeader>t", group = "todo" },
      { "<LocalLeader>ts", desc = "Cycle Task" },
    },
  },
}