return {
  'rmagatti/auto-session',
  lazy = false,

  -- Enables autocomplete for opts
  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    suppressed_dirs = { '~/', '~/Downloads', '/' },
    silent_restore = false,
    log_level = 'error',
    pre_save_cmds = { "tabdo NeoTreeClose" },
    post_restore_cmds = { "NeoTreeReveal" },
  },
}
