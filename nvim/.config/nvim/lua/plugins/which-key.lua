return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  opts = {},
  config = function()
    local wk = require('which-key')
    wk.setup({})
    wk.add({
      -- Groups
      { '<leader>c', group = '[C]ode' },
      { '<leader>d', group = '[D]ebug' },
      { '<leader>f', group = '[F]ind' },
      { '<leader>g', group = '[G]it' },
      { '<leader>gt', group = '[G]it [T]oggle' },
      { '<leader>h', group = '[H]arpoon' },
      { '<leader>r', group = '[R]ename' },
      { '<leader>s', group = '[S]earch' },
      { '<leader>w', group = '[W]orkspace' },

      -- Standalone keymaps (for discoverability)
      { '<leader><space>', desc = 'Find buffers' },
      { '<leader>/', desc = 'Fuzzy find in buffer' },
      { '<leader>?', desc = 'Recent files' },
      { '<leader>a', desc = 'Swap parameter next' },
      { '<leader>A', desc = 'Swap parameter prev' },
      { '<leader>b', desc = 'Buffer picker' },
      { '<leader>D', desc = 'Type definition' },
      { '<leader>e', desc = 'Floating diagnostic' },
      { '<leader>m', desc = 'Marks picker' },
      { '<leader>o', desc = 'Oil file explorer' },
      { '<leader>p', desc = 'Paste (keep register)' },
      { '<leader>q', desc = 'Diagnostics list' },
    })
  end,
}
