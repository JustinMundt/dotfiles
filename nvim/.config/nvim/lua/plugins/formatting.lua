return {
  'stevearc/conform.nvim',
  config = function()
    local conform = require('conform')

    -- Helper to check if a formatter is available
    local function formatter_available(formatter)
      return vim.fn.executable(formatter) == 1
    end

    -- Filter formatters to only include those that are installed
    -- For lists with fallbacks (e.g., prettierd -> prettier), keep the first available
    local function filter_formatters(formatters)
      local available = {}
      for _, formatter in ipairs(formatters) do
        if formatter_available(formatter) then
          table.insert(available, formatter)
        end
      end
      return available
    end

    -- Desired formatters by filetype
    local desired_formatters = {
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
    }

    -- Build filtered formatters_by_ft and track missing formatters
    local missing_formatters = {}
    local formatters_by_ft = {}

    for ft, formatters in pairs(desired_formatters) do
      local available = filter_formatters(formatters)
      if #available > 0 then
        formatters_by_ft[ft] = available
      end
      -- Track missing formatters (only if ALL formatters for a filetype are missing)
      if #available == 0 then
        for _, formatter in ipairs(formatters) do
          missing_formatters[formatter] = true
        end
      end
    end

    -- Show one-time warning for missing formatters on startup
    if next(missing_formatters) then
      vim.defer_fn(function()
        local missing_list = {}
        for formatter in pairs(missing_formatters) do
          table.insert(missing_list, formatter)
        end
        table.sort(missing_list)
        vim.notify(
          'conform.nvim: Missing formatters (will be skipped): ' .. table.concat(missing_list, ', '),
          vim.log.levels.WARN
        )
      end, 1000) -- Delay 1 second so it doesn't get buried in startup messages
    end

    conform.setup({
      format_on_save = function(_)
        return {
          timeout_ms = 500,
          -- Don't fall back to LSP - prevents "no matching language servers" error
          lsp_fallback = false,
        }
      end,
      formatters_by_ft = formatters_by_ft,
    })
  end,
}
