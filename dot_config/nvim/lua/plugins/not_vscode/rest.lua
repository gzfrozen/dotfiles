return {
  "rest-nvim/rest.nvim",
  ft = "http",
  dependencies = { "luarocks.nvim" },
  config = function()
    require("rest-nvim").setup()
  end,
  keys = {
    {
      "<leader>rr",
      "<cmd>Rest run<cr>",
      mode = "n",
      desc = "[R]un [r]equest under the cursor",
    },
    {
      "<leader>rl",
      "<cmd>Rest run last<cr>",
      mode = "n",
      desc = "Re-[r]un [l]atest request",
    },
  },
}
