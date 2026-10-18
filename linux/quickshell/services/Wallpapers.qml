pragma Singleton

import Quickshell
import Quickshell.Io

// The wallpaper collection in ~/Pictures/Wallpapers/current. Applying goes
// through change-wallpaper, which also regenerates the matugen theme.
Singleton {
    id: root

    property var files: []

    Process {
        id: lister

        command: ["sh", "-c",
            "find \"$HOME/Pictures/Wallpapers/current\" -type f " +
            "\\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) | sort"]

        stdout: StdioCollector {
            onStreamFinished: root.files = text.trim() === "" ? [] : text.trim().split("\n")
        }
    }

    function refresh(): void {
        lister.running = true;
    }

    function apply(path: string): void {
        Quickshell.execDetached(["change-wallpaper", path]);
    }
}
