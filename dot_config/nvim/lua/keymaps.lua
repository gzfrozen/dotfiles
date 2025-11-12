vim.keymap.set("i", "jj", "<ESC>")
vim.keymap.set("i", "っj", "<ESC>")

vim.keymap.set("n", "<C-i>", "<C-i>")

vim.keymap.set({ "n", "x" }, "j", "gj")
vim.keymap.set({ "n", "x" }, "k", "gk")

vim.keymap.set({ "n", "x" }, "H", "^", {
  desc = "Move cursor to the start of the line",
})
vim.keymap.set({ "n", "x" }, "L", "$", {
  desc = "Move cursor to the end of the line",
})
vim.keymap.set("x", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("x", "K", ":m '<-2<CR>gv=gv")

if not vim.g.vscode then
  vim.keymap.set("n", "<esc>", function()
    vim.cmd("Noice dismiss")
    vim.cmd.noh()
  end)

  -- Diagnostic keymaps
  vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump({ count = 1, float = true })
  end, {
    desc = "Go to previous [D]iagnostic message",
  })
  vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump({ count = -1, float = true })
  end, {
    desc = "Go to next [D]iagnostic message",
  })
  vim.keymap.set("n", "<leader>D", vim.diagnostic.open_float, {
    desc = "Show [D]iagnostic Error messages",
  })
  vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, {
    desc = "Open diagnostic [Q]uickfix list",
  })

  -- Exit terminal mode in the builtin terminal with a shortcut
  vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", {
    desc = "Exit terminal mode",
  })

  --  Use CTRL+<hjkl> to switch between windows
  vim.keymap.set("n", "<C-h>", "<C-w><C-h>", {
    desc = "Move focus to the left window",
  })
  vim.keymap.set("n", "<C-l>", "<C-w><C-l>", {
    desc = "Move focus to the right window",
  })
  vim.keymap.set("n", "<C-j>", "<C-w><C-j>", {
    desc = "Move focus to the lower window",
  })
  vim.keymap.set("n", "<C-k>", "<C-w><C-k>", {
    desc = "Move focus to the upper window",
  })
  vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w><C-h>", {
    desc = "Move focus to the left window from terminal",
  })
  vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w><C-l>", {
    desc = "Move focus to the right window from terminal",
  })
  vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w><C-j>", {
    desc = "Move focus to the lower window from terminal",
  })
  vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w><C-k>", {
    desc = "Move focus to the upper window from terminal",
  })
end

if vim.g.vscode then
  vim.keymap.set("n", "<esc>", function()
    vim.cmd.noh()
  end)

  local vscode = require("vscode-neovim")
  vim.keymap.set({ "n", "x" }, "<Tab>", function()
    vscode.action("workbench.action.nextEditor")
  end)
  vim.keymap.set({ "n", "x" }, "<S-Tab>", function()
    vscode.action("workbench.action.previousEditor")
  end)
  vim.keymap.set({ "n", "x" }, "gb", function()
    vscode.action("workbench.action.navigateBack")
  end)
  vim.keymap.set({ "n", "x" }, "gB", function()
    vscode.action("workbench.action.navigateForward")
  end)
  vim.keymap.set("x", "v", function()
    vscode.action("editor.action.smartSelect.expand")
  end)
  vim.keymap.set("x", "V", function()
    vscode.action("editor.action.smartSelect.shrink")
  end)
  vim.keymap.set({ "n", "x" }, "<leader>sf", function()
    vscode.action("workbench.action.quickOpen")
  end)
  vim.keymap.set({ "n", "x" }, "<leader>tf", function()
    vscode.action("workbench.explorer.fileView.focus")
  end)
  vim.keymap.set({ "n", "x" }, "<leader>tg", function()
    vscode.action("workbench.scm.focus")
  end)
  vim.keymap.set({ "n", "x" }, "<leader>b", function()
    vscode.action("bookmarks.list")
  end)
  vim.keymap.set({ "n", "x" }, "<leader>m", function()
    vscode.action("bookmarks.toggle")
  end)
  vim.keymap.set({ "n", "x" }, "''", function()
    vscode.action("bookmarks.jumpToNext")
  end)
  vim.keymap.set({ "n", "x" }, "<leader>n", function()
    vscode.action("extension.advancedNewFile")
  end)
  --  Use CTRL+<hjkl> to switch between windows
  vim.keymap.set("n", "<C-h>", function()
    vscode.action("workbench.action.navigateLeft")
  end, {
    desc = "Move focus to the left window",
  })
  vim.keymap.set("n", "<C-l>", function()
    vscode.action("workbench.action.navigateRight")
  end, {
    desc = "Move focus to the right window",
  })
  vim.keymap.set("n", "<C-j>", function()
    vscode.action("workbench.action.navigateDown")
  end, {
    desc = "Move focus to the lower window",
  })
  vim.keymap.set("n", "<C-k>", function()
    vscode.action("workbench.action.navigateUp")
  end, {
    desc = "Move focus to the upper window",
  })
end
