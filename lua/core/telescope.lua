-- stylua: ignore
local vimgrep_arguments = { "rg", "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case", "--trim" }
local find_command = { "rg", "--files", "--color", "never" }
---@type LazySpec
return {
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      local actions, action_layout = require "telescope.actions", require "telescope.actions.layout"
      local astrocore = require "astrocore"

      local user_opts = {
        defaults = {
          layout_strategy = "flex",
          sorting_strategy = "ascending",
          dynamic_preview_title = true,
          file_ignore_patterns = { ".git/", ".github/" },
          layout_config = {
            prompt_position = "top",
            bottom_pane = {
              height = 13,
              preview_cutoff = 120,
            },
            center = {
              height = 14,
              width = 60,
              preview_cutoff = 150,
            },
            horizontal = {
              height = 0.8,
              width = 0.9,
              preview_width = 0.6,
              preview_cutoff = 120,
            },
            vertical = {
              height = 0.95,
              width = 0.85,
              preview_height = 0.4,
              preview_cutoff = 15,
            },
            flex = {
              flip_columns = 120,
              flip_lines = 15,
              horizontal = {
                height = 0.8,
                width = 0.9,
                preview_width = 0.6,
                preview_cutoff = 120,
              },
              vertical = {
                height = 0.95,
                width = 0.85,
                preview_height = 0.4,
                preview_cutoff = 15,
              },
            },
          },
          mappings = {
            i = {
              ["<bs>"] = false,
              ["<C-u>"] = false,
              ["<C-h>"] = false,
              ["<C-l>"] = false,
              ["<C-a>"] = false,
              ["<C-e>"] = false,

              ["<C-d>"] = actions.results_scrolling_down,
              ["<A-j>"] = actions.preview_scrolling_down,
              ["<A-k>"] = actions.preview_scrolling_up,

              ["<Esc>"] = actions.close,
              ["<C-s>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<C-g>"] = actions.to_fuzzy_refine,
              ["<C-/>"] = action_layout.toggle_preview,

              ["<A-/>"] = actions.which_key,
              ["<A-a>"] = actions.toggle_all,
              ["<A-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            },
          },
          vimgrep_arguments = vimgrep_arguments,
          history = {
            path = "~/.local/share/nvim/telescope_history.sqlite3",
            limit = 100,
          },
        },
        pickers = {
          buffers = { layout_strategy = "center", mappings = { i = { ["<C-d>"] = actions.delete_buffer } } },
          find_files = { layout_strategy = "center" },
          git_files = { layout_strategy = "center" },
          current_buffer_fuzzy_find = { layout_strategy = "vertical", preview = { hide_on_startup = true } },
        },
        extensions = {
          fzf = {
            fuzzy = false, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = "smart_case", -- or "ignore_case" or "respect_case"
          },
        },
      }

      if astrocore.is_available "flash.nvim" then
        user_opts.defaults.mappings.i["<C-z>"] = function(prompt_bufnr)
          require("flash").jump {
            pattern = "^",
            search = {
              mode = "search",
              exclude = {
                function(win) return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults" end,
              },
            },
            action = function(match)
              local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
              picker:set_selection(match.pos[1] - 1)
            end,
          }
        end
      end
      if astrocore.is_available "trouble.nvim" then
        user_opts.defaults.mappings.i["<C-x>"] = function(prompt_bufnr)
          require("trouble.sources.telescope").open(prompt_bufnr)
        end
      end

      return vim.tbl_deep_extend("force", opts, user_opts)
    end,
    specs = {
      "AstroNvim/astrocore",
      opts = function()
        local map = require("utils").keymap.set

        map.n = {
          ["<Leader>gf"] = { function() require("telescope.builtin").git_files() end, desc = "Find Git Files" },

          ["<Leader>fo"] = {
            function()
              require("telescope").extensions.frecency.frecency {
                prompt_title = "Frecency Files",
              }
            end,
            desc = "Find Frecency Files",
          },
          ["<Leader>fe"] = {
            function() require("telescope").extensions.file_browser.file_browser { path = vim.fn.expand "%:p:h" } end,
            desc = "Browser CurrentDir Files",
          },
          ['<Leader>f"'] = { function() require("telescope.builtin").registers() end, desc = "Find Registers" },
          ["<Leader>fH"] = { function() require("telescope").extensions.helpgrep.helpgrep() end, desc = "Grep Help" },
          ["<Leader>fL"] = { function() require("telescope").extensions.lazy.lazy() end, desc = "Find Lazyplugins" },
          ["<Leader>fg"] = {
            function() require("telescope").extensions.egrepify.egrepify { prompt_title = "Live Grep" } end,
            desc = "Grep word in current file directory",
          },
          ["<Leader>fG"] = {
            function()
              require("telescope").extensions.egrepify.egrepify {
                prompt_title = "Live Grep (Hidden)",
                vimgrep_arguments = vim.list_extend(vimgrep_arguments, { "--hidden" }),
              }
            end,
            desc = "Grep word in cwd",
          },
          ["<Leader>fc"] = {
            function()
              require("telescope.builtin").find_files {
                prompt_title = "Find Nvim Files",
                cwd = vim.fn.stdpath "config" .. "/lua",
                find_command = vim.list_extend(find_command, { "--glob", "*.lua" }),
              }
            end,
          },
          ["<Leader>fC"] = {
            function()
              require("telescope").extensions.egrepify.egrepify {
                prompt_title = "Grep Nvim Files",
                cwd = vim.fn.stdpath "config",
                vimgrep_arguments = vim.list_extend(vimgrep_arguments, { "--glob", "*.lua" }),
              }
            end,
          },
          ["<Leader>fa"] = {
            function()
              require("telescope.builtin").git_files {
                prompt_title = "Find Config Files",
                recurse_submodules = false,
                toplevel = vim.env.HOME,
                gitdir = vim.env.HOME .. "/.dotfiles",
              }
            end,
            desc = "Find config files",
          },
          ["<Leader>fB"] = {
            function()
              require("telescope").extensions.egrepify.egrepify {
                prompt_title = "Grep Buffers",
                grep_open_files = true,
              }
            end,
            desc = "Live grep open files",
          },
          ["<Leader>fu"] = { function() require("telescope").extensions.undo.undo() end, desc = "Find Undotree" },
          ["<Leader>ff"] = {
            function() require("telescope").extensions.corrode.corrode { layout_strategy = "center" } end,
            desc = "Find files",
          },
          ["<Leader>fF"] = {
            function()
              require("telescope").extensions.corrode.corrode {
                layout_strategy = "center",
                hidden = true,
                no_ignore = true,
              }
            end,
            desc = "Find all files",
          },
        }
      end,
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-smart-history.nvim", dependencies = "kkharji/sqlite.lua" },
    },
  },
  {
    "nvim-telescope/telescope-frecency.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      opts = function(_, opts)
        local extensions = require("utils").tbl_get(opts, "extensions")
        extensions.frecency = {
          layout_strategy = "center",

          workspaces = {
            ["Conf"] = vim.fn.expand "$XDG_CONFIG_HOME",
            ["Zsh"] = vim.fn.expand "$XDG_CONFIG_HOME/zsh",
            ["Nvim"] = vim.fn.expand "$XDG_CONFIG_HOME/nvim",
            ["Home"] = vim.fn.expand "$HOME",
            ["Study"] = vim.fn.expand "$HOME/study",
            ["Note"] = vim.fn.expand "$HOME/notes",

            ["CppNote"] = vim.fn.expand "$HOME/notes/languages/cpp",
            ["AssemNote"] = vim.fn.expand "$HOME/notes/languages/assembler",
            ["RustNote"] = vim.fn.expand "$HOME/notes/languages/rust/new",

            ["RustStudy"] = vim.fn.expand "$HOME/study/rust-examples",
            ["CppStudy"] = vim.fn.expand "$HOME/study/cpp",
            ["AssemStudy"] = vim.fn.expand "$HOME/study/assembler",
          },
        }
      end,
    },
    config = function() require("telescope").load_extension "frecency" end,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      opts = function(_, opts)
        local extensions = require("utils").tbl_get(opts, "extensions")
        extensions.file_browser = {
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
              ["/"] = function(...) require("telescope._extensions.file_browser.actions").open_dir(...) end,
              ["<C-w>"] = function(prompt_bufnr, bypass)
                local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
                if current_picker:_get_prompt() == "" then
                  require("telescope._extensions.file_browser.actions").goto_parent_dir(prompt_bufnr, bypass)
                else
                  vim.me.api.feedkeys("<C-S-w>", "tn")
                end
              end,
              ["<C-g>"] = function(...) require("telescope._extensions.file_browser.actions").toggle_hidden(...) end,
              ["<C-c>"] = function(...) require("telescope._extensions.file_browser.actions").goto_cwd(...) end,
            },
          },
        }
      end,
    },
    config = function() require("telescope").load_extension "file_browser" end,
  },
  {
    "fdschmidt93/telescope-egrepify.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      opts = function(_, opts)
        local extensions = require("utils").tbl_get(opts, "extensions")
        extensions.egrepify = {
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
            [">>"] = {
              flag = "iglob",
              cb = function(input) return string.format([[%s*/**]], input) end,
            },
            [">!"] = {
              flag = "iglob",
              cb = function(input) return string.format([[!%s*/**]], input) end,
            },
            ["<<"] = {
              flag = "iglob",
              cb = function(input) return string.format([[**/%s*/*]], input) end,
            },
            ["<!"] = {
              flag = "iglob",
              cb = function(input) return string.format([[!**/%s*/*]], input) end,
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
        }
      end,
    },
    config = function() require("telescope").load_extension "egrepify" end,
  },
  {
    "catgoose/telescope-helpgrep.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      opts = function(_, opts)
        local extensions = require("utils").tbl_get(opts, "extensions")
        extensions.helpgrep = {
          ignore_paths = { vim.fn.stdpath "state" .. "/lazy/readme" },
          default_grep = function(...) require("telescope").extensions.egrepify.egrepify(...) end,
        }
      end,
    },
    config = function() require("telescope").load_extension "helpgrep" end,
  },
  {
    "tsakirist/telescope-lazy.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      opts = function(_, opts)
        local extensions = require("utils").tbl_get(opts, "extensions")
        extensions.lazy = {
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
        }
      end,
    },
    config = function() require("telescope").load_extension "lazy" end,
  },
  {
    "debugloop/telescope-undo.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      opts = function(_, opts)
        local extensions = require("utils").tbl_get(opts, "extensions")
        extensions.undo = { side_by_side = false }
      end,
    },
    config = function() require("telescope").load_extension "undo" end,
  },
  {
    "fdschmidt93/telescope-corrode.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      opts = function(_, opts)
        local extensions = require("utils").tbl_get(opts, "extensions")
        extensions.corrode = { layout_strategy = "center" }
      end,
    },
    config = function() require("telescope").load_extension "corrode" end,
  },
}