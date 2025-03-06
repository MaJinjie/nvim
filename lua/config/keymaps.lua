local map = vim.keymap.set
local uk = User.keymap

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
map("n", "<C-\\>", "<C-w>w", { desc = "Go to Last Window", remap = true })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- windows
map("n", "<leader>_", "<C-w>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-w>v", { desc = "Split Window Right", remap = true })
map("n", "<leader>wd", "<C-w>c", { desc = "Delete Window", remap = true })

-- arglist
map("n", "[g", "<cmd>lua vim.cmd(vim.v.count1 .. 'prev')<cr>", { desc = "Prev File" })
map("n", "]g", "<cmd>lua vim.cmd(vim.v.count1 .. 'next')<cr>", { desc = "Next File" })
map("n", "[G", "<cmd>first<cr>", { desc = "First Buffer" })
map("n", "]G", "<cmd>last<cr>", { desc = "Last Buffer" })

-- quickfix list
map("n", "[q", "<cmd>cprev<cr>", { desc = "Previous Quickfix" })
map("n", "]q", "<cmd>cnext<cr>", { desc = "Next Quickfix" })
map("n", "[Q", "<cmd>cfirst<cr>", { desc = "First Quickfix" })
map("n", "]Q", "<cmd>clast<cr>", { desc = "Last Quickfix" })
map("n", "[<C-q>", "<cmd>cpfile<cr>", { desc = "Quickfix in the Previous File" })
map("n", "]<C-q>", "<cmd>cnfile<cr>", { desc = "Quickfix in the Next File" })

-- location list
map("n", "[l", "<cmd>lprev<cr>", { desc = "Previous Location" })
map("n", "]l", "<cmd>lnext<cr>", { desc = "Next Location" })
map("n", "[L", "<cmd>lfirst<cr>", { desc = "First Location" })
map("n", "]L", "<cmd>llast<cr>", { desc = "Last Location" })
map("n", "[<C-l>", "<cmd>lpfile<cr>", { desc = "Location in the Previous File" })
map("n", "]<C-l>", "<cmd>lnfile<cr>", { desc = "Location in the Next File" })

-- buffers
map("n", "[b", "<cmd>execute 'bprev' . v:count1<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>execute 'bnext' . v:count1<cr>", { desc = "Next Buffer" })
map("n", "[B", "<cmd>bfirst<cr>", { desc = "First Buffer" })
map("n", "]B", "<cmd>blast<cr>", { desc = "Last Buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>bd", uk.bd, { desc = "Delete Buffer" })
map("n", "<leader>bo", uk.bda_butvis, { desc = "Delete Other Buffers Except the visual windows" })
map("n", "<leader>bO", uk.bda_butcur, { desc = "Delete Other Buffers" })

-- tabs
map("n", "]<Tab>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "[<Tab>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
map("n", "[<S-Tab>", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "]<S-Tab>", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><Tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><Tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
map("n", "<leader><tab><tab>", uk.tswitch, { desc = "Switch Tabpage" })

-- diagnostic
-- stylua: ignore start
map("n", "<leader>cd", function() vim.diagnostic.open_float() end, { desc = "Line Diagnostics" })
map("n", "]d", function() vim.diagnostic.goto_next() end, { desc = "Next Diagnostic" })
map("n", "[d", function() vim.diagnostic.goto_prev() end, { desc = "Prev Diagnostic" })
map("n", "]e", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end, { desc = "Next Error" })
map("n", "[e", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, { desc = "Prev Error" })
map("n", "]w", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN }) end, { desc = "Next Warning" })
map("n", "[w", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN }) end, { desc = "Prev Warning" })
-- stylua: ignore end

-- Paste last yank
map({ "n", "v" }, "<C-p>", '"0p', { desc = "Past last yank", silent = true })

-- Clear search on escape
map({ "n" }, "<esc>", "<Cmd>noh<CR><Esc>", { desc = "Escape and Clear hlsearch" })
-- Clear search, diff update and redraw
map(
  "n",
  "<leader>ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / Clear hlsearch / Diff Update" }
)

-- toggle
Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
Snacks.toggle
  .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" })
  :map("<leader>uc")
Snacks.toggle
  .option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" })
  :map("<leader>ut")
Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>uB")
Snacks.toggle.line_number():map("<leader>ul")
Snacks.toggle.zen():map("<leader>uz")
Snacks.toggle.zoom():map("<leader>wm"):map("<leader>uZ")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.dim():map("<leader>uD")
Snacks.toggle.treesitter():map("<leader>uT")
Snacks.toggle.animate():map("<leader>ua")
Snacks.toggle.indent():map("<leader>ug")
Snacks.toggle.scroll():map("<leader>uS")
Snacks.toggle.profiler():map("<leader>dpp")
Snacks.toggle.profiler_highlights():map("<leader>dph")
Snacks.toggle.inlay_hints():map("<leader>uh")

for key, toggle in pairs(uk.toggle) do
  toggle():map(key)
end

-- neovide
if vim.g.neovide then
  map("n", "<C-=>", function()
    local neovide_scale_factor = vim.g.neovide_scale_factor + vim.g.neovide_increment_scale_factor * vim.v.count1
    if neovide_scale_factor > vim.g.neovide_max_scale_factor then
      Snacks.notify.warn(
        "neovide_scale_factor has reached its maximum value " .. vim.g.neovide_max_scale_factor,
        { title = "Neovide" }
      )
    end
    vim.g.neovide_scale_factor = math.min(neovide_scale_factor, vim.g.neovide_max_scale_factor)
  end, {
    desc = "Increase Neovide scale factor",
  })
  map("n", "<C-->", function()
    local neovide_scale_factor = vim.g.neovide_scale_factor - vim.g.neovide_increment_scale_factor * vim.v.count1
    if neovide_scale_factor < vim.g.neovide_min_scale_factor then
      Snacks.notify.warn(
        "neovide_scale_factor has reached its minimum value " .. vim.g.neovide_min_scale_factor,
        { title = "Neovide" }
      )
    end
    vim.g.neovide_scale_factor = math.max(neovide_scale_factor, vim.g.neovide_min_scale_factor)
  end, {
    desc = "Decrease Neovide scale factor",
  })
  map("n", "<C-0>", function()
    vim.g.neovide_scale_factor = vim.g.neovide_initial_scale_factor
  end, {
    desc = "Reset Neovide scale factor to default",
  })
end
