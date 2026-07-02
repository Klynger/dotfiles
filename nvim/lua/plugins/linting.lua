return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require('lint')

    lint.linters_by_ft = {
      sql = { 'sqlfluff' },
    }

    -- JS/TS filetypes are linted dynamically (see the autocmd below) so we only
    -- run the linter whose config is actually present in the project.
    local js_filetypes = {
      javascript = true,
      javascriptreact = true,
      typescript = true,
      typescriptreact = true,
    }

    local oxlint_configs = {
      'oxlint.config.ts',
      'oxlint.config.js',
      'oxlint.config.mjs',
      '.oxlintrc.json',
    }

    local eslint_configs = {
      'eslint.config.js',
      'eslint.config.mjs',
      'eslint.config.cjs',
      'eslint.config.ts',
      '.eslintrc',
      '.eslintrc.js',
      '.eslintrc.cjs',
      '.eslintrc.json',
      '.eslintrc.yml',
      '.eslintrc.yaml',
    }

    local function has_config(names, dir)
      return #vim.fs.find(names, { upward = true, type = 'file', path = dir }) > 0
    end

    -- Pick JS/TS linters based on which config the project uses. A repo can use
    -- oxlint, ESLint, or both.
    local function js_linters(bufnr)
      local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
      local linters = {}

      if has_config(oxlint_configs, dir) then
        table.insert(linters, 'oxlint')
      end

      if has_config(eslint_configs, dir) then
        table.insert(linters, 'eslint_d')
      end

      return linters
    end

    -- Neither oxlint nor eslint_d is guaranteed to be on $PATH; resolve them
    -- from the nearest node_modules/.bin walking up from the current file (works
    -- in monorepos regardless of cwd), falling back to a global binary.
    local function local_bin(binary_name)
      return function()
        local start = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
        local node_modules = vim.fs.find('node_modules', {
          upward = true,
          type = 'directory',
          path = start,
          limit = math.huge,
        })

        for _, dir in ipairs(node_modules) do
          local bin = dir .. '/.bin/' .. binary_name
          if vim.uv.fs_stat(bin) then
            return bin
          end
        end

        return binary_name
      end
    end

    lint.linters.oxlint.cmd = local_bin('oxlint')
    lint.linters.eslint_d.cmd = local_bin('eslint_d')

    -- Auto-lint on open, save, and when leaving insert mode
    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })

    vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function(args)
        if js_filetypes[vim.bo[args.buf].filetype] then
          local linters = js_linters(args.buf)
          if #linters > 0 then
            lint.try_lint(linters)
          end
        else
          lint.try_lint()
        end
      end,
    })
  end,
}
