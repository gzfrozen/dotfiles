return {
  {
    "catgoose/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      filetypes = {
        "css",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "html",
      },
      user_default_options = { css = true, tailwind = "both", tailwind_opts = {
        update_names = true,
      } },
    },
  },
}
