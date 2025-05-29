local M = {}

M.setup = function()
  require('lspconfig').tailwindcss.setup({
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
    root_dir = require('lspconfig').util.root_pattern(
      'tailwind.config.js',
      'tailwind.config.cjs',
      'tailwind.config.ts',
      'postcss.config.js',
      'node_modules'
    ),
  })
end

return M
