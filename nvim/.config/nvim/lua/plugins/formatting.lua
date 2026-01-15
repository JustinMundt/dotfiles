return {
  'stevearc/conform.nvim',
  opts = {
    format_on_save = function(_)
      return {
        timeout_ms = 500,
        lsp_fallback = true,
      }
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'black' },
      javascript = { 'prettierd', 'prettier' },
      javascriptreact = { 'prettierd', 'prettier' },
      typescript = { 'prettierd', 'prettier' },
      typescriptreact = { 'prettierd', 'prettier' },
      json = { 'prettierd', 'prettier' },
      yaml = { 'prettierd', 'prettier' },
      html = { 'prettierd', 'prettier' },
      css = { 'prettierd', 'prettier' },
      markdown = { 'prettierd', 'prettier' },
      sh = { 'shfmt' },
      bash = { 'shfmt' },
      go = { 'gofumpt', 'gofmt' },
      rust = { 'rustfmt' },
      c = { 'clang-format' },
      cpp = { 'clang-format' },
    },
  },
}
