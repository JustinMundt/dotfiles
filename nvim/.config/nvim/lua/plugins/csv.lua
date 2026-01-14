return {
  'chrisbra/csv.vim',
  ft = { 'csv', 'tsv' },
  init = function()
    vim.g.csv_delim = ','
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'csv',
      callback = function()
        vim.cmd('CSVArrange')
      end,
    })
  end,
}
