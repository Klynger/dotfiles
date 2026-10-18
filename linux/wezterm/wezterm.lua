-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

config.font = wezterm.font("AdwaitaMono Nerd Font Mono")
config.font_size = 9

config.enable_tab_bar = false
config.window_decorations = "NONE"

-- Curated Tokyo Night schemes (built into wezterm) instead of the
-- matugen-generated one: generated ANSI colors had poor contrast in light
-- mode. toggle-theme-mode touches this file so the scheme follows the mode.
local function color_scheme()
	local f = io.popen("gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null")
	if f then
		local out = f:read("*a") or ""
		f:close()
		if out:find("light") then
			return "Tokyo Night Day"
		end
	end
	return "Tokyo Night"
end

config.color_scheme = color_scheme()

-- Glass: translucent enough for Hyprland's blur to read through, matching
-- the shell's panels
config.window_background_opacity = 0.78
config.default_prog = {
	"zsh",
	"-lc",
	[[
    if command -v tmux >/dev/null 2>&1 && [ -z "$TMUX" ]; then
      exec tmux
    else
      exec zsh
    fi
  ]],
}

-- Enable compose key support for cedilla
config.use_ime = true
config.use_dead_keys = true

return config
