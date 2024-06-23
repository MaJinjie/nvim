---@type LazySpec
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    ---@type CatppuccinOptions
    opts = {
      flavour = "mocha",
      dim_inactive = {
        enabled = true, -- dims the background color of inactive window
        shade = "dark",
        percentage = 0.20, -- percentage of the shade to apply to the inactive window
      },
      --[[ Array Boolean Class Constant Constructor Enum EnumMember Event Field File Function Interface Key
      --Method Module Namespace Null Number Object Operator Package Property String Struct TypeParameter Variable ]]
      styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { "italic" }, -- Change the style of comments
        conditionals = { "italic" },
        loops = { "italic" },
        functions = { "italic" },
        properties = { "italic" },
        types = { "italic" },
        namespace = { "bold" },
      },
      integrations = {
        aerial = true,
        alpha = true,
        cmp = true,
        dap = true,
        dap_ui = true,
        gitsigns = true,
        illuminate = true,
        indent_blankline = true,
        markdown = true,
        mason = true,
        native_lsp = { enabled = true },
        neotree = true,
        notify = true,
        semantic_tokens = true,
        symbols_outline = true,
        telescope = true,
        treesitter = true,
        ts_rainbow = false,
        ufo = true,
        which_key = true,
        window_picker = true,
        neogit = true,
        neotest = true,
        flash = false,
      },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    opts = function(_, opts) opts.scope = { show_start = false, show_end = true } end,
  },
  {
    "lewis6991/satellite.nvim",
    event = "User AstroFile",
    opts = {
      current_only = true,
      excluded_filetypes = { "prompt", "TelescopePrompt", "noice", "notify", "neo-tree", "aerial" },
    },
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = false, -- use a classic bottom cmdline for search
        command_palette = false, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = true, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false, -- add a border to hover docs and signature help
      },
    },
  },
  {
    "heirline.nvim",
    opts = function(_, opts)
      local noice_opts = require("astrocore").plugin_opts "noice.nvim"
      if vim.tbl_get(noice_opts, "lsp", "progress", "enabled") ~= false then -- check if lsp progress is enabled
        opts.statusline[9] = require("astroui.status").component.lsp { lsp_progress = false }
      end
    end,
  },
  {
    "rcarriga/nvim-notify",
    opts = function(_, opts)
      local user_opts = {
        stages = "static",
        fps = 5,
        timeout = 1200,
      }
      return require("astrocore").extend_tbl(opts, user_opts)
    end,
  },
}
