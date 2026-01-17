return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    branch = 'master',
    lazy = false,
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'cpp',
        'css',
        'diff',
        'gitignore',
        'html',
        'http',
        'javascript',
        'jsdoc',
        'go',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'regex',
        'rust',
        'tsx',
        'typescript',
        'tsx',
        'vim',
        'vimdoc',
        'yaml',
      },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        -- `false` will disable the whole extension
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = 'BufReadPre',
    config = function()
      vim.api.nvim_set_hl(0, 'TreesitterContextBottom', { underline = true, sp = 'grey' })
      vim.api.nvim_set_hl(0, 'TreesitterContextLineNumberBottom', { underline = true, sp = 'grey' })
      vim.api.nvim_set_hl(0, 'TreesitterContextLineNumber', vim.api.nvim_get_hl(0, { name = 'CursorLineNr' }))

      require('treesitter-context').setup({
        max_lines = 1,
      })
    end,
  },
  -- Not treesitter, but highlighting
  'RRethy/vim-illuminate',
}
