local M = {}

-- Create a function that lets us more easily define mappings specific LSP related items.
-- It sets the mode, buffer and description for us each time.
---@param keys string
---@param func function
---@param desc string
---@param event vim.api.keyset.create_autocmd.callback_args
local function map(keys, func, desc, event)
  vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
end

M.map = map

---@param event vim.api.keyset.create_autocmd.callback_args
M.setup = function(event)
  local telescope = require('telescope.builtin')

  -- Jump to the definition of the word under your cursor.
  -- This  is where a variable was first declared, or where a function is defined, etc.
  -- To jump back, press <C-t>.
  map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition', event)

  -- Find references for the word under your cursor.
  map('gr', vim.lsp.buf.references, '[G]oto [R]eferences', event)

  -- Jump to the implementation of the word under your cursors.
  -- Useful when your language has ways of declaring types without an actual implementation.
  map('gI', vim.lsp.buf.implementation, 'Type [I]mplementation', event)

  -- Jump to the type of the word under your cursor.
  -- Useful when you're not sure what type a variable is and you want to see
  -- the definition of its *type*, not where it was *defined*
  map('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition', event)

  -- Fuzzy find all the symbols in your current document.
  -- Symbols are things like variables, functions, types, etc.
  map('<leader>ds', vim.lsp.buf.document_symbol, '[D]ocument [S]ymbols', event)

  -- Fuzzy find all the symbols in your current workspace.
  -- Similar to document symbols, except searches over your entire project.
  map('<leader>ws', telescope.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols', event)

  -- Rename the variable under your cursors.
  -- Most Language Servers support renaming across files, etc.
  map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame', event)

  -- Show suggestions on normal mode when there is a problem
  map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', event)

  map('K', vim.lsp.buf.hover, '[LSP] Show Hover Declaration', event)

  -- WARN: This is not Goto Definition, this is Goto Declaration.
  -- For example, in C this would take you to the header.
  map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration', event)
end

return M
