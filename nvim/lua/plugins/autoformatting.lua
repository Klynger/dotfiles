local function js_formatter(bufnr)
  local oxfmt_config = vim.fs.find({ '.oxfmtrc.json', '.oxfmtrc.jsonc' }, {
    upward = true,
    path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)),
    type = 'file',
  })

  if #oxfmt_config > 0 then
    return { 'eslint_d', 'oxfmt' }
  end

  return { 'eslint_d', 'prettier' }
end

return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format({ async = true, lsp_format = 'fallback' })
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = true,
    notify_on_formatters = true,
    format_on_save = false,
    formatters_by_ft = {
      go = { 'swag_fmt', 'gofmt' },
      lua = { 'stylua' },
      sh = { 'shfmt' },
      -- typescript = { 'eslint_d', 'oxfmt', 'prettier' },
      -- javascript = { 'eslint_d', 'oxfmt', 'prettier' },
      -- javascriptreact = { 'eslint_d', 'oxfmt', 'prettier' },
      -- typescriptreact = { 'eslint_d', 'oxfmt', 'prettier' },
      typescript = js_formatter,
      javascript = js_formatter,
      javascriptreact = js_formatter,
      typescriptreact = js_formatter,
      html = { 'prettier' },
      css = { 'prettier' },
      json = { 'prettier' },
      sql = { 'sqlfluff' }, -- or 'pg_format' for PostgreSQL
      -- Conform can also run multiple formatters sequentially
      -- python = { "isort", "black" },
      --
      -- You can use 'stop_after_first' to run the first available formatter from the list
      -- javascript = { "another_prettier_fmt", "prettier", stop_after_first = true },
    },
    formatters = {
      swag_fmt = {
        command = 'swag',
        args = { 'fmt' },
        stdin = false, -- swag fmt doesn't use stdin
      },
      eslint_d = {
        command = 'eslint_d',
        args = { '--fix', '--stdin', '--stdin-filename', '$FILENAME' },
        stdin = true,
      },
    },
  },
}
