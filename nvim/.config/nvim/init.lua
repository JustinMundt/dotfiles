--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================

Kickstart.nvim is *not* a distribution.

Kickstart.nvim is a template for your own configuration.
The goal is that you can read every line of code, top-to-bottom, understand
what your configuration is doing, and modify it to suit your needs.

Once you've done that, you should start exploring, configuring and tinkering to
explore Neovim!

If you don't know anything about Lua, I recommend taking some time to read through
a guide. One possible example:
- https://learnxinyminutes.com/docs/lua/


And then you can explore or search through `:help lua-guide`
- https://neovim.io/doc/user/lua-guide.html


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]


vim.wo.relativenumber = true
-- Set <space> as the leader key
-- test row
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '


-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
-- print("Lazypath = ", lazypath)
if not vim.loop.fs_stat(lazypath) then
vim.fn.system {
  'git',
  'clone',
  '--filter=blob:none',
  'https://github.com/folke/lazy.nvim.git',
  '--branch=stable', -- latest stable release
  lazypath,
}
end
vim.opt.rtp:prepend(lazypath)

-- [Configure plugins]
-- NOTE: Here is "where" you install your plugins.
--  You can ( configure ) plugins using the `config` key.
--  You can configure plugins "using" the `config` key.
--  You can "configure" "plugins" using the `config` key.
--  You can "confiugureu" plugins using the `config` key.
--  You can configure plugins using "the" `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
-- NOTE: First, some plugins that don't require any configuration
"neovim/nvim-lspconfig",
  {
"chrisbra/csv.vim",
    ft = {"csv", "tsv" },
    init = function()
    vim.g.csv_delim = ","
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "csv",
        callback = function()
          vim.cmd("CSVArrange")
        end,
      })
    end,
  },
"pmizio/typescript-tools.nvim",
dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
opts = {
  settings = {
  tsserver_file_preferences = {
  includeInlayParameterNameHints = "all",
  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
  incldueCompletionsForModuleExports = true,
  },
  tsserver_format_options = {
    indentSize = 2,
    tabSize = 2,
  },
  },
},
config = function(_, opts)
  require("typescript-tools").setup(opts)
end,


-- Git related plugins
'tpope/vim-fugitive',
'tpope/vim-rhubarb',
'tpope/vim-commentary',
'ThePrimeagen/harpoon',
-- Detect tabstop and shiftwidth automatically
'tpope/vim-sleuth',
-- For sql dadbod
"tpope/vim-dadbod",
 "kristijanhusak/vim-dadbod-ui",
 "kristijanhusak/vim-dadbod-completion",
-- debugger
-- "mfussenegger/nvim-dap",
--   dependencies = {
-- "rcarriga/nvim-dap-ui",
--   },
--   config = function()
--     local dap = require("dap")
--     local dapui = require("dapui")
--     dapui.setup()
--     require("nvim-dap-virtual-text").setup()

-- 'mattn/emmet-vim',

-- NOTE: This is where your plugins related to LSP can be installed.
--  The configuration is done below. Search for lspconfig to find it below.
{
  -- LSP Configuration & Plugins
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs to stdpath for neovim
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',

    -- Useful status updates for LSP
    -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
    { 'j-hui/fidget.nvim', opts = {} },

    -- Additional lua configuration, makes nvim stuff amazing!
    'folke/neodev.nvim',
  },
},

{
  -- Autocompletion
  'hrsh7th/nvim-cmp',
  dependencies = {
    -- Snippet Engine & its associated nvim-cmp source
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',

    -- Adds LSP completion capabilities
    'hrsh7th/cmp-nvim-lsp',

    -- Adds a number of user-friendly snippets
    'rafamadriz/friendly-snippets',
  },
},

-- Useful plugin to show you pending keybinds.
{ 'folke/which-key.nvim', opts = {} },
{
  -- Adds git related signs to the gutter, as well as utilities for managing changes
  'lewis6991/gitsigns.nvim',
  opts = {
    -- See `:help gitsigns.txt`
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
    on_attach = function(bufnr)
      vim.keymap.set('n', '<leader>hp', require('gitsigns').preview_hunk, { buffer = bufnr, desc = 'Preview git hunk' })

      -- don't override the built-in and fugitive keymaps
      local gs = package.loaded.gitsigns
      vim.keymap.set({ 'n', 'v' }, ']c', function()
        if vim.wo.diff then
          return ']c'
        end
        vim.schedule(function()
          gs.next_hunk()
        end)
        return '<Ignore>'
      end, { expr = true, buffer = bufnr, desc = 'Jump to next hunk' })
      vim.keymap.set({ 'n', 'v' }, '[c', function()
        if vim.wo.diff then
          return '[c'
        end
        vim.schedule(function()
          gs.prev_hunk()
        end)
        return '<Ignore>'
      end, { expr = true, buffer = bufnr, desc = 'Jump to previous hunk' })
    end,
  },
},

{
  -- Theme inspired by Atom
  'navarasu/onedark.nvim',
  priority = 1000,
  config = function()
    vim.cmd.colorscheme 'onedark'
  end,
},

{
  -- Set lualine as statusline
  'nvim-lualine/lualine.nvim',
  -- See `:help lualine.txt`
  opts = {
    options = {
      icons_enabled = false,
      theme = 'onedark',
      component_separators = '|',
      section_separators = '',
    },
  },
},

{
  -- Add indentation guides even on blank lines
  'lukas-reineke/indent-blankline.nvim',
  -- Enable `lukas-reineke/indent-blankline.nvim`
  -- See `:help ibl`
  main = 'ibl',
  opts = {},
},

-- "gc" to comment visual regions/lines
{ 'numToStr/Comment.nvim', opts = {} },

-- Fuzzy Finder (files, lsp, etc)
{
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    -- Fuzzy Finder Algorithm which requires local dependencies to be built.
    -- Only load if `make` is available. Make sure you have the system
    -- requirements installed.
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      -- NOTE: If you are having trouble with this installation,
      --       refer to the README for telescope-fzf-native for more instructions.
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
  },
    config = function()
      require("telescope").setup {
        defaults = {
          file_ignore_patterns = { "node_modules" },
      },
    }
  end,
},

{
  -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  build = ':TSUpdate',
},
{
      'kylechui/nvim-surround',
      config = function()
          require("nvim-surround").setup({
              -- your configuration here (if any)
          })
      end
  },
{

'stevearc/oil.nvim',
config = function()
  require("oil").setup({
    float = {
      border = "rounded", -- Border style: "rounded", "double", "single", etc.
      max_width = 100,    -- Maximum width of the floating window
      max_height = 50,    -- Maximum height of the floating window
      min_width = 50,     -- Minimum width of the floating window
      min_height = 10,    -- Minimum height of the floating window
      win_options = {
        winblend = 10,    -- Transparency of the floating window
        -- preview = "right",
      },
    },
    view_options = {
      show_hidden = true, -- Optionally show hidden files
    },
    default_file_explorer = true, -- Use Oil as the default file explorer
    keymaps = {
        ["q"] = "actions.close", -- Close Oil
        -- ["<leader>o"] = function()
        --     vim.cmd("b#") -- Jump to the previously active buffer
        --   end,
      dependencies = { "nvim-lua/planary.nvim" },
        },
    })

    -- Correctly set up the keymap
    vim.keymap.set('n', '<leader>o', function() require("oil").open_float() end, { desc = "Open Oil File Explorer" })
  end
      },
--   {
--     "nvim-neo-tree/neo-tree.nvim",
--     -- cmd = "Neotree",
--     branch = "v3.x",
--     dependencies = {
--     "nvim-lua/plenary.nvim",
--     "MunifTanjim/nui.nvim",
--     -- "nvim-tree/nvim-web-devicons",
--     "neovim/nvim-lspconfig", -- LSP support for diagnosticsn preview window: See `# Preview Mode` for more information
--     -- "3rd/image.nvim",
--     },
--     config = function()
--     require("neo-tree").setup({
--         -- use_default_mappings = false, -- Disable all default keymaps
--         sources = {
--           "filesystem",
--           "buffers",    -- Keep the buffers source
--           "git_status", -- Keep the git status source
--           -- "diagnostics" -- Keep the diagnostics source
--         },
--           filesystem = {
--     -- follow_current_file = true, -- Sync tree with the currently open file
--     -- group_empty_dirs = true,    -- Group empty directories
--     hijack_netrw = true,        -- Replace netrw
--     -- use_libuv_file_watcher = true, -- Watch filesystem changes
--     -- bind_to_cwd = false,        -- Don't change root based on the current working directory
--     cwd_target = "git_root",    -- Set the root to the Git repository root
--   },
-- window = {
--   mappings = {
--     -- ["<leader>ea"] = "expand_all",  -- Expand all directories under the current root
--   },
-- },
--         -- diagnostics = {
--         --   bind_to_cwd = true,
--         --   diag_sort_function = "severity", -- Sort diagnostics by severity
--         --   follow_current_file = true,
--         --   show_unloaded = true,
--         -- }
--       })
--     end
--
--   },


  ----
  ---
  ---
  ---

  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  -- { import = 'custom.plugins' },
}, {})

--- END OF LAZY
---
---
-- for dadbod completion
-- cmp isn't working yet
-- cmp.setup.filetype({ "sql" }, {
--   sources = {
--     { name = "vim-dadbod-completion"},
--     { name = "buffer" },
--
--   },
-- })


-- This is so dadbod <leader>o doesn't overwrite my oil setupd
-- Doesn't work yet
-- vim.g.db_ui_disable_default_mappings = true


--
-- vim.api.nvim_create_autocmd("VimLeave", {
--   callback = function()
--     local cwd = vim.fn.getcwd()
--     local file = vim.fn.expand("$HOME") .. "/.nvim_last_dir"
--     vim.fn.writefile({ cwd }, file)
--   end,
-- })
--


-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.o.clipboard = 'unnamedplus'
--
vim.o.clipboard = nil
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]
-- Justins personal Keymapping
vim.api.nvim_set_keymap('i', '<CapsLock>', '<Esc>', {noremap = true, silent = true})

-- Keymap set is the newer way
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true })
vim.keymap.set('t', [[<C-v><Esc>]]   , '<Esc>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<C-v>', '<C-v>', {noremap = true, silent = true})

-- for quick Telescope action
-- These were custom written but I think the functionality of space ff ect. is already in the environment
vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fb', '<cmd>Telescope buffers<CR>', { noremap = true })
-- Done with Justins section
-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})


-- Highlighting for terminal mode
--
vim.cmd("highlight! TermCursorNC guibg=red guifg=white ctermbg=1 ctermfg=15")

-- This may be required if a new color scheme is applied
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
  vim.cmd("highlight! TermCursorNC guibg=red guifg=white ctermbg=1 ctermfg=15")
  end,
})



-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == "" then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ":h")
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    print("Not a git repository. Searching on current working directory")
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep({
      search_dirs = {git_root},
    })
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>b', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').buffers(require('telescope.themes').get_dropdown({
    winblend = 10,
    previewer = false,
    layout_config = {
      width = 0.5,
    },
    sort_mru = true, --most recent

  }))
end, { desc = '[b] Search Buffers' })

vim.keymap.set('n', '<leader>m', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').marks({
    winblend = 10,
    -- previewer = true,
    layout_strategy = "horizontal",
    layout_config = {
      width = 0.4,
      height = 0.4,
      -- preview_cutoff = 0,
      preview_width = 0.4,
      prompt_position = "top",
    },
    sort_mru = true, --most recent

  })
end, { desc = '[b] Search Buffers' })

vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
-- vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
-- vim.keymap.set('n', '<leader><space>', function() require('telescope.builtin').find_files({ cwd = vim.fn.expand('%:p:h:h'),}) end, { noremap = true, silent = true,  desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
-- vim.keymap.set('n', '<leader>lf', vim.lsp.buf.formatting, { noremap = true, silent = true}) --I want to eventually to be able to easily format text

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust',  'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,

    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>a'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>A'] = '@parameter.inner',
        },
      },
    },
  }
end, 0)

-- [[ Configure LSP ]]
vim.lsp.config(pyright.setup{})

-- vim.lsp.config(.ts_ls.setup({filetypes = {"javascript", "typescript", "javascriptreact", "typescriptreact", "jsx", "tsx"}})
-- vim.lsp.config(.ts_ls.setup({})
vim.lsp.config(eslint.setup{})
vim.lsp.config(html.setup{})
vim.lsp.config(stylelint_lsp.setup{})
vim.lsp.config(gopls.setup{})
-- vim.lsp.config(tsserver.setup{})
vim.lsp.config(ts_ls.setup{})



--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  -- nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  vim.keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions, { noremap = true, silent = true, desc = '[G]oto [D]efinitions' })
  -- nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, { noremap = true, silent = true, desc = '[G]oto [R]eferences' })

  -- nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  vim.keymap.set('n', 'gI', require('telescope.builtin').lsp_implementations, { noremap = true, silent = true, desc = '[G]oto [I]mplementation' })

  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  --Copy pervious buffer when pasting:
-- greatest remap ever
vim.keymap.set("x", "<leader>p", '"_dP')

  -- Create a command `:Format` local to the LSP buffer
  local function setup_format_command()
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

setup_format_command()

end
-- This is to help attach the Format
local lspconfig = require('lspconfig')

local servers = {'pyright', 'ts_ls', --[[ add other LSP servers here ]]}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    -- other server-specific settings here
  }
end
-- document existing key chains
require('which-key').register {
  ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
  ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
  ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
  ['<leader>h'] = { name = 'More git', _ = 'which_key_ignore' },
  ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
  ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
  ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
  ['<leader>P'] = { name = '[P]aste keep original', _ = 'which_key_ignore' },
}

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
      -- diagnostics = { disable = { 'missing-fields' } },
    },
  },
}

-- Optional: neodev first (Lua LSP tweaks for Neovim)
require('neodev').setup()

-- nvim-cmp capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Your servers table (example)
-- local servers = { lua_ls = {settings = {...}}, pyright = {}, ts_ls = {}, bashls = {} }

-- Mason just installs binaries; no handlers needed anymore
require('mason').setup()
require('mason-lspconfig').setup {
  ensure_installed = vim.tbl_keys(servers),
}

-- 1) Set global defaults for all LSP clients
vim.lsp.config('*', {
  capabilities = capabilities,
  on_attach = on_attach,
})

-- 2) Apply per-server overrides (merges with the config provided by nvim-lspconfig)
for name, cfg in pairs(servers) do
  vim.lsp.config(name, cfg)
end

-- 3) Enable all servers so they auto-start on matching filetypes
vim.lsp.enable(vim.tbl_keys(servers))
-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert'
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<C-\\>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
