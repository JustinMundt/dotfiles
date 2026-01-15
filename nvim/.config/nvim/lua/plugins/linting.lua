return {
  'mfussenegger/nvim-lint',
  config = function()
    local lint = require('lint')

    -- Map of linter names to their executable commands
    -- Some linters have different executable names than their nvim-lint names
    local linter_executables = {
      eslint_d = 'eslint_d',
      ruff = 'ruff',
      luacheck = 'luacheck',
      shellcheck = 'shellcheck',
      golangci_lint = 'golangci-lint',
      clippy = 'cargo-clippy',
      yamllint = 'yamllint',
      jsonlint = 'jsonlint',
      markdownlint = 'markdownlint',
      hadolint = 'hadolint',
    }

    -- Helper to check if a linter is available
    local function linter_available(linter)
      local executable = linter_executables[linter] or linter
      return vim.fn.executable(executable) == 1
    end

    -- Filter linters to only include those that are installed
    local function filter_linters(linters)
      local available = {}
      for _, linter in ipairs(linters) do
        if linter_available(linter) then
          table.insert(available, linter)
        end
      end
      return available
    end

    -- Desired linters by filetype
    local desired_linters = {
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

    -- Build filtered linters_by_ft and track missing linters
    local missing_linters = {}
    lint.linters_by_ft = {}

    for ft, linters in pairs(desired_linters) do
      local available = filter_linters(linters)
      if #available > 0 then
        lint.linters_by_ft[ft] = available
      end
      -- Track missing linters
      for _, linter in ipairs(linters) do
        if not linter_available(linter) then
          missing_linters[linter] = true
        end
      end
    end

    -- Show one-time warning for missing linters on startup
    if next(missing_linters) then
      vim.defer_fn(function()
        local missing_list = {}
        for linter in pairs(missing_linters) do
          table.insert(missing_list, linter)
        end
        table.sort(missing_list)
        vim.notify(
          'nvim-lint: Missing linters (will be skipped): ' .. table.concat(missing_list, ', '),
          vim.log.levels.WARN
        )
      end, 1000) -- Delay 1 second so it doesn't get buried in startup messages
    end

    local lint_group = vim.api.nvim_create_augroup('LintOnSave', { clear = true })
    vim.api.nvim_create_autocmd('BufWritePost', {
      group = lint_group,
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
