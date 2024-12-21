return {
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    opts = {
      signs = {
        add = {
          text = "+",
        },
        change = {
          text = "~",
        },
        delete = {
          text = "_",
        },
        topdelete = {
          text = "‾",
        },
        changedelete = {
          text = "~",
        },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]c", function()
          if vim.wo.diff then
            return "]c"
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return "<Ignore>"
        end, { expr = true, desc = "Next Hunk" })

        map("n", "[c", function()
          if vim.wo.diff then
            return "[c"
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return "<Ignore>"
        end, { expr = true, desc = "Previous Hunk" })

        -- Actions
        map("n", "<leader>hs", gs.stage_hunk, { desc = "[S]tage [H]unk" })
        map("n", "<leader>hr", gs.reset_hunk, { desc = "[R]eset [H]unk" })
        map("v", "<leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "[S]tage [H]unk" })
        map("v", "<leader>hr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "[R]eset [H]unk" })
        map("n", "<leader>hS", gs.stage_buffer, { desc = "[S]tage Buffer" })
        map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "[U]ndo Last Stage" })
        map("n", "<leader>hR", gs.reset_buffer, { desc = "[R]eset [B]uffer" })
        map("n", "<leader>hp", gs.preview_hunk, { desc = "[P]review [H]unk" })
        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, { desc = "[B]lame Line" })
        map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "[T]oggle Line [B]lame" })
        map("n", "<leader>hd", gs.diffthis, { desc = "Show [D]iff" })
        map("n", "<leader>hD", function()
          gs.diffthis("~")
        end, { desc = "Show [D]iff With Last Commit" })
        map("n", "<leader>td", gs.toggle_deleted, { desc = "[T]oggle Deleted" })

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Git [H]unk" })
      end,
    },
  },
}
