-- Replaces vim-bbye (bufdelete), gitlinker (gitbrowse) and
-- telescope-ui-select (picker.ui_select) with one maintained plugin
return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    bufdelete = { enabled = true },
    gitbrowse = { enabled = true },
    picker = { ui_select = true },
  },
  keys = {
    {
      '<leader>gb',
      function()
        Snacks.gitbrowse()
      end,
      mode = { 'n', 'v' },
      desc = 'Open current line or selection in the browser',
    },
    {
      '<leader>gB',
      function()
        Snacks.gitbrowse({ what = 'repo' })
      end,
      desc = 'Open the repository in the browser',
    },
    {
      '<leader>gY',
      function()
        Snacks.gitbrowse({
          what = 'repo',
          notify = false,
          open = function(url)
            vim.fn.setreg('+', url)
            vim.notify('Copied ' .. url)
          end,
        })
      end,
      desc = 'Copy the repository URL',
    },
  },
}
