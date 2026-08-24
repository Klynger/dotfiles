local M = {}

M.setup = function()
  vim.lsp.config('cssls', {
    on_init = function(client)
      -- The server only takes custom data via this notification (the
      -- css.customData setting is handled client-side by VS Code).
      -- vscode-jsonrpc spreads positional params, hence the double array.
      client:notify('css/customDataChanged', {
        {
          vim.uri_from_fname(vim.fn.stdpath('config') .. '/lsp-data/tailwind.css-data.json'),
        },
      })
    end,
  })
end

return M
