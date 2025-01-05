-- For conciseness
local opts = { noremap = true, silent = true }

-- Directory to save sessions
local session_dir = vim.fn.stdpath 'data' .. '/sessions'

if vim.fn.isdirectory(session_dir) == 0 then
  vim.fn.mkdir(session_dir, 'p')
end

-- Funciton to get the session file path for the current directory
local get_session_file = function()
  return session_dir .. '/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':t') .. '.vim'
end

-- Auto-save session on exit
vim.api.nvim_create_autocmd('VimLeavePre', {
  callback = function()
    local session_file = get_session_file()
    vim.cmd('mksession! ' .. session_file)
    print('Session auto-saved to: ' .. session_file)
  end,
  desc = 'Auto-save session on exit',
})

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    if vim.fn.argc() == 0 and vim.fn.exists 'g:started_by_firenvim' == 0 then
      local session_file = get_session_file()

      if vim.fn.filereadable(session_file) == 1 then
        vim.cmd('source ' .. session_file)

        print('Session auto-loaded from: ' .. session_file)
      end
    end
  end,
  desc = 'Auto-load session on startup',
})

-- This code is commented because I'm only using the automatic loading that the rest of the file does
--[[ -- Save session ]]
--[[ vim.keymap.set('n', '<leader>ss', function() ]]
--[[   local session_file = get_session_file() ]]
--[[   vim.cmd('mksession! ' .. session_file) ]]
--[[]]
--[[   print('Session saved to: ' .. session_file) ]]
--[[ end, opts) ]]
--[[]]
--[[ -- Load session ]]
--[[ vim.keymap.set('n', '<leader>sl', function() ]]
--[[   local session_file = get_session_file() ]]
--[[   if vim.fn.filereadable(session_file) == 1 then ]]
--[[     vim.cmd('source ' .. session_file) ]]
--[[   else ]]
--[[     print('No session file found for this directory. Trying to find a session in ' .. session_file) ]]
--[[   end ]]
--[[ end, opts) ]]
