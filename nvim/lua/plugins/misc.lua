return {
  {
    -- Tmux Navigator
    'christoomey/vim-tmux-navigator',
  },
  {
    -- Detect tabstop and shiftwidth  automatically
    'tpope/vim-sleuth',
  },
  {
    -- Powerful Git integration for Vim
    'tpope/vim-rhubarb',
  },
  {
    -- Keybinding hints
    'folke/which-key.nvim',
  },
  {
    -- Autoclose parentheses, brackets, quotes, etc.
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = true,
    opts = {},
  },
  {
    -- Highlight todo, notes, etc in comments
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },
  {
    -- High-performance color highlighter
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup()
    end,
  },
  {
    -- Emmet-like abbreviation expansion
    'mattn/emmet-vim',
    config = function()
      vim.g.user_emmet_install_global = 0
      vim.cmd [[
        autocmd FileType html,css,javascript,javascriptreact,typescriptreact EmmetInstall
      ]]
    end,
  },
  -- Auto-close and rename html/jsx/tsx tags
  {
    'windwp/nvim-ts-autotag',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {},
  },
  {
    'tpope/vim-surround',
  },
}
