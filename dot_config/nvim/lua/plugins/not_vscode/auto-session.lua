return {
  "rmagatti/auto-session",
  lazy = false,
  keys = {
    -- Will use Telescope if installed or a vim.ui.select picker otherwise
    { "<leader>sS", "<cmd>SessionSearch<CR>", desc = "Session search" },
  },

  ---enables autocomplete for opts
  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    suppress_dirs = { "~/", "~/repos", "~/Downloads", "/" },
    bypass_save_filetypes = { "dashboard" },
    cwd_change_handling = true,
    post_cwd_changed_cmds = {
      function() -- example refreshing the lualine status line _after_ the cwd changes
        require("lualine").refresh() -- refresh lualine so the new session name is displayed in the status bar
      end,
    },
    session_lens = {
      load_on_setup = true,
      picker_opts = { border = true },
    },
  },
}
