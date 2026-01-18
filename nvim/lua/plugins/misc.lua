local function get_workspace_folders(root_dirs)
  local folders = {}
  local home = os.getenv('HOME')
  root_dirs = root_dirs or {}

  for _, base_dir in ipairs(root_dirs) do
    -- Expand ~ to home directory if present
    local dir_path = base_dir:gsub('^~', home)
    -- Fix the find command: add space after dir_path and fix -type flag
    local handle = io.popen('find ' .. dir_path .. ' -maxdepth 1 -type d | grep -v "^' .. dir_path .. '$"')
    if handle then
      for dir in handle:lines() do
        table.insert(folders, dir)
      end
      handle:close()
    end
  end

  return folders
end

vim.g.augment_workspace_folders = get_workspace_folders({ '~/dev', '~/spoke' })

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
    'tpope/vim-fugitive',
  },
  {
    'sindrets/diffview.nvim',
  },
  {
    -- Keybinding hints
    'folke/which-key.nvim',
  },
  {
    -- Integrate NeoVim with tmux
    'christoomey/vim-tmux-navigator',
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
  -- Auto-close and rename html/jsx/tsx tags
  {
    'windwp/nvim-ts-autotag',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {},
  },
  {
    'tpope/vim-surround',
  },
  -- Syntax highlighting for Firebase files
  {
    'delphinus/vim-firestore',
    ft = 'firestore',
    config = function()
      vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
        pattern = '*.rules',
        command = 'set filetype=firestore',
      })
    end,
  },
  {
    'augmentcode/augment.vim',
  },
  -- TODO: Configure fzf
  --
  -- Finding everything
  -- See https://github.com/ibhagwan/fzf-lua
  -- {
  --   'ibhagwan/fzf-lua',
  --   lazy = false,
  --   -- optional for icon support
  --   dependencies = { 'nvim-tree/nvim-web-devicons' },
  --   -- See https://www.reddit.com/r/neovim/comments/1bqf1w3/psa_fzflua_pulls_cause_an_error_my_github_account/
  --   url = 'https://gitlab.com/ibhagwan/fzf-lua',
  -- },
  {
    'ruifm/gitlinker.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('gitlinker').setup()

      -- Open the current line in the browser
      vim.api.nvim_set_keymap(
        'n',
        '<leader>gb',
        '<cmd>lua require"gitlinker".get_buf_range_url("n", {action_callback = require"gitlinker.actions".open_in_browser})<cr>',
        { silent = true }
      )

      -- Open the selected range in the browser
      vim.api.nvim_set_keymap(
        'v',
        '<leader>gb',
        '<cmd>lua require"gitlinker".get_buf_range_url("v", {action_callback = require"gitlinker.actions".open_in_browser})<cr>',
        {}
      )

      -- Copy the repository URL to the clipboard
      vim.api.nvim_set_keymap('n', '<leader>gY', '<cmd>lua require"gitlinker".get_repo_url()<cr>', { silent = true })
      -- Open the repository in the browser
      vim.api.nvim_set_keymap(
        'n',
        '<leader>gB',
        '<cmd>lua require"gitlinker".get_repo_url({action_callback = require"gitlinker.actions".open_in_browser})<cr>',
        { silent = true }
      )
    end,
  },
}
