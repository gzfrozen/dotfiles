return {
  "andymass/vim-matchup",
  lazy = false,
  config = function()
    -- may set any options here
    vim.g.matchup_matchparen_offscreen = { method = "popup" }
  end,
}
