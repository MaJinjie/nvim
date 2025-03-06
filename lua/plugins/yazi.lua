return {
  "mikavilpas/yazi.nvim",
  lazy = true,
  opts = function()
    local keymaps = {
      open_file_in_vertical_split = "<localleader>v",
      open_file_in_horizontal_split = "<localleader>s",
      open_file_in_tab = "<localleader>t",
      grep_in_directory = "<localleader>g",
      replace_in_directory = "<localleader>r",
      send_to_quickfix_list = "<localleader>q",
      change_working_directory = "<localleader>c",
    }

    return {
      keymaps = vim.tbl_map(function(key)
        return Snacks.util.normkey(key)
      end, keymaps),
      integrations = {
        grep_in_directory = "snacks.picker",
        grep_in_selected_files = "snacks.picker",
      },
    } --[[@as YaziConfig|{} ]]
  end,
  -- stylua: ignore
  keys = {
    { "<leader>-", function() require("yazi").yazi() end, desc = "Open yazi at the current file" },
    { "<leader>y", function() require("yazi").toggle() end, desc = "Toggle Yazi" },
    { "<leader>Y", function() require("yazi").yazi(nil, User.root.get_by_count()) end, desc = "Open Yazi" },
    { "<leader>e", "<leader>y", remap = true, desc = "Toggle Yazi"},
    { "<leader>E", "<leader>Y", remap = true, desc = "Open Yazi"}
  },
}
