return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  init = function()
    -- register vim.ui.select
    User.util.on_verylazy(function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("fzf-lua").register_ui_select(function(o, items)
          local min_h, max_h = 0.30, 0.80
          local preview = o.kind == "codeaction" and 0.30 or 0
          local h = (#items + 4) / vim.o.lines + preview
          if h < min_h then
            h = min_h
          elseif h > max_h then
            h = max_h
          end
          return {
            prompt = " ",
            winopts = {
              height = h,
              width = 0.50,
              row = 0.40,
              title = " " .. vim.trim((o.prompt or "Select"):gsub("%s*:%s*$", "")) .. " ",
              title_pos = "center",
            },
          }
        end)
        return vim.ui.select(...)
      end
    end)
  end,
  opts = function()
    local actions = require("fzf-lua.actions")
    return {
      { "default-title" },
      fzf_opts = {
        ["--tiebreak"] = "chunk",
        ["--history"] = vim.fn.stdpath("data") .. "/fzf-history",
      },
      winopts = {
        boarder = "single",
        preview = {
          wrap = "nowrap",
          hidden = "nohidden",
          vertical = "up:35%",
          horizontal = "right:55%",
          layout = "flex",
          flip_columns = 100,
        },
      },
      keymap = {
        builtin = {
          ["<F1>"] = "toggle-help",
          ["<F2>"] = "toggle-fullscreen",
          ["<F3>"] = "toggle-preview-wrap",
          ["<C-/>"] = "toggle-preview",
          ["<C-b>"] = "preview-page-up",
          ["<C-f>"] = "preview-page-down",
        },
        fzf = {},
      },
      actions = {
        files = {
          ["enter"] = actions.file_edit,
          ["ctrl-s"] = actions.file_split,
          ["ctrl-v"] = actions.file_vsplit,
          ["ctrl-t"] = actions.file_tabedit,
          ["ctrl-q"] = actions.file_sel_to_qf,
        },
      },
      defaults = { formatter = "path.dirname_first" },
      previewers = {
        builtin = {
          extensions = {
            ["png"] = "chafa",
            ["jpg"] = "chafa",
            ["jpeg"] = "chafa",
            ["gif"] = "chafa",
            ["webp"] = "chafa",
          },
          ueberzug_scaler = "fit_contain",
        },
      },
      buffers = {
        sort_lastused = true,
        ignore_current_buffer = true,
        fzf_opts = { ["--scheme"] = "path" },
      },
      blines = {
        winopts = { preview = { layout = "vertical" } },
      },
      files = {
        cwd_prompt = false,
        fzf_opts = { ["--scheme"] = "path", ["--history"] = vim.fn.stdpath("data") .. "/fzf-find-history" },
      },
      grep = {
        winopts = { preview = { layout = "vertical" } },
        fzf_opts = { ["--history"] = vim.fn.stdpath("data") .. "/fzf-grep-history" },
        rg_glob = true,
        glob_flag = "--iglob",
        glob_separator = vim.pesc(" -- "),
        ---@param query string
        ---@param opts fzf-lua.grep.Opts
        rg_glob_fn = function(query, opts)
          local s, e = query:match("^.*()" .. opts.glob_separator .. "().*$")
          ---@cast s integer
          ---@cast e integer

          local search_string = query:sub(1, s - 1)
          local flags_string = query:sub(e - 1):gsub("%f[%S]([^%-%s]+)", function(g1)
            return opts.glob_flag .. "=" .. vim.fn.shellescape(g1)
          end)

          return vim.trim(search_string), vim.trim(flags_string)
        end,
      },
      lsp = {
        symbols = {
          path_shorten = 1,
          symbol_icons = User.config.icons.lsp,
        },
        code_actions = {
          winopts = {
            preview = {
              layout = "vertical",
              vertical = "up:70%,border-bottom",
            },
          },
          previewer = vim.fn.executable("delta") == 1 and "codeaction_native" or nil,
          preview_pager = "delta --width=$COLUMNS --hunk-header-style='omit' --file-style='omit'",
        },
      },
    }
  end,
  -- stylua: ignore
  keys = {
    { "<leader>ff", "<cmd>lua require'fzf-lua'.files{cwd=require'util.root'{}}<cr>", desc = "Find files (root)" },
    { "<leader>fF", "<cmd>lua require'fzf-lua'.files{cwd=require'util.root'{follow=true}}<cr>", desc = "Find files (Root)", },
    { "<leader>f;", "<cmd>lua require'fzf-lua'.files{cwd=require'util.root'{specs ={'pwd','cwd'}}}<cr>", desc = "Find files (pwd,cwd)", },
    { "<leader>ss", "<cmd>lua require'fzf-lua'.live_grep{cwd=require'util.root'{}}<cr>", desc = "Grep files (root)" },
    { "<leader>sS", "<cmd>lua require'fzf-lua'.live_grep{cwd=require'util.root'{follow=true}}<cr>", desc = "Grep files (Root)", },
    { "<leader>s;", "<cmd>lua require'fzf-lua'.live_grep{cwd=require'util.root'{specs ={'pwd','cwd'}}}<cr>", desc = "Grep files (pwd,cwd)", },
    { "<leader>fc", "<cmd>lua require'fzf-lua'.files{cwd=vim.fn.stdpath'config'}<cr>", desc = "Find Config files" },
    { "<leader>sc", "<cmd>lua require'fzf-lua'.live_grep{cwd=vim.fn.stdpath'config'}<cr>", desc = "Grep Config files" },
    { "<leader>,", "<cmd>FzfLua buffers<cr>", desc = "Find buffers" },
    { "<leader>f,", "<cmd>FzfLua blines<cr>", desc = "Search blines" },
    { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Find oldfiles" },
    { "<leader>f:", "<cmd>FzfLua command_history<cr>", desc = "Find Command_History" },
    { "<leader>f/", "<cmd>FzfLua search_history<cr>", desc = "Find Search_History" },
    { "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "Find keymap" },
    { "<leader>fh", "<cmd>FzfLua helptags<cr>", desc = "Find help" },
    { "<leader>fm", "<cmd>FzfLua manpages<cr>", desc = "Find man" },
    { "<leader>f'", "<cmd>FzfLua marks<cr>", desc = "Find mark" },
    { '<leader>f"', "<cmd>FzfLua registers<cr>", desc = "Find register" },
    { '<leader>F', "<cmd>FzfLua<cr>", desc = "Find register" },
    { '<leader>f<cr>', "<cmd>FzfLua resume<cr>", desc = "Find resume" },
    -- git
    { "<leader>gf", "<cmd>FzfLua git_files<cr>", desc = "Git files" },
    { "<leader>gs", "<cmd>FzfLua git_status<CR>", desc = "Git status" },
    -- lsp
    { "<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Search Symbols" },
    { "<leader>fS", "<cmd>FzfLua lsp_workspace_symbols<cr>", desc = "Search Symbols (Workspace)" },
  },
}

---@class fzf-lua.grep.Opts
---@field cmd string
---@field color_icons boolean
---@field file_icons boolean
---@field git_icons boolean
---@field glob_flag string
---@field glob_separator string
---@field rg_glob boolean
---@field g ...
---@field argv_expr boolean
