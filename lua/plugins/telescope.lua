return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "fdschmidt93/telescope-egrepify.nvim" },
  keys = {
    {
      "<leader>sg",
      function()
        require("telescope").extensions.egrepify.egrepify({ cwd = LazyVim.root() })
      end,
      desc = "Grep (Root Dir)",
    },
    {
      "<leader>sG",
      function()
        require("telescope").extensions.egrepify.egrepify({ cwd = vim.uv.cwd() })
      end,
      desc = "Grep (Cwd)",
    },
    {
      "<leader>sB",
      function()
        require("telescope").extensions.egrepify.egrepify({ grep_open_files = true })
      end,
      desc = "Grep Buffers",
    },
    {
      "<leader>/",
      function()
        local opts = { cwd = LazyVim.root() }
        if vim.bo.filetype ~= "" then
          local vimgrep_arguments = LazyVim.get_plugin("telescope.nvim").opts.defaults.vimgrep_arguments
          vimgrep_arguments = vim.deepcopy(vimgrep_arguments)
          opts.vimgrep_arguments = vim.list_extend(vimgrep_arguments, { "--type", vim.bo.filetype })
        end
        require("telescope").extensions.egrepify.egrepify(opts)
      end,
    },
    {
      "<leader><space>",
      function()
        local opts = { cwd = LazyVim.root() }
        if vim.bo.filetype ~= "" then
          local find_command = LazyVim.get_plugin("telescope.nvim").opts.defaults.find_command
          find_command = vim.deepcopy(find_command)
          opts.find_command = vim.list_extend(find_command, { "--type", vim.bo.filetype })
        end
        require("telescope.builtin").find_files(opts)
      end,
    },
  },
  opts = {
    defaults = {
      layout_strategy = "flex",
      sorting_strategy = "ascending",
      dynamic_preview_title = true,
      file_ignore_patterns = { ".git/", ".github/" },
      layout_config = {
        prompt_position = "top",
        bottom_pane = { height = 13, preview_cutoff = 120 },
        center = { height = 14, width = 60, preview_cutoff = 150 },
        horizontal = { height = 0.8, width = 0.9, preview_width = 0.6, preview_cutoff = 120 },
        vertical = { height = 0.95, width = 0.85, preview_height = 0.3, preview_cutoff = 15 },
        flex = {
          flip_columns = 120,
          flip_lines = 15,
          horizontal = { height = 0.8, width = 0.9, preview_width = 0.6, preview_cutoff = 120 },
          vertical = { height = 0.95, width = 0.85, preview_height = 0.3, preview_cutoff = 15 },
        },
      },
      mappings = {
        i = {
          ["<C-u>"] = false,
        },
      },
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
      },
      find_command = { "rg", "--files", "--color", "never" },
    },
    pickers = {
      buffers = { layout_strategy = "center" },
      find_files = { layout_strategy = "center" },
      git_files = { layout_strategy = "center" },
      oldfiles = { layout_strategy = "center" },
      current_buffer_fuzzy_find = { layout_strategy = "vertical", preview = { hide_on_startup = true } },
    },
    extensions = {
      fzf = {
        fuzzy = false, -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      },
      egrepify = {
        layout_strategy = "vertical",

        prefixes = {
          ["##"] = {
            -- in the above example #lua,md -> input: lua,md -> output: --glob="*.{lua,md}"
            flag = "iglob",
            cb = function(input)
              return string.format([[*.{%s}]], input)
            end,
          },
          ["#!"] = {
            -- in the above example #lua,md -> input: lua,md -> output: --glob="!*.{lua,md}"
            flag = "iglob",
            cb = function(input)
              return string.format([[!*.{%s}]], input)
            end,
          },
          -- filter for (partial) folder names
          ["<>"] = {
            flag = "iglob",
            cb = function(input)
              return string.format([[**/%s*/**]], input)
            end,
          },
          [">>"] = {
            flag = "iglob",
            cb = function(input)
              return string.format([[%s*/**]], input)
            end,
          },
          ["<<"] = {
            flag = "iglob",
            cb = function(input)
              return string.format([[**/%s*/*]], input)
            end,
          },
          ["@@"] = {
            flag = "iglob",
            cb = function(input)
              return string.format([[%s]], input)
            end,
          },
          ["@!"] = {
            flag = "iglob",
            cb = function(input)
              return string.format([[!%s]], input)
            end,
          },
        },
      },
    },
  },
}
