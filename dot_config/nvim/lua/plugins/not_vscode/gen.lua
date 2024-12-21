return {
  "David-Kunz/gen.nvim",
  config = function()
    local gen = require("gen")
    gen.setup({
      model = "llama3.1",
      show_model = true,
    })
    gen.prompts["Explain_Code"] = {
      prompt = "Explain the meaning of following code:\n```$filetype\n$text\n```",
      replace = false,
    }
  end,
  keys = {
    {
      "<leader>gs",
      ":Gen<CR>",
      mode = { "n", "x" },
      desc = "[S]tart [G]enrate with llm",
    },
    {
      "<leader>gc",
      ":Gen Chat<CR>",
      mode = { "n", "x" },
      desc = "[C]ontinue [C]hat with llm",
    },
  },
}
