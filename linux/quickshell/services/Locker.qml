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

        command: ["sh", "-c",
            "sed -n 's/^\\$lock_wallpaper = //p' \"$HOME/.cache/hyprlock-wallpaper.conf\" 2>/dev/null | head -1; " +
            "cat \"$HOME/.cache/last_wallpaper\" 2>/dev/null"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n").filter(l => l !== "");
                root.wallpaper = lines[0] ?? "";
            }
        }
    }
}
