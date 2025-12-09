return {
  'vim-test/vim-test',
  dependencies = {
    'preservim/vimux',
  },
  config = function()
    vim.keymap.set('n', '<leader>t', ':TestNearest<CR>')
    vim.keymap.set('n', '<leader>T', ':TestFile<CR>')

    vim.cmd('let g:VimuxUseNearest = 1')
    vim.cmd("let test#strategy = 'vimux'")
  end,
}
