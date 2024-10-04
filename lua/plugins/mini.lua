return {
   {
      "echasnovski/mini.pairs",
      init = function()
         local map_bs = function(lhs, rhs)
            vim.keymap.set({ "i", "c" }, lhs, rhs, { expr = true, replace_keycodes = false })
         end

         map_bs("<C-h>", "v:lua.MiniPairs.bs()")
         map_bs("<C-w>", 'v:lua.MiniPairs.bs("\23")')
         map_bs("<C-u>", 'v:lua.MiniPairs.bs("\21")')
      end,
      opts = {
         mappings = {
            ["<"] = { action = "open", pair = "<>", neigh_pattern = "[^\\]." },
            [">"] = { action = "close", pair = "<>", neigh_pattern = "[^\\]." },
         },
      },
   },
}
