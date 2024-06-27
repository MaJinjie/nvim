---@type LazyPluginSpec
return {
  "nvim-neotest/neotest",
  cmd = "Neotest",
  opts = function(_, opts)
    local user_opts = {}

    user_opts = {
      adapters = {
        require "rustaceanvim.neotest",
      },
    }
    vim.diagnostic.config({
      virtual_text = {
        format = function(diagnostic)
          local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
          return message
        end,
      },
    }, vim.api.nvim_create_namespace "neotest")

    return vim.tbl_deep_extend("force", opts, user_opts)
  end,
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<Leader>T"] = { desc = "󰗇 Tests" },
            ["<Leader>Tt"] = { function() require("neotest").run.run() end, desc = "Run test" },
            ["<Leader>Td"] = { function() require("neotest").run.run { strategy = "dap" } end, desc = "Debug test" },
            ["<Leader>Tf"] = {
              function() require("neotest").run.run(vim.fn.expand "%") end,
              desc = "Run all tests in file",
            },
            ["<Leader>Tp"] = {
              function() require("neotest").run.run(vim.fn.getcwd()) end,
              desc = "Run all tests in project",
            },
            ["<Leader>T<CR>"] = { function() require("neotest").summary.toggle() end, desc = "Test Summary" },
            ["<Leader>To"] = { function() require("neotest").output.open() end, desc = "Output hover" },
            ["<Leader>TO"] = { function() require("neotest").output_panel.toggle() end, desc = "Output window" },
            ["]T"] = { function() require("neotest").jump.next() end, desc = "Next test" },
            ["[T"] = { function() require("neotest").jump.prev() end, desc = "previous test" },
          },
        },
      },
    },
  },
}
