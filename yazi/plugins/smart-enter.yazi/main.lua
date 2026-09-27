--- @sync entry

-- Makes one key do the vim-like thing: descend into a directory, or open
-- the hovered file (yazi's official smart-enter tip)
return {
  entry = function()
    local h = cx.active.current.hovered
    ya.emit(h and h.cha.is_dir and "enter" or "open", { hovered = true })
  end,
}
