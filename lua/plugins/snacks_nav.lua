---@diagnostic disable: missing-fields
return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = { enabled = true },
      explorer = { enabled = true },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      ---@type snacks.picker.Config
      picker = {
        win = {
          input = {
            keys = {
              ["<c-n>"] = { "history_forward", mode = { "n", "i" } },
              ["<c-p>"] = { "history_back", mode = { "n", "i" } },
            },
          },
          list = {
            keys = {
              ["<c-n>"] = { "history_forward", mode = { "n", "i" } },
              ["<c-p>"] = { "history_back", mode = { "n", "i" } },
            },
          },
          preview = {
            wo = { cursorcolumn = false },
          },
        },
        icons = {
          lsp = User.config.icons.lsp,
        },
        previewers = {
          git = { native = true }, -- 使用delta
        },
        layouts = {
          vertical = {
            layout = {
              width = 0.8,
              min_width = 120,
              height = 0.8,
              border = "none",
              box = "vertical",
              { win = "preview", title = "{preview}", height = 0.4, border = "vpad" },
              {
                box = "vertical",
                border = "rounded",
                title = "{title} {live} {flags}",
                title_pos = "center",
                { win = "input", height = 1, border = "bottom" },
                { win = "list", border = "none" },
              },
            },
          },
          default = {
            layout = {
              box = "horizontal",
              width = 0.8,
              min_width = 120,
              height = 0.8,
              {
                box = "vertical",
                border = "rounded",
                title = "{title} {live} {flags}",
                { win = "input", height = 1, border = "bottom" },
                { win = "list", border = "none" },
              },
              { win = "preview", title = "{preview}", border = "vpad", width = 0.6 },
            },
          },
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>,", function() Snacks.picker.buffers({ layout = { preset = "vscode" }}) end, desc = "Buffers" },
      { "<leader>/", function() Snacks.picker.grep({ cwd = User.root({ preset = "root", opts = { cwd = true } }) }) end, desc = "Grep (Follow cwd)" },
      { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader><space>", function() Snacks.picker.files({ cwd = User.root({ preset = "root", opts = { cwd= true } }), layout = { preset = "vscode" } }) end, desc = "Find Files (Follow cwd)" },
      -- find
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>fB", function() Snacks.picker.buffers({ hidden = true, nofile = true }) end, desc = "Buffers (all)" },
      { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath "config" --[[@as string?]] }) end, desc = "Find Config File" },
      { "<leader>ff", function() Snacks.picker.files({ cwd = User.root({ preset = "root", opts = { buffer = true } }) }) end, desc = "Find Files (By count)" },
      { "<leader>fF", function() Snacks.picker.files({ cwd = User.root({ preset = "cwd" }) }) end, desc = "Find Files (Global cwd)" },
      { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },
      { "<leader>fR", function() Snacks.picker.recent({ filter = { cwd = true }}) end, desc = "Recent (cwd)" },
      { "<leader>fz", function() Snacks.picker.zoxide() end, desc = "Zoxide" },
      { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
      { "<leader>fP", function() Snacks.picker.projects({ title = "Plugins", projects = Snacks.picker.util.rtp(), recent = false }) end, desc = "Plugins" },
      { "<leader>fC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
      -- grep
      { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
      { "<leader>sB", function() Snacks.picker.grep_buffers({ layout = { preset = "vertical" }}) end, desc = "Grep Open Buffers" },
      { "<leader>sg", function() Snacks.picker.grep({ cwd = User.root({ preset = "root", opts = { buffer = true } }), layout = { preset = "vertical" } }) end, desc = "Grep (By count)" },
      { "<leader>sG", function() Snacks.picker.grep({ cwd = User.root({ preset = "cwd" }), layout = { preset = "vertical" } }) end, desc = "Grep (Global cwd)" },
      { "<leader>sc", function() Snacks.picker.grep({ cwd = vim.fn.stdpath "config" --[[@as string?]], layout = { preset = "vertical" } }) end, desc = "Grep Config File" },
      { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
      { "<leader>sw", function() Snacks.picker.grep_word({ cwd = User.root({ preset = "root", opts = { buffer = true } }), layout = { preset = "vertical" } }) end, desc = "Visual selection or word (By count)", mode = { "n", "x" } },
      { "<leader>sW", function() Snacks.picker.grep_word({ cwd = User.root({ preset = "cwd" }), layout = { preset = "vertical" } }) end, desc = "Visual selection or word (Global cwd)", mode = { "n", "x" } },
      -- search
      { "<leader>s'", function() Snacks.picker.marks() end, desc = "Marks" },
      { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
      { "<leader>s:", function() Snacks.picker.command_history() end, desc = "Command History" },
      { '<leader>s/', function() Snacks.picker.search_history() end, desc = "Search History" },
      { "<leader>s?", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
      { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
      { "<leader>sd", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
      { "<leader>sD", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
      { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
      { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
      { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
      { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
      { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
      { "<leader>sm", function() Snacks.picker.man() end, desc = "Man Pages" },
      { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
      { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
      { "<leader>su", function() Snacks.picker.undo() end, desc = "Undotree" },

      -- lsp
      { "<leader>ss", function() Snacks.picker.lsp_symbols({ filter = User.config.kind_filter }) end, desc = "LSP Symbols" },
      { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols({ filter = User.config.kind_filter }) end, desc = "LSP Workspace Symbols" },
      -- explorer
      { "<leader>fe", function() Snacks.picker.explorer({ cwd = User.root({ preset = "root", opts = { buffer = true } }) }) end, desc = "Explorer Snacks (By Count)" },
      { "<leader>fE", function() Snacks.picker.explorer({ cwd = User.root({ preset = "cwd" }) }) end, desc = "Explorer Snacks (Global cwd)" },
      -- git
      { "<leader>fg", function() Snacks.picker.git_files({ cwd = User.root({ preset = "git", opts = { buffer = true } }) }) end, desc = "Git Files" },
      { "<leader>fG", function() Snacks.picker.git_grep({ cwd = User.root({ preset = "git", opts = { buffer = true } }), lazyout = { preset = "vertical" }}) end, desc = "Git Grep" },
      { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
      { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
      { "<leader>gl", function() Snacks.picker.git_log_line({layout = { preset = "vertical" }}) end, desc = "Git Log Line" },
      { "<leader>gL", function() Snacks.picker.git_log_file({layout = {fullscreen = true}}) end, desc = "Git Log File" },
      { "<leader>g<C-l>", function() Snacks.picker.git_log({layout = {fullscreen = true}}) end, desc = "Git log" },

      -- todo-comment
      { "<leader>st", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },
      { "<leader>sT", function() Snacks.picker.todo_comments() end, desc = "Todo" },
    },
  },
}
