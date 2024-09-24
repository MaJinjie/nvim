if true then
   return {}
end
return {
   "yetone/avante.nvim",
   event = "VeryLazy",
   lazy = false,
   opts = {},
   -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
   build = "make",
   dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      -- "zbirenbaum/copilot.lua",
      {
         -- support for image pasting
         "HakonHarnes/img-clip.nvim",
         event = "VeryLazy",
         opts = {
            -- recommended settings
            default = {
               embed_image_as_base64 = false,
               prompt_for_file_name = false,
               drag_and_drop = {
                  insert_mode = true,
               },
               -- required for Windows users
               use_absolute_path = true,
            },
         },
      },
      {
         -- Make sure to set this up properly if you have lazy=true
         "MeanderingProgrammer/render-markdown.nvim",
         opts = {
            file_types = { "markdown", "Avante" },
         },
         ft = { "markdown", "Avante" },
      },
   },
}
