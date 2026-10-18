pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Lock-screen state. The lock wallpaper follows what pick-lock-wallpaper
// saved for hyprlock, falling back to the current wallpaper.
Singleton {
    id: root

    property bool locked: false
    property string wallpaper: ""

    function lock(): void {
        resolver.running = true;
        root.locked = true;
    }

    function unlock(): void {
        root.locked = false;
    }

    Process {
        id: resolver

        // First existing file wins: the chosen lock wallpaper can go stale
        // when the collection changes (it did), so each path is verified
        command: ["sh", "-c",
            "lock=$(sed -n 's/^\\$lock_wallpaper = //p' \"$HOME/.cache/hyprlock-wallpaper.conf\" 2>/dev/null | head -1); " +
            "last=$(cat \"$HOME/.cache/last_wallpaper\" 2>/dev/null); " +
            "for f in \"$lock\" \"$last\"; do [ -n \"$f\" ] && [ -f \"$f\" ] && { printf '%s\\n' \"$f\"; break; }; done"]

        stdout: StdioCollector {
            onStreamFinished: root.wallpaper = text.trim().split("\n")[0] ?? ""
        }
    }
}
