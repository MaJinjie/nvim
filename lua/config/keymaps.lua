local map = vim.keymap.set

-- stylua: ignore start

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- better indenting
map("v", "<", "<gv") map("v", ">", ">gv")

-- Add undo break-points
map("i", ",", ",<C-g>u") map("i", ".", ".<C-g>u") map("i", ";", ";<C-g>u")

-- Clear search, diff update and redraw, taken from runtime/lua/_editor.lua
map( "n", "<leader>ur", "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>", { desc = "Redraw / Clear hlsearch / Diff Update" })

-- save file
map({ "i", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

-- Clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and Clear hlsearch" })

-- better quit
map("n", "q", function () require("util.keymap").quit() end, { desc = "Quit/Close" })
map("n", "Q", "q", { desc = "Start macro" })

-- windows
map("n", "_", "<C-w>s", { desc = "Split Window Below", remap = true })
map("n", "|", "<C-w>v", { desc = "Split Window Right", remap = true })

-- buffers
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>bd", function() require("util.keymap").buf_delete() end, { desc = "Delete Buffer" })
map("n", "<leader>bD", function() require("util.keymap").buf_delete(function(buf) return buf ~= vim.api.nvim_get_current_buf() end) end, { desc = "Delete Other Buffer" })
map("n", "<leader>ba", function() require("util.keymap").buf_delete(function(buf) return not vim.list_contains(vim.fn.tabpagebuflist(), buf) end) end, { desc = "Delete all Buffer" })
map("n", "<leader>bA", function() require("util.keymap").buf_delete(function() return true end) end, { desc = "Delete All Buffer" })

-- tabs
map("n", "<leader><Tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><Tab>D", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
map("n", "<leader><Tab>n", "<cmd>tabnew %<cr>", { desc = "New Tab" })
map("n", "<leader><Tab><Tab>", function () require("util.keymap").tab_switch() end, { desc = "Switch to Other Tabpage" })
map("n", "]<Tab>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "[<Tab>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- stylua: ignore end
