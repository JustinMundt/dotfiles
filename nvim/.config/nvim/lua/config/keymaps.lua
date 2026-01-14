-- Keymaps for better default experience
-- See `:help vim.keymap.set()`

local keymap = vim.keymap.set

-- Escape mappings
keymap('i', '<CapsLock>', '<Esc>', { noremap = true, silent = true })

-- Terminal mode mappings
keymap('t', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true })
keymap('t', [[<C-v><Esc>]], '<Esc>', { noremap = true, silent = true })

-- Disable space in normal/visual mode (leader key)
keymap({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
keymap('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
keymap('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
keymap('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
keymap('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
keymap('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
keymap('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- Paste without yanking (greatest remap ever)
keymap('x', '<leader>p', '"_dP')
