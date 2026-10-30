local function biome_available(bufnr)
  return require("conform").get_formatter_info("biome", bufnr).available
end

local function javascript_formatters(bufnr)
  if biome_available(bufnr) then
    return { "biome", lsp_format = "never" }
  end

  return { "eslint_d", "prettierd", lsp_format = "never" }
end

local web_formatters = {
  "biome",
  "prettierd",
  stop_after_first = true,
  lsp_format = "never",
}

local function ts_organize_imports(bufnr)
  if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
    return
  end

  if vim.g.disable_orgnize_import or vim.b[bufnr].disable_orgnize_import then
    return
  end

  local client = vim.lsp.get_clients({ name = "ts_ls", bufnr = bufnr })[1]

  if not client or biome_available(bufnr) then
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

local function after_format(bufnr)
  return function(err)
    if not err and vim.api.nvim_buf_is_valid(bufnr) then
      organize_imports(bufnr)
    end
  end
end

return {
  { -- Autoformat
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      notify_on_error = false,
      default_format_opts = {
        lsp_format = "fallback",
      },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        -- Disable LSP formatting on save for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        return {
          bufnr = bufnr,
          timeout_ms = 1000,
          lsp_format = disable_filetypes[vim.bo[bufnr].filetype] and "never" or nil,
        },
          after_format(bufnr)
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        -- Conform can also run multiple formatters sequentially
        python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
        -- Biome is exclusive; otherwise preserve ESLint -> Prettier.
        javascript = javascript_formatters,
        javascriptreact = javascript_formatters,
        typescript = javascript_formatters,
        typescriptreact = javascript_formatters,
        json = web_formatters,
        jsonc = web_formatters,
        html = web_formatters,
        css = web_formatters,
        rust = { "rustfmt" },
        fish = { "fish_indent" },
        bash = { "shfmt" },
        go = { lsp_format = "fallback" },
      },
      formatters = {
        biome = {
          -- Require the config directory detected by Conform's built-in Biome formatter.
          require_cwd = true,
        },
      },
    },
    keys = {
      {
        "<leader><leader>f",
        function()
          local bufnr = vim.api.nvim_get_current_buf()
          require("conform").format({
            bufnr = bufnr,
            async = true,
          }, after_format(bufnr))
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
