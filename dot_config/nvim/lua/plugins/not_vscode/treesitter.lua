return {
  { -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local filetypes = {
        "bash",
        "c",
        "html",
        "lua",
        "markdown",
        "vim",
        "vimdoc",
        "python",
        "c_sharp",
        "css",
        "diff",
        "dockerfile",
        "dot",
        "gitcommit",
        "gitignore",
        "go",
        "helm",
        "javascript",
        "json",
        "jsdoc",
        "latex",
        "regex",
        "ruby",
        "rust",
        "sql",
        "ssh_config",
        "terraform",
        "toml",
        "yaml",
        "typescript",
        "tsx",
        "xml",
        "http",
        "graphql",
        "comment",
        "prisma",
        "nix",
      }

      vim.api.nvim_create_autocmd("FileType", {
        desc = "Enable file highlight",
        pattern = filetypes,
        group = vim.api.nvim_create_augroup("treesitter-highlight-start", {
          clear = true,
        }),
        callback = function()
          vim.treesitter.start()
        end,
      })
    end,
  },
}
