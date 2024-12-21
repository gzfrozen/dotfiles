return {
  { -- Fuzzy Finder (files, lsp, etc)
    "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        "nvim-telescope/telescope-fzf-native.nvim",

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = "make",

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
      { "nvim-telescope/telescope-ui-select.nvim" }, -- Useful for getting pretty icons, but requires a Nerd Font.
      {
        "nvim-tree/nvim-web-devicons",
        enabled = vim.g.have_nerd_font,
      },
      { "debugloop/telescope-undo.nvim" },
      {
        "gzfrozen/harpoon",
        branch = "harpoon2",
        config = function()
          local harpoon = require("harpoon")
          harpoon:setup({})
          vim.keymap.set("n", "gh", function()
            harpoon:list():add()
          end, { desc = "Add file to [H]arpoon" })
          vim.keymap.set("n", "<Tab>", function()
            harpoon:list():next({ ui_nav_wrap = true })
          end, { desc = "[T]oggle Harpoon" })
          vim.keymap.set("n", "<S-Tab>", function()
            harpoon:list():prev({ ui_nav_wrap = true })
          end, { desc = "[T]oggle Harpoon reverse" })
        end,
      },
    },
    config = function()
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      -- local telescope = require("telescope")

      -- Config about hidden files
      local telescopeConfig = require("telescope.config")

      -- Clone the default Telescope configuration
      local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

      -- I want to search in hidden/dot files.
      table.insert(vimgrep_arguments, "--hidden")
      -- I don't want to search in the `.git` directory.
      table.insert(vimgrep_arguments, "--glob")
      table.insert(vimgrep_arguments, "!**/.git/*")

      require("telescope").setup({
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        -- defaults = {
        --   mappings = {
        --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        --   },
        -- },
        -- pickers = {}
        extensions = {
          ["ui-select"] = { require("telescope.themes").get_dropdown({ initial_mode = "normal" }) },
          undo = { initial_mode = "normal" },
        },
        defaults = {
          preview = true,
          layout_config = {
            horizontal = {
              preview_cutoff = 0,
            },
          },
          vimgrep_arguments = vimgrep_arguments,
        },
        pickers = {
          find_files = {
            find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
          },
          buffers = {
            mappings = {
              n = {
                ["d"] = "delete_buffer",
              },
              i = {
                ["<c-d>"] = "delete_buffer",
              },
            },
            initial_mode = "normal",
          },
        },
      })

      -- Enable Telescope extensions if they are installed
      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")
      pcall(require("telescope").load_extension, "undo")
      pcall(require("telescope").load_extension, "rest")
      pcall(require("telescope").load_extension, "noice")
      pcall(require("telescope").load_extension, "session-lens")

      -- Create Harpoon picker
      local conf = require("telescope.config").values
      local harpoon = require("harpoon")

      local function toggle_telescope(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(file_paths, item.value)
        end

        local make_finder = function()
          local paths = {}
          for _, item in ipairs(harpoon_files.items) do
            table.insert(paths, item.value)
          end

          return require("telescope.finders").new_table({
            results = paths,
          })
        end

        local remove_at = function(prompt_buffer_number)
          local state = require("telescope.actions.state")
          local selected_entry = state.get_selected_entry()
          local current_picker = state.get_current_picker(prompt_buffer_number)

          harpoon:list():remove_at(selected_entry.index)
          current_picker:refresh(make_finder())
        end

        require("telescope.pickers")
          .new({ initial_mode = "normal" }, {
            prompt_title = "Harpoon",
            finder = make_finder(),
            previewer = conf.file_previewer({}),
            sorter = conf.generic_sorter({}),
            attach_mappings = function(_, map)
              map(
                "n",
                "d", -- your mapping here
                remove_at
              )
              map(
                "i",
                "<C-d>", -- your mapping here
                remove_at
              )
              return true
            end,
          })
          :find()
      end

      -- See `:help telescope.builtin`
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>sH", builtin.help_tags, {
        desc = "[S]earch [H]elp",
      })
      vim.keymap.set("n", "<leader>sk", builtin.keymaps, {
        desc = "[S]earch [K]eymaps",
      })
      vim.keymap.set("n", "<leader>sf", builtin.find_files, {
        desc = "[S]earch [F]iles",
      })
      vim.keymap.set("n", "<leader>st", builtin.git_status, {
        desc = "Git S[t]atus",
      })
      vim.keymap.set("n", "<leader>ss", builtin.builtin, {
        desc = "[S]earch [S]elect Telescope",
      })
      vim.keymap.set("n", "<leader>sw", builtin.grep_string, {
        desc = "[S]earch current [W]ord",
      })
      vim.keymap.set("n", "<leader>sg", builtin.live_grep, {
        desc = "[S]earch by [G]rep",
      })
      vim.keymap.set("n", "<leader>sd", builtin.diagnostics, {
        desc = "[S]earch [D]iagnostics",
      })
      vim.keymap.set("n", "<leader>sr", builtin.resume, {
        desc = "[S]earch [R]esume",
      })
      vim.keymap.set("n", "<leader>s.", builtin.oldfiles, {
        desc = '[S]earch Recent Files ("." for repeat)',
      })
      vim.keymap.set("n", "<leader><leader>", builtin.buffers, {
        desc = "[ ] Find existing buffers",
      })
      vim.keymap.set("n", "<leader>su", "<CMD>Telescope undo<CR>", {
        desc = "[S]earch [U]ndo",
      })
      vim.keymap.set("n", "<leader>sh", function()
        toggle_telescope(require("harpoon"):list())
      end, { desc = "[S]earch Files added to [h]arpoon" })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set("n", "<leader>/", function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end, {
        desc = "[/] Fuzzily search in current buffer",
      })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set("n", "<leader>s/", function()
        builtin.live_grep({
          grep_open_files = true,
          prompt_title = "Live Grep in Open Files",
        })
      end, {
        desc = "[S]earch [/] in Open Files",
      })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set("n", "<leader>sn", function()
        builtin.find_files({
          cwd = vim.fn.stdpath("config"),
        })
      end, {
        desc = "[S]earch [N]eovim files",
      })
      -- Rest client environment variables picker
      vim.keymap.set("n", "<leader>re", function()
        require("telescope").extensions.rest.select_env()
      end, {
        desc = "Select [r]est client [e]nvironment variables",
      })
    end,
  },
}
