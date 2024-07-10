---@type LazySpec
return {
  {
    "smjonas/inc-rename.nvim",
    event = "User AstroLspSetup",
    opts = {},
    specs = {
      "AstroNvim/astrolsp",
      opts = {
        mappings = {
          n = {
            ["<Leader>lr"] = {
              function() return ":IncRename " .. vim.fn.expand "<cword>" end,
              expr = true,
              desc = "Rename current symbol",
              cond = "textDocument/rename",
            },
          },
        },
      },
    },
  },
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    cmd = "Lspsaga",
    opts = function()
      local get_icon = function(icon) return require("astroui").get_icon(icon, 0, true) end

      local user_opts = {}
      local keys = {
        edit = "<Cr>",
        split = "<C-s>",
        vsplit = "<C-v>",
        tabe = "<C-t>",
        quit = "q",
        close = "<C-q>",
      }

      user_opts = {
        code_action = { extend_gitsigns = require("astrocore").is_available "gitsigns.nvim" },
        lightbulb = { sign = false },
        ui = {
          code_action = get_icon "DiagnosticHint",
          expand = get_icon "FoldClosed",
          collapse = get_icon "FoldOpened",
        },
      }

      -- definition & type definition
      user_opts.definition = {
        width = 0.6,
        height = 0.4,
        keys = keys,
      }

      -- hover
      user_opts.hover = {
        open_cmd = "!firefox",
        max_width = 0.8,
        max_height = 0.5,
      }

      --symbol_in_winbar
      user_opts.symbol_in_winbar = {
        hide_keyword = true,
      }

      --finder
      user_opts.finder = {
        max_height = 0.5,
        left_width = 0.3,
        right_width = 0.3,
        default = "i",
        layout = "normal",
        methods = {
          ["d"] = "textDocument/definition",
          ["t"] = "textDocument/typeDefinition",
          ["i"] = "textDocument/implementation",
          ["r"] = "textDocument/references",
        },
        keys = keys,
      }

      -- callHierarchy
      user_opts.callhierarchy = {
        keys = keys,
      }

      -- outline
      user_opts.outline = {
        layout = "float",
        max_height = 0.6,
        left_width = 0.3,
      }

      return user_opts
    end,
    specs = {
      {
        "AstroNvim/astrocore",
        opts = function()
          local nmap = require("utils").keymap.set.n

          nmap {
            ["]d"] = { "<Cmd>Lspsaga diagnostic_jump_next<CR>", desc = "Next diagnostic" },
            ["[d"] = { "<Cmd>Lspsaga diagnostic_jump_prev<CR>", desc = "Previous diagnostic" },
            ["<Leader>ll"] = { ":Lspsaga finder ", desc = "Trigger :Lspsaga finder" },
          }
        end,
      },
      {
        "AstroNvim/astrolsp",
        opts = function(_, opts)
          local user_opts = { mappings = {} }

          user_opts.mappings.n = {
            -- hover
            -- ["K"] = { "<Cmd>Lspsaga hover_doc<CR>", desc = "Hover symbol details", cond = "textDocument/hover" },

            -- declaration
            ["gl"] = {
              function() vim.lsp.buf.declaration() end,
              desc = "Declaration of current symbol",
              cond = "textDocument/declaration",
            },

            -- definition
            ["gd"] = {
              "<Cmd> Lspsaga goto_definition<Cr>",
              cond = "textDocument/definition",
            },
            ["gD"] = {
              "<Cmd> Lspsaga peek_definition<Cr>",
              desc = "Peek definition",
              cond = "textDocument/definition",
            },

            -- type definition
            ["<Leader>gy"] = {
              "<Cmd>Lspsaga goto_type_definition<Cr>",
              cond = "textDocument/typeDefinition",
            },
            ["<Leader>gY"] = {
              "<Cmd>Lspsaga peek_type_definition<Cr>",
              desc = "Peek type definition",
              cond = "textDocument/typeDefinition",
            },

            -- references
            ["gr"] = {
              function() vim.lsp.buf.references() end,
              desc = "Search references",
              nowait = true,
              cond = "textDocument/references",
            },
            ["gR"] = {
              "<Cmd> Lspsaga finder r <Cr>",
              desc = "Search references (Lspsaga)",
              cond = "textDocument/references",
            },

            -- implementation
            ["gI"] = {
              "<Cmd> Lspsaga finder i <Cr>",
              desc = "Implementation of current symbol",
              cond = "textDocument/implementation",
            },

            -- outline
            ["<Leader>lS"] = {
              "<Cmd>Lspsaga outline<CR>",
              desc = "Symbols outline (Lspsaga)",
              cond = "textDocument/documentSymbol",
            },

            -- call hierarchy
            ["<Leader>lc"] = {
              "<Cmd>Lspsaga incoming_calls<CR>",
              desc = "Incoming calls",
              cond = "callHierarchy/incomingCalls",
            },
            ["<Leader>lC"] = {
              "<Cmd>Lspsaga outgoing_calls<CR>",
              desc = "Outgoing calls",
              cond = "callHierarchy/outgoingCalls",
            },

            -- code action
            ["<Leader>la"] = {
              "<Cmd>Lspsaga code_action<CR>",
              desc = "LSP code action",
              cond = "textDocument/codeAction",
            },
          }

          user_opts.mappings.x = {
            ["<Leader>la"] = {
              ":<C-U>Lspsaga code_action<CR>",
              desc = "LSP code action",
              cond = "textDocument/codeAction",
            },
          }

          return vim.tbl_deep_extend("force", opts, user_opts)
        end,
      },
    },
  },
  {
    "stevearc/aerial.nvim",
    opts = {
      filter_kind = {
        "Class",
        "Constructor",
        "Enum",
        "Function",
        "Interface",
        "Method",
        "Module",
        "Namespace",
        "Object",
        "Operator",
        "Package",
        "Property",
        "Struct",
      },
      keymaps = nil,
    },
    specs = {
      "AstroNvim/astrocore",
      opts = function()
        local nmap = require("utils").keymap.set.n

        nmap {
          ["<Leader>ls"] = { "<Cmd> AerialToggle <Cr>", desc = "Symbols outline" },
          ["<Leader>fs"] = { "<Cmd> Telescope aerial <Cr>", desc = "Search symbols" },
        }
      end,
    },
  },
}
