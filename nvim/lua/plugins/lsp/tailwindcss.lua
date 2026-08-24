local M = {}

M.setup = function()
  vim.lsp.config('tailwindcss', {
    settings = {
      tailwindCSS = {
        experimental = {
          classRegex = {
            'tw`([^`]*)',
            'tw="([^"]*)',
            'tw={"([^"}]*)',
            'tw\\.\\w+`([^`]*)',
            'tw\\(.*?\\)`([^`]*)',
          },
        },
      },
    },
    filetypes = { 'html', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'css' },
  })
end

return M
