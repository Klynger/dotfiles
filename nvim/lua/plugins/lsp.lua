return {
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs and relatd tools to stdpath for neovim
    'mason-org/mason.nvim',
    'mason-org/mason-lspconfig.nvim',

    -- Useful status updates for LSP.
    -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
    {
      'j-hui/fidget.nvim',
      tag = 'v1.5.0',
      opts = {
        progress = {
          display = {
            done_icon = '✓', -- Icon shown when all LSP progress tasks are complete
          },
        },
        notification = {
          window = {
            windblend = 0, -- Background color opacity in the notification window
          },
        },
      },
    },
    { 'hrsh7th/cmp-nvim-lsp' },
    {
      'pmizio/typescript-tools.nvim',
      dependencies = { 'nvim-lua/plenary.nvim' },
      opts = {
        settings = {
          separate_diagnostic_server = true,
          publish_diagnostic_on = 'insert_leave',
          expose_as_code_action = 'all',
        },
      },
    },
  },
  config = function()
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
      -- Create a function that lets us more easily define mappings specific LSP related items.
      -- It sets the mode, buffer and description for us each time.
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        local telescope = require('telescope.builtin')

        -- Jump to the definition of the word under your cursor.
        -- This  is where a variable was first declared, or where a function is defined, etc.
        -- To jump back, press <C-t>.
        map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')

        -- Find references for the word under your cursor.
        map('gr', vim.lsp.buf.references, '[G]oto [R]eferences')

        -- Jump to the implementation of the word under your cursors.
        -- Useful when your language has ways of declaring types without an actual implementation.
        map('gI', vim.lsp.buf.implementation, 'Type [I]mplementation')

        -- Jump to the type of the word under your cursor.
        -- Useful when you're not sure what type a variable is and you want to see
        -- the definition of its *type*, not where it was *defined*
        map('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')

        -- Fuzzy find all the symbols in your current document.
        -- Symbols are things like variables, functions, types, etc.
        map('<leader>ds', vim.lsp.buf.document_symbol, '[D]ocument [S]ymbols')

        -- Fuzzy find all the symbols in your current workspace.
        -- Similar to document symbols, except searches over your entire project.
        map('<leader>ws', telescope.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

        -- Rename the variable under your cursors.
        -- Most Language Servers support renaming across files, etc.
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

        -- Show suggestions on normal mode when there is a problem
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

        -- TODO: Close it when we press Esc
        map('K', vim.lsp.buf.hover, '[LSP] Show Hover Declaration')

        -- WARN: This is not Goto Definition, this is Goto Declaration.
        -- For example, in C this would take you to the header.
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        --      See `:help CursorHold` for information about when this is executed
        --
        -- When you move your cursor, the highlights will be cleared
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })

          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds({ group = 'lsp-highlight', buffer = event2.buf })
            end,
          })
        end

        -- The following code creates a keymap to toggle inlay hights in your
        -- code, if the language server you are using supports them
        --
        -- This may be unwanted, since they displace some of your code
        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

    -- Ensure the server and tools are installed
    require('mason').setup()

    local typescript_config = require('plugins.lsp.typescript_tools')
    local tailwindcss_config = require('plugins.lsp.tailwindcss')
    local lua_ls_config = require('plugins.lsp.lua_ls')

    typescript_config.setup()
    tailwindcss_config.setup()
    lua_ls_config.setup()

    local ensure_installed = {
      'eslint',
      'bashls',
      'lua_ls',
      'tailwindcss',
      'stylua',
    }
    vim.list_extend(ensure_installed, {
      'stylua', -- Used to format lua code
      'tailwindcss',
    })
    require('mason-lspconfig').setup({
      ensure_installed = ensure_installed,
    })
  end,
}
