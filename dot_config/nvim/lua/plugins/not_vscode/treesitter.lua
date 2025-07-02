return {
  { -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false,
    build = ":TSUpdate",
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)

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
    end,
    opts = {
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
      },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { "ruby" },
      },
      indent = {
        enable = true,
        disable = { "ruby" },
      },
      macthup = {
        enable = true,
        disable = { "c", "ruby" },
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          node_incremental = "v",
          node_decremental = "V",
        },
      },
    },
  },
}
