require('core.options')
require('core.keymaps')

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.env.PATH = vim.env.PATH .. ':' .. vim.fn.expand('$HOME/go/bin')
vim.env.PATH = vim.env.PATH .. ':' .. vim.fn.stdpath('data') .. '/mason/bin'

require('lazy').setup({
  -- require('plugins.avante'),
  require('plugins.auto-session'),
  require('plugins.neo-tree'),
  require('plugins.colortheme'),
  require('plugins.bufferline'),
  require('plugins.copilot'),
  require('plugins.markdown-preview'),
  require('plugins.lualine'),
  require('plugins.treesitter'),
  require('plugins.telescope'),
  require('plugins.lsp'),
  require('plugins.linting'),
  require('plugins.vim-test'),
  require('plugins.autocompletion'),
  require('plugins.autoformatting'),
  require('plugins.gitsigns'),
  require('plugins.copilot'),
  require('plugins.indent-blankline'),
  require('plugins.comment'),
  require('plugins.misc'),
  require('plugins.dev'),
})

-- Related to treesitter
vim.api.nvim_create_autocmd('FileType', {
  pattern = { '*' },
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local filetype = vim.bo[buf].filetype

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

    if vim.bo[buf].filetype ~= '' and not vim.tbl_contains(excluded_filetypes, filetype) then
      -- Check if parser exists before starting treesitter
      local has_parser = pcall(vim.treesitter.language.get_lang, filetype)
      if has_parser then
        vim.treesitter.start(buf)
      else
        vim.notify('No treesitter parser available for filetype: ' .. filetype, vim.log.levels.WARN)
      end
    end
  end,
})
