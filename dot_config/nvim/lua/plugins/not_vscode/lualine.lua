return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local navic = require("nvim-navic")
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "auto",
          component_separators = {
            left = "",
            right = "",
          },
          section_separators = {
            left = "",
            right = "",
          },
          disabled_filetypes = {
            statusline = {
              "dapui_hover",
              "dapui_stacks",
              "dapui_scopes",
              "dapui_console",
              "dapui_breakpoints",
              "dapui_watches",
              "dap-repl",
              "Avante",
              "AvanteSelectedFiles",
              "AvanteInput",
            },
            winbar = {
              "dapui_hover",
              "dapui_stacks",
              "dapui_scopes",
              "dapui_console",
              "dapui_breakpoints",
              "dapui_watches",
              "dap-repl",
            },
          },
          ignore_focus = {},
          always_divide_middle = true,
          globalstatus = false,
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { require("auto-session.lib").current_session_name(), "filename" },
          lualine_x = { "rest", "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
        winbar = {
          lualine_c = {
            {
              function()
                return navic.get_location()
              end,
              cond = function()
                return navic.is_available()
              end,
              color_correction = "dynamic",
              navic_opts = nil,
            },
          },
        },
        inactive_winbar = {},
        extensions = {},
      })
    end,
  },
}
