-- Define session directory
local session_dir = vim.fn.stdpath('config') .. '/sessions'

if vim.fn.isdirectory(session_dir) == 0 then
  vim.fn.mkdir(session_dir, 'p')
end

return {
  'rmagatti/auto-session',
  lazy = false,

  -- Enables autocomplete for opts
  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    suppressed_dirs = { '~/', '~/Downloads', '/' },
    silent_restore = false,
    log_level = 'info',
    pre_save_cmds = { 'tabdo Neotree close' },
    bypass_save_filetypes = { 'neo-tree', 'neo-tree-popup', 'notify', 'terminal', 'quickfix', 'help' },
    close_unsupported_windows = true,
    args_allow_single_directory = true,
    args_allow_files_auto_save = false,
    auto_restore = true, -- Disable auto restore temporarily
    auto_save = true,
  },
}
