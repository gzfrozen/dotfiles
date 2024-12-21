return {
  "huggingface/llm.nvim",
  enabled = false,
  event = "VeryLazy",
  opts = {
    api_token = nil, -- cf Install paragraph
    model = "starcoder2", -- the model ID, behavior depends on backend
    backend = "ollama", -- backend ID, "huggingface" | "ollama" | "openai" | "tgi"
    url = "http://localhost:11434", -- the http url of the backend
    tokens_to_clear = { "<|endoftext|>" }, -- tokens to remove from the model's output
    -- parameters that are added to the request body, values are arbitrary, you can set any field:value pair here it will be passed as is to the backend
    request_body = {
      parameters = {
        temperature = 0.2,
        top_p = 0.95,
      },
    },
    -- set this if the model supports fill in the middle
    fim = {
      enabled = true,
      prefix = "<fim_prefix>",
      middle = "<fim_middle>",
      suffix = "<fim_suffix>",
    },
    debounce_ms = 200,
    accept_keymap = "<C-/>",
    dismiss_keymap = "<C-n>",
    lsp = {
      bin_path = vim.api.nvim_call_function("stdpath", { "data" }) .. "/mason/bin/llm-ls",
    },
    tokenizer = {
      repository = "bigcode/starcoder2-3b",
      api_token = nil,
    }, -- cf Tokenizer paragraph
    context_window = 1024, -- max number of tokens for the context window
    enable_suggestions_on_startup = true,
    enable_suggestions_on_files = "*", -- pattern matching syntax to enable suggestions on specific files, either a string or a list of strings
  },
}
