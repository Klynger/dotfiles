return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      require('catppuccin').setup({
        background = {
          light = 'latte',
          dark = 'mocha',
        },
        transparent_background = true,
      })

      -- vim.cmd.colorscheme('catppuccin')
    end,
  },
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      -- Follows 'background': nvim 0.10+ detects it from the terminal at
      -- startup, so after switching the system theme new sessions match;
      -- in a running one, :set background=light (or dark) flips it live
      light_style = 'day',
      transparent = true,
      styles = {
        sidebars = 'transparent',
        floats = 'transparent',
      },
    },
    config = function(_, opts)
      require('tokyonight').setup(opts)
      vim.cmd.colorscheme('tokyonight')
    end,
  },
}
