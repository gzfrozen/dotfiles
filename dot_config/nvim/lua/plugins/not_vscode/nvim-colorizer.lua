return {
  {
    "catgoose/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      options = {
        parsers = {
          css = true,
          css_fn = true,
          tailwind = {
            enable = true,
            lsp = true,
            update_names = true,
          },
        },
      },
      filetypes = {
        "css",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "html",
      },
    },
  },
}
