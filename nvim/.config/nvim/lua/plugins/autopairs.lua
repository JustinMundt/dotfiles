return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  dependencies = { 'hrsh7th/nvim-cmp' },
  config = function()
    local autopairs = require('nvim-autopairs')
    autopairs.setup({
      check_ts = true, -- Use treesitter for smarter pairing
      disable_filetype = { 'TelescopePrompt', 'vim' },
    })

    -- Integrate with nvim-cmp (auto-add pairs after completion)
    local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    local cmp = require('cmp')
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
  end,
}
