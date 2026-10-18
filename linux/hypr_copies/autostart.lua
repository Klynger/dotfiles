-----------------
--- AUTOSTART ---
-----------------

-- Machine-specific: this file is copied (not symlinked) to ~/.config/hypr/
-- by scripts/copy-base-files.sh and is gitignored there.

-- Autostart necessary processes (the shell, daemons, etc.)
-- Or execute your favorite apps at launch. Example:
--
-- hl.on("hyprland.start", function()
--     hl.exec_cmd("wezterm", { workspace = "1" })
-- end)

hl.on("hyprland.start", function()
    hl.exec_cmd("playerctld daemon")
    hl.exec_cmd("qs")
end)
