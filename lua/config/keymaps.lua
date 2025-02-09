local map = vim.keymap.set

-- stylua: ignore start

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<cmd>TmuxNavigate h follow_zoomed=true<cr>", { desc = "TmuxNavigate to Left Window" })
map("n", "<C-j>", "<cmd>TmuxNavigate j follow_zoomed=true<cr>", { desc = "TmuxNavigate to Down Window" })
map("n", "<C-k>", "<cmd>TmuxNavigate k follow_zoomed=true<cr>", { desc = "TmuxNavigate to Up Window" })
map("n", "<C-l>", "<cmd>TmuxNavigate l follow_zoomed=true<cr>", { desc = "TmuxNavigate to Right Window" })
map({ "n", "i", "x" }, "<C-\\>", "<cmd>TmuxNavigate p follow_zoomed=true<cr>", { desc = "TmuxNavigate to Last Window" })

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
-- map({ "i", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

-- Clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and Clear hlsearch" })

-- better quit
map("n", "q", "<cmd>quit<cr>", { desc = "Quit/Close" })
map("n", "Q", "q", { desc = "Start macro" })

-- diagnostic
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
map("n", "[e", function() vim.diagnostic.goto_prev({ severity = "ERROR" }) end, { desc = "Prev Error Diagnostic" })
map("n", "]e", function() vim.diagnostic.goto_next({ severity = "ERROR" }) end, { desc = "Next Error Diagnostic" })
map("n", "[w", function() vim.diagnostic.goto_prev({ severity = "WARN" }) end, { desc = "Prev Warn Diagnostic" })
map("n", "]w", function() vim.diagnostic.goto_next({ severity = "WARN" }) end, { desc = "Next Warn Diagnostic" })

-- windows
map("n", "_", "<cmd>split<cr>", { desc = "Split Window Below" })
map("n", "|", "<cmd>vsplit<cr>", { desc = "Split Window Right" })

-- buffers
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader><leader>", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>bd", function() require("util.keymap").buf_delete() end, { desc = "Delete Buffer" })
map("n", "<leader>bD", "<cmd>BufferPickDelete<cr>", { desc = "PickDelete Buffer" })
map("n", "<leader>ba", function()
  local tab_buflist = vim.fn.tabpagebuflist()
  require("util.keymap").buf_delete(function(buf) return not vim.list_contains(tab_buflist, buf) end)
end, { desc = "Delete all Buffer" })
map("n", "<leader>bA", function() require("util.keymap").buf_delete(function() return true end) end, { desc = "Delete All Buffer" })
map("n", "<leader>bb", "<cmd>BufferPick<cr>", {desc = "Pick buffer"})

-- tabs
map("n", "<leader><Tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><Tab>D", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
map("n", "<leader><Tab>n", "<cmd>tabnew %<cr>", { desc = "New Tab" })
map("n", "<leader><Tab><Tab>", function () require("util.keymap").tab_switch() end, { desc = "Switch to Other Tabpage" })
map("n", "]<Tab>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "[<Tab>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- quickfix
map("n", "<leader>q", function() require("util.keymap").quickfix_toggle(true) end, { desc = "Toggle Quickfix" })
map("n", "<leader>Q", function() require("util.keymap").quickfix_toggle(false) end, { desc = "Toggle Quickfix" })
map("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })

-- extra

-- stylua: ignore end
