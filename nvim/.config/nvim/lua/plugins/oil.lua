return {
  'stevearc/oil.nvim',
  config = function()
    require('oil').setup({
      float = {
        border = 'rounded',
        max_width = 100,
        max_height = 50,
        min_width = 50,
        min_height = 10,
        win_options = {
          winblend = 10,
        },
      },
      view_options = {
        show_hidden = true,
      },
      default_file_explorer = true,
      keymaps = {
        ['q'] = 'actions.close',
      },
    })

    vim.keymap.set('n', '<leader>o', function()
      require('oil').open_float()
    end, { desc = 'Open Oil File Explorer' })
  end,
}
