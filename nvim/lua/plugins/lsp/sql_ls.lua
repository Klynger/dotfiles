local M = {}

M.setup = function()
  vim.lsp.config('sqlls', {
    settings = {
      sqlLanguageServer = {
        connections = {
          -- Add your database connections here if needed
        },
      },
    },
    filetypes = { 'sql', 'mysql', 'plsql' },
  })
end

return M
