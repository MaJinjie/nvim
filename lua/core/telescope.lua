--[[
themes: dropdown cursor ivy
layout_strategy: 
layout_config:
--]]
local layout_config = {
  bottom_pane = {
    {
      height = 13,
      preview_cutoff = 120,
    },
  },
  center = {
    {
      height = 14,
      width = 60,
      preview_cutoff = 150,
    },
    {
      height = 0.7,
      width = 0.8,
      preview_cutoff = 15,
    },
  },
  horizontal = {
    {
      height = 15,
      width = 60,
      preview_cutoff = 1200,
    },
    {
      height = 0.8,
      width = 0.9,
      preview_width = 0.6,
      preview_cutoff = 120,
    },
  },
  vertical = {
    {
      height = 0.95,
      width = 0.85,
      preview_height = 0.4,
      preview_cutoff = 15,
    },
  },
}

layout_config.bottom_pane.default = layout_config.bottom_pane[1]
layout_config.center.default = layout_config.center[1]
layout_config.horizontal.default = layout_config.horizontal[2]
layout_config.vertical.default = layout_config.vertical[1]

---@type LazySpec
return {
  "nvim-telescope/telescope.nvim",
  opts = function(_, opts)
    local actions, actions_layout = require "telescope.actions", require "telescope.actions.layout"
    local fb_actions = require "telescope._extensions.file_browser.actions"

    local user_opts = {}
    user_opts = {
      defaults = {
        layout_strategy = "flex",
        layout_config = {
          prompt_position = "top",
          bottom_pane = layout_config.bottom_pane.default,
          center = layout_config.center.default,
          horizontal = layout_config.horizontal.default,
          vertical = layout_config.vertical.default,
          flex = {
            flip_columns = 120,
            flip_lines = 15,
            horizontal = layout_config.horizontal.default,
            vertical = layout_config.vertical.default,
          },
        },
        mappings = {
          i = {
            ["<C-u>"] = false,

            ["<Esc>"] = actions.close,
            ["<C-s>"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            ["<C-t>"] = actions.select_tab,
            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            ["<C-g>"] = actions.to_fuzzy_refine,
            ["<C-/>"] = actions_layout.toggle_preview,

            ["<A-a>"] = actions.toggle_all,
            ["<A-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<A-j>"] = actions.preview_scrolling_down,
            ["<A-k>"] = actions.preview_scrolling_up,
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
          "--trim",
        },
      },
      pickers = {
        buffers = { layout_strategy = "center", mappings = { i = { ["<C-d>"] = actions.delete_buffer } } },
        find_files = { layout_strategy = "center" },
        git_files = { layout_strategy = "center" },
      },
    }

    user_opts.extensions = {
      frecency = {
        layout_strategy = "center",

        workspaces = {
          ["conf"] = vim.fn.expand "$XDG_CONFIG_HOME",
          ["zsh"] = vim.fn.expand "$XDG_CONFIG_HOME/zsh",
          ["nvim"] = vim.fn.expand "$XDG_CONFIG_HOME/nvim",
          ["home"] = vim.fn.expand "$HOME",
          ["rustNote"] = vim.fn.expand "$HOME/notes/languages/rust/new",
          ["rustStudy"] = vim.fn.expand "$HOME/study/rust-examples",
        },
      },
      file_browser = {
        layout_strategy = "bottom_pane",

        cwd_to_path = true,
        hide_parent_dir = true,
        grouped = true,
        collapse_dirs = true,
        quiet = true,
        hidden = false,
        respect_gitignore = true,
        no_ignore = false,
        mappings = {
          i = {
            ["/"] = fb_actions.open_dir,
            ["<C-w>"] = fb_actions.goto_parent_dir,
            ["<C-t>"] = fb_actions.toggle_browser,
            ["<C-h>"] = fb_actions.toggle_hidden,
            ["<C-c>"] = fb_actions.change_cwd,
            ["<S-enter>"] = fb_actions.create_from_prompt,
          },
        },
      },
      lazy = {
        layout_strategy = "center",

        mappings = {
          open_in_browser = "<C-o>",
          open_in_file_browser = "<C-b>",
          open_in_find_files = "<C-f>",
          open_in_live_grep = "<C-g>",
          open_in_terminal = "<C-t>",
          open_lazy_root_find_files = "<C-c>f",
          open_lazy_root_live_grep = "<C-c>g",
          change_cwd_to_plugin = "<C-c>d",
        },
      },
      helpgrep = {
        ignore_paths = { vim.fn.stdpath "state" .. "/lazy/readme" },
        default_grep = function() require("telescope").extensions.egrepify.egrepify {} end,
      },
      egrepify = {
        layout_strategy = "vertical",

        prefixes = {
          ["#"] = {
            -- in the above example #lua,md -> input: lua,md -> output: --glob="*.{lua,md}"
            flag = "iglob",
            cb = function(input) return string.format([[*.{%s}]], input) end,
          },
          ["#!"] = {
            -- in the above example #lua,md -> input: lua,md -> output: --glob="!*.{lua,md}"
            flag = "iglob",
            cb = function(input) return string.format([[!*.{%s}]], input) end,
          },
          -- filter for (partial) folder names
          [">"] = {
            flag = "iglob",
            cb = function(input) return string.format([[%s*/**]], input) end,
          },
          [">!"] = {
            flag = "iglob",
            cb = function(input) return string.format([[!%s*/**]], input) end,
          },
          ["<"] = {
            flag = "iglob",
            cb = function(input) return string.format([[**/%s*/*]], input) end,
          },
          ["<!"] = {
            flag = "iglob",
            cb = function(input) return string.format([[!**/%s*/*]], input) end,
          },
          -- filter for (partial) file names
          ["&"] = {
            flag = "iglob",
            cb = function(input) return string.format([[**/%s*/**]], input) end,
          },
          ["&!"] = {
            flag = "iglob",
            cb = function(input) return string.format([[!**/%s*/**]], input) end,
          },
          ["@"] = {
            flag = "iglob",
            cb = function(input) return string.format([[%s]], input) end,
          },
          ["@!"] = {
            flag = "iglob",
            cb = function(input) return string.format([[!%s]], input) end,
          },
        },
      },
      undo = {
        side_by_side = false,
      },
    }

    return vim.tbl_deep_extend("force", opts, user_opts)
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-frecency.nvim",
    "nvim-telescope/telescope-file-browser.nvim",
    "tsakirist/telescope-lazy.nvim",
    "catgoose/telescope-helpgrep.nvim",
    "fdschmidt93/telescope-egrepify.nvim",
    "debugloop/telescope-undo.nvim",
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<Leader>fg"] = { function() require("telescope.builtin").git_files() end, desc = "Find git files" },
            ["<Leader>fo"] = {
              function() require("telescope").extensions.frecency.frecency() end,
              desc = "Find history",
            },
            ["<Leader>fe"] = {
              function() require("telescope").extensions.file_browser.file_browser { path = vim.fn.expand "%:p:h" } end,
              desc = "Find currentDir files",
            },
            ['<Leader>f"'] = { function() require("telescope.builtin").registers() end, desc = "Find Registers" },
            ["<Leader>fH"] = { "<Cmd> Telescope helpgrep <Cr>", desc = "Grep help" },
            ["<Leader>fL"] = { "<Cmd> Telescope lazy <Cr>", desc = "Find lazyplugins" },
            ["<Leader>fw"] = {
              function() require("telescope").extensions.egrepify.egrepify { cwd = vim.fn.expand "%:p:h" } end,
              desc = "Grep word in current file directory",
            },
            ["<Leader>fW"] = {
              function() require("telescope").extensions.egrepify.egrepify { cwd = vim.uv.cwd() } end,
              desc = "Grep word in cwd",
            },
            ["<Leader>fu"] = { "<Cmd> Telescope undo <Cr>", desc = "Find Undotree" },
          },
        },
      },
    },
  },
}
