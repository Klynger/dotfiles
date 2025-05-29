local M = {}

M.setup = function()
  require('typescript-tools').setup {
    on_attach = function(client, bufnr)
      local map = function(keys, func, desc)
        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
      end

      local typescript_tools_api = require 'typescript-tools.api'

      map('<leader>oi', typescript_tools_api.organize_imports, '[O]rganize [I]mports')
      map('<leader>rf', typescript_tools_api.rename_file, '[R]ename [F]ile')
      map('<leader>ai', typescript_tools_api.add_missing_imports, '[A]dd [I]mports')
      map('<leader>ru', typescript_tools_api.remove_unused, '[R]emove [U]nused')
    end,
  }
end

return M
