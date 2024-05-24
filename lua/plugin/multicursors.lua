return {
  "smoka7/multicursors.nvim",
  cmd = { "MCstart", "MCpattern", "MCclear", "MCunderCursor" },
  dependencies = {
    "smoka7/hydra.nvim",
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<Leader>m"] = { "<Cmd>MCstart<CR>", desc = "Create a selection for word under the cursor" },
          },
        },
      },
    },
  },
  opts = {
    hint_config = {
      position = "bottom-right",
    },
    generate_hints = {
      config = {
        column_count = 1,
      },
    },
  },
}
