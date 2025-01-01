return {
  'numToStr/Comment.nvim',
  dependencies = {
    'JoosepAlviste/nvim-ts-context-commentstring',
  },
  opts = {
    pre_hook = function(ctx)
      -- TODO: Check this because it is not working as expectec `gcc` doesn't work
      return require('ts_context_commentstring.internal').calculate_commentstring({
        key = ctx.ctype == require('Comment.utils').ctype.line and '__default' or '__multiline',
        location = ctx.ctype == require('Comment.utils').ctype.block and
          require('ts_context_commentstring.utils').get_cursor_location() or
          require('ts_context_commentstring.utils').get_visual_start_location(),
      })
    end,
  },
  lazy = false,
}
