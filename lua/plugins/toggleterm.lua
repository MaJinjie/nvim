--[[
{
  __state = {
    mode = "?"
  },
  auto_scroll = true,
  close_on_exit = true,
  dir = "/home/majinjie/.config/nvim",
  direction = "vertical",
  float_opts = {
    border = "rounded",
    title_pos = "left",
    winblend = 0
  },
  hidden = false,
  id = 1,
  newline_chr = "\n",
  on_create = <function 1>,
  <metatable> = <1>{
    __add = <function 2>,
    __index = <table 1>,
    __make_output_handler = <function 3>,
    __restore_mode = <function 4>,
    __resurrect = <function 5>,
    __set_ft_options = <function 6>,
    __set_options = <function 7>,
    __set_win_options = <function 8>,
    __spawn = <function 9>,
    _display_name = <function 10>,
    change_dir = <function 11>,
    change_direction = <function 12>,
    clear = <function 13>,
    close = <function 14>,
    focus = <function 15>,
    is_float = <function 16>,
    is_focused = <function 17>,
    is_open = <function 18>,
    is_split = <function 19>,
    is_tab = <function 20>,
    new = <function 21>,
    open = <function 22>,
    persist_mode = <function 23>,
    resize = <function 24>,
    scroll_bottom = <function 25>,
    send = <function 26>,
    set_mode = <function 27>,
    shutdown = <function 28>,
    spawn = <function 29>,
    toggle = <function 30>
  }
}
--]]
---@type LazySpec
return {
  "akinsho/toggleterm.nvim",
  opts = {
    size = function(term)
      if term.direction == "horizontal" then
        return vim.o.lines < 20 and vim.o.lines * 0.4 or 10
      elseif term.direction == "vertical" then
        return vim.o.columns < 100 and 30 or 40
      end
    end,
    direction = "horizontal",
  },
  specs = {
    "AstroNvim/astrocore",
    opts = function()
      local map = require("utils").keymap.set
      map.n = {
        ["<Leader>tf"] = { "<Cmd>ToggleTerm direction=float<CR>", desc = "ToggleTerm float" },
        ["<Leader>th"] = { "<Cmd>ToggleTerm direction=horizontal<CR>", desc = "ToggleTerm horizontal split" },
        ["<Leader>tv"] = { "<Cmd>ToggleTerm direction=vertical<CR>", desc = "ToggleTerm vertical split" },
      }
    end,
  },
}
