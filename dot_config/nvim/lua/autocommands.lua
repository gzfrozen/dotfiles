vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", {
    clear = true,
  }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Enable certain file types heightlights",
  pattern = "prisma",
  group = vim.api.nvim_create_augroup("prisma-highlight-start", {
    clear = true,
  }),
  callback = function(args)
    vim.treesitter.start(args.buf, "prisma")
    -- vim.bo[args.buf].syntax = "on" -- only if additional legacy syntax is needed
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Enable certain file types heightlights",
  pattern = "markdown",
  group = vim.api.nvim_create_augroup("markdown-highlight-start", {
    clear = true,
  }),
  callback = function(args)
    vim.treesitter.start(args.buf, "markdown")
    -- vim.bo[args.buf].syntax = "on" -- only if additional legacy syntax is needed
  end,
})
