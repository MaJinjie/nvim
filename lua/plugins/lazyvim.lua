local symbols = {
   rust = { "EnumMember", "Object", "TypeParameter", "Constant" },
}

local function get_filter_symbols(lang)
   local default = LazyVim.config.kind_filter.default
   if type(default) == "boolean" then
      default = {}
   end

   return symbols[lang] == nil and true or vim.list_extend(symbols[lang], default)
end

return {
   {
      "folke/persistence.nvim",
    -- stylua: ignore
    keys = {
      { "<leader>qs", function() require("persistence").select() end, desc = "Select Session" },
      { "<leader>qS", function() require("persistence").save() end, desc = "Save Session" },
      { "<leader>ql", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>qL", function() require("persistence").load({last = true}) end, desc = "Restore Last Session" },
    },
   },
   {
      "hedyhli/outline.nvim",
      opts = {
         outline_items = { show_symbol_lineno = true },
         preview_window = { open_hover_on_preview = true, live = true },
         keymaps = {
            show_help = "?",
            close = "q",
            peek_location = "o",
            goto_location = "O",
            goto_and_close = "<cr>",

            restore_location = "<C-g>",

            hover_symbol = "K",

            toggle_preview = "p",
            rename_symbol = "r",
            code_actions = "a",

            fold = "h",
            unfold = {},
            fold_all = "zM",
            unfold_all = "zR",
            fold_toggle = { "za", "<Tab>", "l" },
            fold_toggle_all = "zA",
            fold_reset = "R",

            down_and_jump = { "<C-j>", "<Up>" },
            up_and_jump = { "<C-k>", "Down" },
         },
         symbols = {
            filter = {
               rust = get_filter_symbols("rust"),
            },
         },
      },
   },
}
