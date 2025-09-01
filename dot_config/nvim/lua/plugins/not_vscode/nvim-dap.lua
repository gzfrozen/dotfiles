return {
  "mfussenegger/nvim-dap",
  event = "VeryLazy",
  dependencies = {
    "mfussenegger/nvim-dap-python",
    { "nvim-dap-virtual-text", opts = {} },
  },
  config = function()
    local dap = require("dap")

    vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "", linehl = "", numhl = "" })
    vim.fn.sign_define("DapStopped", { text = "👉", texthl = "", linehl = "", numhl = "" })

    vim.keymap.set("n", "<Leader>dt", dap.toggle_breakpoint, { desc = "[T]oggle breakporint" })
    vim.keymap.set("n", "<Leader>dc", dap.continue, { desc = "[C]ontinue" })
    vim.keymap.set("n", "<Leader>dx", dap.terminate, { desc = "E[x]it Debug" })
    vim.keymap.set({ "n", "x" }, "<Leader>de", function()
      require("dapui").eval(nil, { enter = true })
    end, { desc = "[E]val currunt value" })

    dap.adapters["pwa-node"] = {
      type = "server",
      host = "localhost",
      port = "${port}",
      executable = {
        command = "js-debug-adapter",
        args = { "${port}" },
      },
    }
    for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
      dap.configurations[language] = {
        {
          name = "Next.js: default debug server",
          type = "pwa-node",
          request = "launch",
          program = "${workspaceFolder}/node_modules/next/dist/bin/next",
          runtimeArgs = { "--inspect" },
          skipFiles = { "<node_internals>/**" },
          serverReadyAction = {
            action = "debugWithChrome",
            killOnServerStop = true,
            pattern = "- Local:.+(https?://.+)",
            uriFormat = "%s",
            webRoot = "${workspaceFolder}",
          },
          cwd = "${workspaceFolder}",
        },
      }
    end

    require("dap-python").setup("python")
  end,
}
