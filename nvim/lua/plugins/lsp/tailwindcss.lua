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
    root_dir = vim.fs.root(
      'tailwind.config.js',
      'tailwind.config.cjs',
      'tailwind.config.ts',
      'postcss.config.js',
      'node_modules'
    ),
  })
end

return M
