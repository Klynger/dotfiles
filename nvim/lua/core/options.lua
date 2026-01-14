vim.o.hlsearch = true -- Set highlight on search
vim.wo.number = true -- Make line numbers default (default: false)
vim.o.mouse = 'a' -- Enable mouse mode (default: '')
vim.o.clipboard = 'unnamedplus' -- Sync clipboard between OS and Neovim. (default: '')
vim.o.breakindent = true -- Enable break indent
vim.o.undofile = true -- Save undo history
vim.o.smartcase = true -- Smart case (default: false)
vim.o.ignorecase = true -- Case-insensitive searching UNLESS \C or capital in search (default: false)
vim.wo.signcolumn = 'yes' -- Visual markers on the left side (icons, symbols, indicators...)
vim.o.updatetime = 250 -- Time to wait before triggering certain updates after stop typing (LSP diagnostics, linters, etc)
vim.o.timeoutlen = 300 -- Time to wait for a mapped sequence to complete (in ms)
vim.o.backup = false -- creates a backup file
vim.o.writebackup = false -- If a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
vim.completeopt = 'menuone,noselect,fuzzy' -- Better completion experience
vim.opt.termguicolors = true -- Set termguicolors to enable highlight groups
vim.o.whichwrap = 'bs<>[]hl' -- Which "horizontal" keys are allowed to travel to prev/next line
vim.o.wrap = false -- Display lines as one long line (default: false)
vim.o.linebreak = true -- Companion to wrap, don't split words (default: false)
vim.o.scrolloff = 8 -- Minimal number of screen lines to keep above and below the cursor
vim.o.sidescrolloff = 8 -- Minimal number of screen columns either side of cursor if wrap is `false`
vim.o.relativenumber = true -- Set relative numbered lines (default: false)
vim.o.numberwidth = 4 -- Set number column width to 4
vim.o.expandtab = true -- Convert tabs into spaces
vim.o.cursorline = false -- Highlight the current line
vim.o.splitbelow = true -- Force all horizontal splits to go below current window
vim.o.splitright = true -- Force all vertical splits to go to the right of current window
vim.o.swapfile = false -- Create a swapfile
vim.o.smartindent = true -- Make indenting smarter again
vim.o.showmode = false -- Turn off showing the current mode below (-- INSERT --)
vim.o.showtabline = 2 -- Always show tabs
vim.o.backspace = 'indent,eol,start' -- Allow backspace on indent, end of line, and start
vim.o.pumheight = 10 -- pop up menu height
vim.o.conceallevel = 0 -- So that `` is visible in markdown files
vim.o.fileencoding = 'utf-8' -- The encoding written to a file
vim.o.cmdheight = 1 -- More space in the NeoVim command line for displaying messages
vim.o.autoindent = true -- Copy indent from current line when starting new one (default: true)
vim.o.diffopt = 'internal,filler,vertical,context:3'
vim.o.spell = false -- Spell checking
vim.o.spelllang = 'en,en_us,pt_br'
vim.o.winborder = 'rounded' -- Configure floating window borders

vim.opt.laststatus = 3

-- vim.diagnostic.config({
--   float = {
--     border = 'rounded',
--   },
-- })

-- Tabs
local tab_size = 2
vim.o.shiftwidth = tab_size -- The number of spaces inserted for each indentation (default: 8)
vim.o.tabstop = tab_size -- Insert n spaces for a tab (default: 8)
vim.o.softtabstop = tab_size -- Number of spaces that a tab counts for while performing editing operations
-- vim.opt.shortmess:append 'c' -- Don't give |ins-completion-menu| messages (show menu while typing)
-- vim.opt.iskeyword:append '-' -- Hyphenated words recognized by searches
vim.opt.runtimepath:remove('/usr/share/vim/vimfiles') -- separate vim plugins from NeoVim in case vim still in use

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'go',
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})
