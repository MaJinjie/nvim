--[[  <leader> ff f. fb fd fw fW dz dm df ds ss sb sg                                        ]]
--11
local mt = require("plugins.utils.telescope")
return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader><leader>",  false },
      { "<leader><leader>t", "<cmd> Telescope resume <cr>", desc = "Telescope resume" },
      {
        "<leader>ff",
        function()
          mt.builtin("find_files", "fd") {
            cwd = vim.fn.expand('%:p:h'),
            find_command = mt.custom_command("fd", "-tf -d3")
          }
        end,
        desc = "find . directory files"
      },
      {
        "<leader>fd",
        function()
          mt.builtin("find_files", "fd") {
            cwd = vim.loop.cwd(),
            find_command = mt.custom_command("fd", "-tf -d5")
          }
        end,
        desc = "find workspace files"
      },
      {
        "<leader>fp",
        function()
          -- vim.print(vim.fn.expand('%:p:h:h'), vim.fn.expand('%:p:h:t'))
          mt.builtin("find_files", "fd") {
            cwd = vim.fn.expand('%:p:h:h'),
            find_command = mt.custom_command("fd", string.format("-tf -d4 -E %s", vim.fn.expand("%:p:h:t")))
          }
        end,
        desc = "find parentdir files"
      },
      {
        "<leader>fb",
        function()
          mt.builtin("buffers", "fd") {
            sort_mru = true,
            sort_lastused = true
          }
        end,
      },
      {
        "<leader>fc",
        function()
          mt.builtin("find_files", "fd") {
            cwd = "~/.config/nvim",
            find_command = mt.custom_command("fd")
          }
        end,
      },
      {
        "<leader>fg",
        function()
          mt.builtin("git_files", "fd") {}
        end,
      },
      {
        "<leader>fr",
        function()
          mt.builtin("oldfiles", "fd") { path_display = function(_, path) return vim.fn.fnamemodify(path, ":~") end }
        end,
      },
      -- search
      {
        "<leader>sg", false
      },
      {
        "<leader>sb",
        function()
          mt.builtin("current_buffer_fuzzy_find", 'rg') { preview = { hide_on_startup = true } }
        end,
        desc = "Buffer"
      },
      {
        "<leader>sc",
        "<cmd>Telescope commands<cr>",
        desc = "Commands"
      },
      {
        "<leader>s;",
        "<cmd>Telescope command_history<cr>",
        desc = "Command History"
      },
      -- { '<leader>s"',      "<cmd>Telescope registers<cr>",                                    desc = "Registers" },
      -- { "<leader>sa",      "<cmd>Telescope autocommands<cr>",                                 desc = "Auto Commands" },
      -- { "<leader>sd",      "<cmd>Telescope diagnostics bufnr=0<cr>",                          desc = "Document diagnostics" },
      -- { "<leader>sD",      "<cmd>Telescope diagnostics<cr>",                                  desc = "Workspace diagnostics" },
      -- { "<leader>sh",      "<cmd>Telescope help_tags<cr>",                                    desc = "Help Pages" },
      -- { "<leader>sH",      "<cmd>Telescope highlights<cr>",                                   desc = "Search Highlight Groups" },
      -- { "<leader>sk",      "<cmd>Telescope keymaps<cr>",                                      desc = "Key Maps" },
      -- { "<leader>sM",      "<cmd>Telescope man_pages<cr>",                                    desc = "Man Pages" },
      -- { "<leader>sm",      "<cmd>Telescope marks<cr>",                                        desc = "Jump to Mark" },
      -- { "<leader>so",      "<cmd>Telescope vim_options<cr>",                                  desc = "Options" },
      -- { "<leader>sR",      "<cmd>Telescope resume<cr>",                                       desc = "Resume" },
      -- { "<leader>sw",      Util.telescope("grep_string", { word_match = "-w" }),              desc = "Word (root dir)" },
      -- { "<leader>sW",      Util.telescope("grep_string", { cwd = false, word_match = "-w" }), desc = "Word (cwd)" },
      -- { "<leader>uC",      Util.telescope("colorscheme", { enable_preview = true }),          desc = "Colorscheme with preview" },
      -- git
      { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "commits" },
      { "<leader>gs", "<cmd>Telescope git_status<CR>",  desc = "status" },
    },
    config = function(_, opts)
      local action_layout = require("telescope.actions.layout")
      require("telescope").setup {
        defaults = {
          mappings = {
            i = {
              ["<esc>"] = function(bufnr)
                require("telescope.actions").close(bufnr)
              end,
              ["<C-\\>"] = action_layout.toggle_preview,
              ["<C-u>"] = function(bufnr)
                vim.api.nvim_feedkeys(
                  vim.api.nvim_replace_termcodes(
                    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs> \
                    <bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
                    true, false, true),
                  "n",
                  false
                )
              end,
            },
            n = {
              ["q"] = require("telescope.actions").close,
              ["<C-\\>"] = action_layout.toggle_preview,
            }
          },
          layout_strategy = "horizontal",
          layout_config = {
            prompt_position = "top",

          },
          sorting_strategy = "ascending",
          prompt_title = false,
          borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
          initial_mode = "insert",
          preview = {
            hide_on_startup = false
          },
          winblend = 0,
        }

      }
    end
  },
  ------------------------------[[dirs jump ]]------------------------------^
  {
    "jvgrootveld/telescope-zoxide",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-telescope/telescope-file-browser.nvim" },
    keys = {
      { "<leader>dz", "<cmd> Telescope zoxide list<cr>", desc = "open zoxide" },
    },
    config = function()
      local t = require("telescope")
      local builtin = require("telescope.builtin")
      t.setup({
        extensions = {
          zoxide = {
            list_command = "zoxide query -ls",
            mappings = {
              ["<C-s>"] = { action = false },
              ["<C-v>"] = { action = false },
              ["<C-e>"] = { action = false },
              ["<C-t>"] = { action = false },
              default = {
                after_action = function(selection)
                  vim.print("Update to (" .. selection.z_score .. ") " .. selection.path)
                  vim.cmd("Telescope file_browser path=" .. selection.path)
                end
              },
              ["<C-g>"] = {
                keepinsert = true,
                action = function(selection)
                  builtin.live_grep({ cwd = selection.path })
                end
              },
              ["<C-f>"] = {
                keepinsert = true,
                action = function(selection)
                  mt.builtin("find_files", "fd") {
                    cwd = selection.path,
                    find_command = mt.custom_command("fd", "-tf")
                  }
                end
              },
              ["<C-b>"] = {
                keepinsert = true,
                action = function(selection)
                  vim.cmd("Telescope file_browser path=" .. selection.path)
                end
              },
            }
          },
        },
      })
      t.load_extension('zoxide')
    end
  },
  {
    "lmburns/telescope-rualdi.nvim",
    dir = "~/.config/nvim/dev/telescope-rualdi.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = {
      { "<leader>dm", "<cmd> Telescope rualdi list<cr>", desc = "open rualdi" },
    },
    config = function()
      require("telescope").setup({
        extensions = {
          rualdi = {
            prompt_title = "Rualdi", -- title of the prompt
            layout_strategy = "bottom_pane",
            layout_config = {
              height = 20,
            },
            command = function(selection)
              vim.cmd("Telescope file_browser path=" .. selection.path)
            end,
            live_grep = function(selection)
              require("telescope.builtin").live_grep({ cwd = selection.path })
            end,
            find_files = function(selection)
              mt.builtin("find_files", "fd") {
                cwd = selection.path,
                find_command = mt.custom_command("fd", "-tf")
              }
            end,
            alias_hl = "Normal", -- highlight group for the alias
            path_hl = "Comment", -- highlight group for the path
          }
        }
      })
      require("telescope").load_extension("rualdi")
    end,
  },
  {
    "princejoogie/dir-telescope.nvim",
    -- telescope.nvim is a required dependency
    dependency = { "nvim-telescope/telescope.nvim" },
    keys = {
      { "<leader>dg", "<cmd>Telescope dir live_grep<cr>",  desc = "live_grep(dir)" },
      { "<leader>df", "<cmd>Telescope dir find_files<cr>", desc = "find files(dir)" },
    },
    -- cwd
    config = function()
      require("dir-telescope").setup({
        -- these are the default options set
        hidden = true,
        no_ignore = false,
        show_preview = true,
        find_command = function()
          return { "fd", "--type", "d", "--hidden", "--exclude", ".git", "--exclude", "node_modules" }
        end,
      })
      require("telescope").load_extension("dir")
    end,
  },
  ------------------------------[[dirs jump ]]------------------------------$
  {
    'prochri/telescope-all-recent.nvim',
    event = "VeryLazy",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "kkharji/sqlite.lua",
      -- optional, if using telescope for vim.ui.select
      "stevearc/dressing.nvim"
    },
    config = function()
      require 'telescope-all-recent'.setup {
        database = {
          folder = vim.fn.stdpath("data"),
          file = "telescope-all-recent.sqlite3",
          max_timestamps = 10,
        },
        debug = false,
        scoring = {
          recency_modifier = {                 -- also see telescope-frecency for these settings
            [1] = { age = 240, value = 100 },  -- past 4 hours
            [2] = { age = 1440, value = 80 },  -- past day
            [3] = { age = 4320, value = 60 },  -- past 3 days
            [4] = { age = 10080, value = 40 }, -- past week
            [5] = { age = 43200, value = 20 }, -- past month
            [6] = { age = 129600, value = 10 } -- past 90 days
          },
          -- how much the score of a recent item will be improved.
          boost_factor = 0.0001
        },
        default = {
          disable = true,    -- disable any unkown pickers (recommended)
          use_cwd = true,    -- differentiate scoring for each picker based on cwd
          sorting = 'recent' -- sorting: options: 'recent' and 'frecency'
        },
        pickers = {          -- allows you to overwrite the default settings for each picker
          man_pages = {      -- enable man_pages picker. Disable cwd and use frecency sorting.
            disable = false,
            use_cwd = false,
            sorting = 'frecency',
          },

          -- change settings for a telescope extension.
          -- To find out about extensions, you can use `print(vim.inspect(require'telescope'.extensions))`
          ['file_browser#file_browser'] = {
            disable = false,
            use_cwd = true,
            sorting = 'frecency'
          },
          ["jvgrootveld/telescope-zoxide"] = {
            disable = false,
            use_cwd = false,
            sorting = 'recent',
          },
          ["lmburns/telescope-rualdi.nvim"] = {
            disable = false,
            use_cwd = false,
            sorting = 'frecency',
          }
        }
      }
    end
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    keys = {
      {
        "<leader>fw",
        function()
          vim.cmd("Telescope file_browser path=" .. vim.loop.cwd())
        end,
        desc = "open filw_brower w",
        silent = true,
      },
      {
        "<leader>f.",
        "<cmd> Telescope file_browser path=%:p:h <CR>",
        desc = "open file_brower .",
        silent = true,
      },
      {
        "<leader>fh",
        "<cmd> Telescope file_browser path=~ <CR>",
        desc = "find home files",
        silent = true,
      },
      {
        "<leader>f/",
        "<cmd> Telescope file_browser path=/ <CR>",
        desc = "find root files",
        silent = true,
      },
    },
    init = function()
      if vim.fn.argc(-1) == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then
          require("telescope").load_extension("file_browser")
        end
      end
    end,
    config = function()
      local fb_actions = require("telescope._extensions.file_browser.actions")
      local action_state = require("telescope.actions.state")
      require("telescope").setup {
        extensions = {
          file_browser = {
            -- path = vim.loop.cwd(),
            -- cwd = vim.loop.cwd(),
            cwd_to_path = true,
            layout_strategy = "bottom_pane",
            layout_config = {
              height = 20,
            },
            select_buffer = true,
            hidden = { file_browser = true, folder_browser = true },
            hide_parent_dir = true,
            prompt_path = false,
            quiet = true,
            hijack_netrw = true,
            use_ui_input = true,
            depth = 1,
            follow_symlinks = true,
            mappings = {
              ["i"] = {
                ["<C-u>"] = fb_actions.goto_home_dir,
                ["<C-e>"] = fb_actions.goto_cwd,
                ["<C-t>"] = fb_actions.toggle_browser,
                ["<C-.>"] = fb_actions.toggle_hidden,
                ["<C-s>"] = fb_actions.toggle_all,
                ["<bs>"] = function()
                  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<bs>", true, false, true), "n", false)
                end,
                ["<C-w>"] = function(prompt_bufnr, bypass)
                  local current_picker = action_state.get_current_picker(prompt_bufnr)

                  if current_picker:_get_prompt() == "" then
                    fb_actions.goto_parent_dir(prompt_bufnr, bypass)
                  else
                    vim.api.nvim_feedkeys(
                      vim.api.nvim_replace_termcodes("<bs><bs><bs><bs><bs><bs>", true, false, true),
                      "n",
                      false
                    )
                  end
                end,
                ["/"] = fb_actions.open_dir,
              },
              ["n"] = {
                ["c"] = fb_actions.create,
                ["r"] = fb_actions.rename,
                ["m"] = fb_actions.move,
                ["y"] = fb_actions.copy,
                ["d"] = fb_actions.remove,

                ["h"] = fb_actions.goto_parent_dir,
                ["<C-w>"] = fb_actions.goto_parent_dir,
                ["l"] = fb_actions.open_dir,
                ["/"] = fb_actions.open_dir,

                ["u"] = fb_actions.goto_home_dir,
                ["e"] = fb_actions.goto_cwd,
                ["t"] = fb_actions.toggle_browser,
                ["."] = fb_actions.toggle_hidden,
                ["s"] = fb_actions.toggle_all,
              },
            },
          }
        }
      }
      require("telescope").load_extension("file_browser")
    end,
  },
  {
    "jonarrien/telescope-cmdline.nvim",
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
    keys = {
      { '<leader>;', '<cmd>Telescope cmdline<cr>', noremap = true, desc = 'Cmdline' }
    },
    config = function()
      require("telescope").setup({
        extensions = {
          cmdline = {
            picker   = {
              layout_config = {
                width  = 100,
                height = 25,
              }
            },
            mappings = {
              complete      = '<Tab>',
              run_selection = '<C-CR>',
              run_input     = '<CR>',
            },
          }
        }
      })
      require("telescope").load_extension('cmdline')
    end,
  }
}
