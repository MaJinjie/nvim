---@type MappingsTable
local M = {}

-- disable
vim.inspect(vim.foldlevel)
vim.inspect(vim.foldcolumn)
vim.inspect(vim.foldlevelstart)

M.disabled = {
  n = {
    ["<leader>n"] = "",
    ["<leader>rn"] = "",
    ["<leader>b"] = "",
    ["<leader>ch"] = "",
    ["<Tab>"] = "",
  },
}

-- change

-- add

M.general = {
  n = {
    ["<leader>rn"] = { "<cmd> set nu! rnu! <CR>", "Toggle line number" },

    ["<leader>fm"] = {
      "<cmd> Format <CR>",
      "formatting",
    },
  },
  v = {
    [">"] = { ">gv", "indent" },
  },
}

M.tabbufline = {
  plugin = true,
  n = {
    ["<Tab>"] = "",
    -- cycle through buffers
    ["]b"] = {
      function()
        require("nvchad.tabufline").tabuflineNext()
      end,
      "Goto next buffer",
    },

    ["<[b]>"] = {
      function()
        require("nvchad.tabufline").tabuflinePrev()
      end,
      "Goto prev buffer",
    },
  },
}
return M
