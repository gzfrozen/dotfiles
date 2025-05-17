return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup({})
      vim.keymap.set("n", "<leader>sh", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end)
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
}
