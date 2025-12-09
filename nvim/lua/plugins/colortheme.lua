return {
  'catppuccin/nvim',
  name = 'catppuccin',
  tag = 'v1.10.0',
  priority = 1000,
  config = function()
    require('catppuccin').setup({
      background = {
        light = 'latte',
        dark = 'mocha',
      },
      transparent_background = true,
    })

    vim.cmd.colorscheme('catppuccin')
  end,
}
