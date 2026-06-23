return {
  "romus204/tree-sitter-manager.nvim",
  config = function()
    require("tree-sitter-manager").setup({
      -- Default Options
      ensure_installed = {
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
      }, -- list of parsers to install at the start of a neovim session. If set to "all", install all parsers.
      -- border = nil, -- border style for the window (e.g. "rounded", "single"), if nil, use the default border style defined by 'vim.o.winborder'. See :h 'winborder' for more info.
      -- auto_install = false, -- if enabled, install missing parsers when editing a new file
      -- highlight = true, -- treesitter highlighting is enabled by default
      -- languages = {}, -- override or add new parser sources
    })
  end,
}
