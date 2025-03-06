User.keymap.toggle["<leader>uC"] = function()
  local tsc = User.util.lazy_require("treesitter-context")

  return Snacks.toggle({
    name = "Treesitter Context",
    get = function()
      return tsc.enabled()
    end,
    set = function(state)
      if state then
        tsc.enable()
      else
        tsc.disable()
      end
    end,
  })
end

-- Show context of the current function
return {
  "nvim-treesitter/nvim-treesitter-context",
  event = "LazyFile",
  -- stylua: ignore
  keys = {
    { "<leader>ct", function() require("treesitter-context").go_to_context(vim.v.count1) end, mode = { "n", "v" }, desc = "Goto Context" },
    { "<leader>cT", function() require("treesitter-context").go_to_context(math.huge) end, mode = { "n", "v" }, desc = "Goto Context Top" },
  },
  opts = { mode = "cursor", max_lines = 3 },
}
