return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
  opts = {
    -- add any opts here
    -- for example
    provider = "copilot",
    providers = {
      copilot = {
        model = "claude-sonnet-4",
      },
    },
    timeout = 60000,
    windows = {
      input = {
        height = 3,
      },
    },
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
    -- "ibhagwan/fzf-lua", -- for file_selector provider fzf
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    {
      -- for providers='copilot'
      "zbirenbaum/copilot.lua",
      event = "InsertEnter",
      cmd = { "Copilot" },
      opts = {
        panel = {
          enabled = false, -- disable the copilot panel
        },
        file_types = {
          yaml = true,
          markdown = true,
          -- Avante = true,
          -- AvanteInput = true,
        },
      },
      config = function(_, opts)
        require("copilot").setup(opts)

        -- Change accept suggestion key
        vim.g.copilot_no_tab_map = true
        vim.keymap.set("i", "<C-j>", 'copilot#Accept("\\<CR>")', {
          desc = "Accept copilot suggestion",
          expr = true,
          replace_keycodes = false,
        })

        -- hide copilot suggestions when avante menu is open
        vim.api.nvim_create_autocmd("User", {
          pattern = "BlinkCmpMenuOpen",
          callback = function()
            vim.b.copilot_suggestion_hidden = true
          end,
        })

        vim.api.nvim_create_autocmd("User", {
          pattern = "BlinkCmpMenuClose",
          callback = function()
            vim.b.copilot_suggestion_hidden = false
          end,
        })
      end,
    },
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
