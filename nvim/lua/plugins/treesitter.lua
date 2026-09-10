local ensure_installed = {
  'bash',
  'c',
  'cpp',
  'css',
  'diff',
  'dockerfile',
  'editorconfig',
  'git_config',
  'git_rebase',
  'gitcommit',
  'gitignore',
  'go',
  'html',
  'http',
  'javascript',
  'jsdoc',
  'json',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'regex',
  'rust',
  'svelte',
  'terraform',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
  'xml',
  'yaml',
}

-- Filetypes where treesitter should stay off even if a parser exists
local excluded_filetypes = {
  'neo-tree',
  'neo-tree-popup',
  'notify',
  'terminal',
  'quickfix',
  'help',
  'fidget',
  'TelescopePrompt',
  'TelescopeResults',
  'systemd',
  'qf',
  'text',
  'conf',
  'copilotpanel',
  'conform-info',
  'cmp_docs',
  'cmp_menu',
}

-- Languages whose treesitter indent rules misbehave; they keep the vim ones
local no_indent_languages = { 'ruby' }

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local ts = require('nvim-treesitter')
      ts.setup({})
      ts.install(ensure_installed)

      -- No dedicated mdx parser exists; reuse markdown's
      vim.filetype.add({
        extension = { mdx = 'markdown.mdx' },
      })
      vim.treesitter.language.register('markdown', 'markdown.mdx')
      vim.treesitter.language.register('bash', 'zsh')

      -- The main branch no longer enables highlight and indent for us
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
        callback = function(args)
          local filetype = vim.bo[args.buf].filetype
          if filetype == '' or vim.tbl_contains(excluded_filetypes, filetype) then
            return
          end

          local lang = vim.treesitter.language.get_lang(filetype)
          if not lang or not vim.treesitter.language.add(lang) then
            return
          end

          vim.treesitter.start(args.buf, lang)

          if not vim.tbl_contains(no_indent_languages, lang) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
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
