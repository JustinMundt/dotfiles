return {
  'mfussenegger/nvim-lint',
  config = function()
    local lint = require('lint')

    lint.linters_by_ft = {
      javascript = { 'eslint_d' },
      javascriptreact = { 'eslint_d' },
      typescript = { 'eslint_d' },
      typescriptreact = { 'eslint_d' },
      python = { 'ruff' },
      lua = { 'luacheck' },
      sh = { 'shellcheck' },
      bash = { 'shellcheck' },
      go = { 'golangci_lint' },
      rust = { 'clippy' },
      yaml = { 'yamllint' },
      json = { 'jsonlint' },
      markdown = { 'markdownlint' },
      dockerfile = { 'hadolint' },
    }

    local lint_group = vim.api.nvim_create_augroup('LintOnSave', { clear = true })
    vim.api.nvim_create_autocmd('BufWritePost', {
      group = lint_group,
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
