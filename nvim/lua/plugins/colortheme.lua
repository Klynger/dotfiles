return {
  'svrana/neosolarized.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('neosolarized').setup {
      comment_italics = true,
      background_set = false,
    }

    local function reload_colorscheme()
      require('neosolarized').setup {
        comment_italics = true,
        background_set = false,
      }
      vim.cmd.colorscheme 'neosolarized'
    end

    reload_colorscheme()

    vim.api.nvim_create_autocmd('SessionLoadPost', {
      callback = function()
        reload_colorscheme()
        print 'Colorscheme reapplied after session load!'
      end,
      desc = 'Reapply Neosolarized colorscheme after session load',
    })
  end,
  dependencies = {
    'tjdevries/colorbuddy.nvim',
  },
}
