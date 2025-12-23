local M = {}

M.setup = function()
  require('typescript-tools').setup({
    settings = {
      separate_diagnostic_server = true,
      publish_diagnostic_on = 'insert_leave',
      expose_as_code_action = 'all',
    },
    on_attach = function(_, bufnr)
      local map = function(keys, func, desc)
        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
      end

      local eslintFixAll = function()
        vim.cmd('LspEslintFixAll')
      end

      local typescript_tools_api = require('typescript-tools.api')

      vim.lsp.config('svelte', {})

      map('<leader>oi', typescript_tools_api.organize_imports, '[O]rganize [I]mports')
      map('<leader>rf', typescript_tools_api.rename_file, '[R]ename [F]ile')
      map('<leader>ai', typescript_tools_api.add_missing_imports, '[A]dd [I]mports')
      map('<leader>ru', typescript_tools_api.remove_unused, '[R]emove [U]nused')
      map('<leader>fa', eslintFixAll, '[F]ix [A]ll (ESLint)')
    end,
  })
end

return M
