return {
  "SR-MyStar/yazi.nvim",
  opts = {
    window = {
      size = {
        width = 0.9,
        height = 0.8,
      },
      command_args = {
        open_dir = vim.cmd.edit,
        open_file = vim.cmd.edit,
        cwd = nil,
        on_open = nil,
      },
      pos = "cc",         -- see `:h yazi-win-position`
      style = "minimal",  -- "" | "minimal"
      border = "single",  -- "none" | "single" | "double" | "rounded" | "solid" | "shadow"
      title = " Yazi ",
      title_pos = "center", -- "center" | "left" | "right"
    },
  }
}
