return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      -- REQUIRED
      harpoon:setup {
        cmd = {
          add = function(possible_value)
            -- get the current line idx
            local idx = vim.fn.line(".")

            -- read the current line
            local cmd = vim.api.nvim_buf_get_lines(0, idx - 1, idx, false)[1]
            if cmd == nil then
              return nil
            end

            return {
              value = cmd,
              context = { "... any data you want ..." },
            }
          end,
          select = function(list_item, list, option)
            -- WOAH, IS THIS HTMX LEVEL XSS ATTACK??
            vim.cmd(list_item.value)
          end,
        }
      }
      vim.keymap.set("n", "<leader>a", function() harpoon:list():append() end)
      vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

      vim.keymap.set("n", "1", function() harpoon:list():select(1) end)
      vim.keymap.set("n", "2", function() harpoon:list():select(2) end)
      vim.keymap.set("n", "3", function() harpoon:list():select(3) end)
      vim.keymap.set("n", "4", function() harpoon:list():select(4) end)

      -- Toggle previous & next buffers stored within Harpoon list
      vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
      vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)
    end
  }
}
