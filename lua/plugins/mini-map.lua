User.keymap.toggle["<leader>um"] = function()
  local mini_map = User.util.lazy_require("mini.map")

  return Snacks.toggle({
    name = "Mini Map",
    get = function()
      local tabnr = vim.api.nvim_get_current_tabpage()
      return mini_map.current.win_data[tabnr] ~= nil
    end,
    set = function(state)
      if state then
        mini_map.open()
      else
        mini_map.close()
      end
    end,
  })
end

return {
  "echasnovski/mini.map",
  event = "LazyFile",
  -- init = function()
  --   vim.api.nvim_create_autocmd({ "TabNewEntered", "VimEnter" }, {
  --     callback = function(args)
  --       if vim.g.minimap_disable then
  --         return
  --       end
  --       if args.event == "VimEnter" then
  --         User.util.on_lazyfile(function()
  --           MiniMap.open()
  --         end)
  --       else
  --         MiniMap.open()
  --       end
  --     end,
  --   })
  -- end,
  config = function()
    local MiniMap = require("mini.map")
    vim.api.nvim_set_hl(0, "MiniMapSymbolView", { link = "Conceal" })
    MiniMap.setup({
      symbols = {
        encode = MiniMap.gen_encode_symbols.dot("4x2"),
        scroll_line = "█",
        scroll_view = "░",
      },
      integrations = {
        MiniMap.gen_integration.builtin_search(),
        MiniMap.gen_integration.diagnostic({
          warn = "DiagnosticWarn",
          error = "DiagnosticError",
        }),
        MiniMap.gen_integration.gitsigns(),
      },
      window = {
        show_integration_count = false,
      },
    })
  end,
  -- stylua: ignore
  keys = {
    { "<leader>M", function () MiniMap.toggle_focus() end, desc = "Toggle Focus MiniMap" }
  }
,
}
