return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    animate = { enabled = true },
    bigfile = { enabled = true },
    dashboard = {
      preset = {
        pick = function(cmd, opts)
          return LazyVim.pick(cmd, opts)()
        end,
        header = [[
        ██╗      █████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗          Z
        ██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██║   ██║██║████╗ ████║      Z    
        ██║     ███████║  ███╔╝  ╚████╔╝ ██║   ██║██║██╔████╔██║   z       
        ██║     ██╔══██║ ███╔╝    ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ z         
        ███████╗██║  ██║███████╗   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║           
        ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝           
 ]],
       -- stylua: ignore
       ---@type snacks.dashboard.Item[]
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
          { icon = "󰒲  ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "h", desc = "Lazy Health", action = ":LazyHealth" },
          { icon = "󱊈  ", key = "m", desc = "Mason", action = ":Mason"},
          { icon = " ", key = "t", desc = "Treesitter Update", action = ":TSUpdate" },
          { icon = " ", key = "D", desc = "Generate Dotfyle Config", action = ":DotfyleGenerate" },
          { icon = " ", key = "d", desc = "Open Current Dotfyle Config", action = ":DotfyleOpen" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    },
    explorer = { enabled = true },
    image = {
      enabled = true,
      -- Let render-markdown.nvim handle LaTeX; snacks image math conflicts with it.
      math = { enabled = false },
    },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    picker = {
      items = {},
      main = { current = true },
      layout = { preset = "select" },
      finder = "meta_preview",
      format = "text",
      ui_select = true,
    },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    toggle = { map = LazyVim.safe_keymap_set },
    words = { enabled = true },
  },
  config = function(_, opts)
    require("snacks").setup(opts)
    if opts.input and opts.input.enabled then
      vim.ui.input = Snacks.input.input
    end
    if opts.picker and opts.picker.ui_select then
      vim.ui.select = Snacks.picker.select
    end
    if opts.notifier and opts.notifier.enabled then
      vim.notify = Snacks.notifier
    end
  end,
}
