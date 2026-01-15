-- Consolidated LSP Configuration (Neovim 0.11+)
-- Uses vim.lsp.config API instead of deprecated lspconfig.setup()

-- List of LSP servers to enable
-- Note: TypeScript/JavaScript handled by typescript-tools.nvim (not ts_ls)
-- Note: gopls installed via bootstrap.sh (go install), not Mason
local servers = {
  'lua_ls',
  'pyright',
  'clangd',
  'gopls',
  'rust_analyzer',
  'bashls',
  'jsonls',
  'yamlls',
  'html',
  'cssls',
  'dockerls',
  'tailwindcss',
}

-- Servers for Mason to install (excludes gopls - installed via go install)
local mason_ensure_installed = vim.tbl_filter(function(s)
  return s ~= 'gopls'
end, servers)

return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      { 'j-hui/fidget.nvim', opts = {} },

      -- Lua development support (replaces neodev.nvim)
      {
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
          library = {
            -- Load luvit types when the `vim.uv` word is found
            { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
          },
        },
      },
    },
    config = function()
      -- nvim-cmp capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
      if ok then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
      end

      -- Set global defaults for all LSP clients
      vim.lsp.config('*', {
        capabilities = capabilities,
      })

      -- Mason setup for automatic LSP installation
      require('mason').setup()
      require('mason-lspconfig').setup({
        ensure_installed = mason_ensure_installed,
        automatic_installation = true,
      })

      -- Enable all configured servers
      vim.lsp.enable(servers)

      -- LspAttach autocmd for buffer-local keymaps and settings
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then
            return
          end

          local function map(mode, keys, func, desc)
            vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
          end

          -- Rename and code actions
          map('n', '<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('n', '<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

          -- Goto mappings using Telescope if available
          local telescope_ok, telescope = pcall(require, 'telescope.builtin')
          if telescope_ok then
            map('n', 'gd', telescope.lsp_definitions, '[G]oto [D]efinition')
            map('n', 'gr', telescope.lsp_references, '[G]oto [R]eferences')
            map('n', 'gI', telescope.lsp_implementations, '[G]oto [I]mplementation')
            map('n', '<leader>D', telescope.lsp_type_definitions, 'Type [D]efinition')
            map('n', '<leader>ss', telescope.lsp_document_symbols, 'Document [S]ymbols')
            map('n', '<leader>sS', telescope.lsp_dynamic_workspace_symbols, 'Workspace [S]ymbols')
          else
            -- Fallback to built-in LSP functions
            map('n', 'gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
            map('n', 'gr', vim.lsp.buf.references, '[G]oto [R]eferences')
            map('n', 'gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
            map('n', '<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
          end

          -- Documentation
          map('n', 'K', vim.lsp.buf.hover, 'Hover Documentation')
          map('n', '<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

          -- Lesser used LSP functionality
          map('n', 'gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
          map('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
          map('n', '<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, '[W]orkspace [L]ist Folders')
        end,
      })
    end,
  },
}
