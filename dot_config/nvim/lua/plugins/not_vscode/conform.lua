local function ts_organize_imports(bufnr)
  if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
    return
  end

  if vim.g.disable_orgnize_import or vim.b[bufnr].disable_orgnize_import then
    return
  end

  local client = vim.lsp.get_clients({ name = "ts_ls", bufnr = bufnr })[1]

  if not client then
    return
  end

  client:request("workspace/executeCommand", {
    command = "_typescript.organizeImports",
    arguments = { vim.api.nvim_buf_get_name(bufnr) },
  })
end

local function go_organize_imports(bufnr)
  local client = vim.lsp.get_clients({ name = "gopls", bufnr = bufnr })[1]
  if not client then
    return
  end

  -- Build params explicitly so we don't inject `context` into a typed table.
  local params = {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
    range = {
      start = { line = 0, character = 0 },
      ["end"] = { line = 0, character = 0 },
    },
    context = { only = { "source.organizeImports" }, diagnostics = {} },
  }

  client:request("textDocument/codeAction", params, function(err, result)
    if err or not result then
      return
    end
    for _, action in pairs(result) do
      if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
      elseif action.command then
        client:exec_cmd(action.command, { bufnr = bufnr })
      end
    end
  end, bufnr)
end

local function organize_imports(bufnr)
  ts_organize_imports(bufnr)
  go_organize_imports(bufnr)
end

return {
  { -- Autoformat
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        return {
          timeout_ms = 1000,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
          callback = organize_imports(bufnr),
        }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        -- Conform can also run multiple formatters sequentially
        python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
        javascript = { "eslint_d", "prettierd" },
        javascriptreact = { "eslint_d", "prettierd" },
        typescript = { "eslint_d", "prettierd" },
        typescriptreact = { "eslint_d", "prettierd" },
        json = { "prettierd" },
        html = { "prettierd" },
        css = { "prettierd" },
        rust = { "rustfmt" },
        fish = { "fish_indent" },
        bash = { "shfmt" },
        go = { lsp_format = "fallback" },
      },
    },
    keys = {
      {
        "<leader><leader>f",
        function()
          require("conform").format({
            async = true,
            lsp_fallback = true,
            callback = organize_imports(vim.api.nvim_get_current_buf()),
          })
        end,
        mode = "n",
        desc = "[F]ormat",
      },
    },
    init = function()
      -- If you want the formatexpr, here is the place to set it
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
      vim.g.disable_orgnize_import = true
      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          -- FormatDisable! will disable formatting just for this buffer
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
        vim.notify("Autoformat on save disabled.", vim.log.levels.INFO, { title = "conform.nvim" })
      end, {
        desc = "Disable autoformat-on-save",
        bang = true,
      })
      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
        vim.notify("Autoformat on save enabled.", vim.log.levels.INFO, { title = "conform.nvim" })
      end, {
        desc = "Re-enable autoformat-on-save",
      })
      vim.api.nvim_create_user_command("OrgnizeImportsDisable", function(args)
        if args.bang then
          -- FormatDisable! will disable formatting just for this buffer
          vim.b.disable_orgnize_import = true
        else
          vim.g.disable_orgnize_import = true
        end
        vim.notify("Orgnize import disabled.", vim.log.levels.INFO, { title = "conform.nvim" })
      end, {
        desc = "Disable orgnize imports",
        bang = true,
      })
      vim.api.nvim_create_user_command("OrgnizeImportsEnable", function()
        vim.b.disable_orgnize_import = false
        vim.g.disable_orgnize_import = false
        vim.notify("Orgnize import enabled.", vim.log.levels.INFO, { title = "conform.nvim" })
      end, {
        desc = "Re-enable orgnize imports",
      })
    end,
  },
}
