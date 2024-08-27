local find_command = { "rg", "--files", "--color", "never" }

local gen_egrepfiy = function(_opts)
  _opts = _opts or {}
  return function()
    local opts
    if type(_opts) == "function" then
      opts = _opts()
    end
    require("telescope").extensions.egrepify.egrepify(opts or _opts)
  end
end
return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "fdschmidt93/telescope-egrepify.nvim" },
  keys = {
    { "<leader>sg", gen_egrepfiy(), desc = "Grep (Root Dir)" },
    {
      "<leader>sG",
      gen_egrepfiy(function()
        local opts = { cwd = vim.fn.expand("%:p:h") }
        return opts
      end),
      desc = "Grep (Cwd)",
    },
    { "<leader>sB", gen_egrepfiy({ grep_open_files = true }), desc = "Grep Buffers" },
    {
      "<leader>/",
      gen_egrepfiy(function()
        local opts = {}
        if vim.bo.filetype ~= "" then
          local vimgrep_arguments = vim.deepcopy(require("telescope.config").values.vimgrep_arguments)
          opts.vimgrep_arguments = vim.list_extend(vimgrep_arguments, { "--type", vim.bo.filetype })
        end
        return opts
      end),
    },
    {
      "<leader><space>",
      function()
        local opts = {}
        if vim.bo.filetype ~= "" then
          local my_find_command = vim.deepcopy(require("telescope.config").values.find_command or find_command)
          opts.find_command = vim.list_extend(my_find_command, { "--type", vim.bo.filetype })
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
