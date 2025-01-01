return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
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
      lua = { 'stylua' },
      sh = { 'shfmt' },
      typescript = { 'eslint_d', 'prettier' },
      javascript = { 'eslint_d', 'pretiter' },
      javascriptreact = { 'eslint_d', 'prettier' },
      typescriptreact = { 'eslint_d', 'prettier' },
      html = { 'prettier' },
      css = { 'prettier' },
      json = { 'prettier' },
      -- Conform can also run multiple formatters sequentially
      -- python = { "isort", "black" },
      --
      -- You can use 'stop_after_first' to run the first available formatter from the list
      -- javascript = { "prettierd", "prettier", stop_after_first = true },
    },
    formatters = {
      eslint_d = {
        command = 'eslint_d',
        args = { '--fix', '--stdin', '--stdin-filename', '$FILENAME' },
        stdin = true,
      },
    },
  },
}
