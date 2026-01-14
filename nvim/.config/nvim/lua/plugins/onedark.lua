return {
  'navarasu/onedark.nvim',
  priority = 1000,
  config = function()
    vim.cmd.colorscheme('onedark')

    -- Highlighting for terminal mode
    vim.cmd('highlight! TermCursorNC guibg=red guifg=white ctermbg=1 ctermfg=15')

    -- Re-apply on colorscheme change
    vim.api.nvim_create_autocmd('ColorScheme', {
      pattern = '*',
      callback = function()
        vim.cmd('highlight! TermCursorNC guibg=red guifg=white ctermbg=1 ctermfg=15')
      end,
    })
  end,
}
