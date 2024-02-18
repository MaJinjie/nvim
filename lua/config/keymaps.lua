-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

---@field nowait? boolean If true, once the `lhs` is matched, the `rhs` will be executed
---@field expr? boolean Specify whether the `rhs` is an expression to be evaluated or not (default false)
---@field silent? boolean Specify whether `rhs` will be echoed on the command line
---@field unique? boolean Specify whether not to map if there exists a keymap with the same `lhs`
---@field script? boolean
---@field desc? string Description for what the mapping will do
---@field noremap? boolean Specify whether the `rhs` will execute user-defined keymaps if it matches some `lhs` or not
---@field replace_keycodes? boolean Only effective when `expr` is **true**, specify whether to replace keycodes in the resuling string
---@field callback function Lua function to call when the mapping is executed

---@mode
---|'"n"' # Normal Mode
---|'"x"' # Visual Mode Keymaps
---|'"s"' # Select Mode
---|'"v"' # Equivalent to "xs"
---|'"o"' # Operator-pending mode
---|'"i"' # Insert Mode
---|'"c"' # Command-Line Mode
---|'"l"' # Insert, Command-Line and Lang-Arg
---|'"t"' # Terminal Mode
---|'"!"' # Equivalent to Vim's `:map!`, which is equivalent to '"ic"'
---|'""'  # Equivalent to Vim's `:map`, which is equivalent to "nxso"

local add_map = vim.api.nvim_set_keymap

add_map("i", "<C-h>", "<Left>", { desc = "Move left", nowait = true, noremap = true, silent = true })
add_map("i", "<C-l>", "<Right>", { desc = "Move right", nowait = true, noremap = true, silent = true })
add_map("i", "<C-b>", "<Esc>^i", { desc = "beginning of line", nowait = true, noremap = true, silent = true })
add_map("i", "<C-e>", "<End>", { desc = "end of line", nowait = true, noremap = true, silent = true })
add_map("n", "<C-b>", "^", { desc = "beginning of line", nowait = true, noremap = true, silent = true })
add_map("n", "<C-e>", "$", { desc = "end of line", nowait = true, noremap = true, silent = true })

-- add_map("i", "<C-k>", "<Up>", { desc = "Move up", nowait = true, noremap = true, silent = true })
-- add_map("i", "<C-j>", "<Down>", { desc = "Move down", nowait = true, noremap = true, silent = true })
