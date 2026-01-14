return {
  'pmizio/typescript-tools.nvim',
  dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
  opts = {
    settings = {
      tsserver_file_preferences = {
        includeInlayParameterNameHints = 'all',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeCompletionsForModuleExports = true,
      },
      tsserver_format_options = {
        indentSize = 2,
        tabSize = 2,
      },
    },
  },
  config = function(_, opts)
    require('typescript-tools').setup(opts)
  end,
}
