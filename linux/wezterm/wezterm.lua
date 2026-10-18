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
--
-- A force-mode file next to this config, containing "dark" or "light",
-- pins wezterm to that mode regardless of the system theme. nvim follows
-- whatever wezterm shows, not the system.
local force_mode_file = wezterm.config_dir .. "/force-mode"

local function color_scheme()
	local f = io.open(force_mode_file)
	if f then
		local mode = (f:read("*l") or ""):gsub("%s+", "")
		f:close()
		if mode == "dark" then
			return "Tokyo Night"
		end
		if mode == "light" then
			return "Tokyo Night Day"
		end
	end

	local p = io.popen("gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null")
	if p then
		local out = p:read("*a") or ""
		p:close()
		if out:find("light") then
			return "Tokyo Night Day"
		end
	end
	return "Tokyo Night"
end

wezterm.add_to_config_reload_watch_list(force_mode_file)

config.color_scheme = color_scheme()

-- Glass: translucent enough for Hyprland's blur to read through, matching
-- the shell's panels. Light mode keeps more opacity because dark text over
-- a colorful wallpaper bleed loses contrast much faster than light text
config.window_background_opacity = config.color_scheme == "Tokyo Night Day" and 0.93 or 0.78
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
