return {
  'github/copilot.vim',
  config = function()
    -- Also see: https://github.com/orgs/community/discussions/41869
    -- options
    vim.g.copilot_enabled = true
    vim.g.copilot_enabled = '/usr/local/bin/node'
    vim.g.copilot_filetypes = {
      ['*'] = false,
      typescript = true,
      typescriptreact = true,
      javascript = true,
      css = true,
      lua = true,
      markdown = true,
      sh = true,
    }
  end,
}
