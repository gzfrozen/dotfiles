return {
  "zbirenbaum/copilot.lua",
  event = "InsertEnter",
  cmd = { "Copilot" },
  dependencies = {
    {
      "copilotlsp-nvim/copilot-lsp",
      config = function()
        vim.g.copilot_nes_debounce = 500
      end,
    },
  },
  opts = {
    panel = {
      enabled = false, -- disable the copilot panel
    },
    file_types = {
      yaml = true,
      markdown = true,
    },
    nes = {
      enabled = true,
      keymap = {
        accept_and_goto = "<leader>p",
        accept = false,
        dismiss = "<Esc>",
      },
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

    -- hide copilot suggestions when blink menu is open
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
}
