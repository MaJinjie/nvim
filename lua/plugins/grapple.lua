---@type LazySpec
return {
  "cbochs/grapple.nvim",
  cmd = "Grapple",
  lazy = false,
  opts = { scope = "git" },
  specs = {
    "AstroNvim/astrocore",
    opts = function()
      local nmap = require("utils").keymap.set.n

      nmap {
        ["<Bslash>a"] = { "<Cmd>Grapple tag<CR>", desc = "Add file" },
        ["<Bslash>A"] = { "<Cmd>Grapple untag<CR>", desc = "Remove file" },
        ["<Bslash>w"] = { "<Cmd>Grapple toggle_tags<CR>", desc = "Toggle a file" },
        ["<Bslash>W"] = { "<Cmd>Telescope grapple tags<CR>", desc = "Toggle a file using telescope" },
        ["]G"] = { "<Cmd>Grapple cycle forward<CR>", desc = "Select next tag" },
        ["[G"] = { "<Cmd>Grapple cycle backward<CR>", desc = "Select previous tag" },
      }
    end,
  },
}
