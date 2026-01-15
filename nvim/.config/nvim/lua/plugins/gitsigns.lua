return {
  'lewis6991/gitsigns.nvim',
  opts = {
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
    on_attach = function(bufnr)
      local gs = require('gitsigns')

      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Navigation (don't override built-in and fugitive keymaps in diff mode)
      map({ 'n', 'v' }, ']c', function()
        if vim.wo.diff then
          return ']c'
        end
        vim.schedule(function()
          gs.next_hunk()
        end)
        return '<Ignore>'
      end, { expr = true, desc = 'Next git hunk' })

      map({ 'n', 'v' }, '[c', function()
        if vim.wo.diff then
          return '[c'
        end
        vim.schedule(function()
          gs.prev_hunk()
        end)
        return '<Ignore>'
      end, { expr = true, desc = 'Previous git hunk' })

      -- Actions (under <leader>g for Git)
      map('n', '<leader>gp', gs.preview_hunk, { desc = 'Git: Preview hunk' })
      map('n', '<leader>gs', gs.stage_hunk, { desc = 'Git: Stage hunk' })
      map('n', '<leader>gr', gs.reset_hunk, { desc = 'Git: Reset hunk' })
      map('v', '<leader>gs', function()
        gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
      end, { desc = 'Git: Stage hunk' })
      map('v', '<leader>gr', function()
        gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
      end, { desc = 'Git: Reset hunk' })
      map('n', '<leader>gS', gs.stage_buffer, { desc = 'Git: Stage buffer' })
      map('n', '<leader>gu', gs.undo_stage_hunk, { desc = 'Git: Undo stage hunk' })
      map('n', '<leader>gR', gs.reset_buffer, { desc = 'Git: Reset buffer' })
      map('n', '<leader>gb', function()
        gs.blame_line({ full = true })
      end, { desc = 'Git: Blame line' })
      map('n', '<leader>gd', gs.diffthis, { desc = 'Git: Diff this' })
      map('n', '<leader>gD', function()
        gs.diffthis('~')
      end, { desc = 'Git: Diff this ~' })
      map('n', '<leader>gtb', gs.toggle_current_line_blame, { desc = 'Git: Toggle line blame' })
      map('n', '<leader>gtd', gs.toggle_deleted, { desc = 'Git: Toggle deleted' })
    end,
  },
}
