pragma Singleton

import Quickshell
import Quickshell.Io

// The wallpaper collection in ~/Pictures/Wallpapers/current. Applying goes
// through change-wallpaper, which also regenerates the matugen theme.
Singleton {
    id: root

    property var files: []

    // The wallpaper on screen before previewing started, to revert to
    property string current: ""

    Process {
        id: currentReader

        command: ["sh", "-c", "cat \"$HOME/.cache/last_wallpaper\" 2>/dev/null"]

        stdout: StdioCollector {
            onStreamFinished: root.current = text.trim()
        }
    }

    // A fast, theme-less wallpaper swap for live previews
    function preview(path: string): void {
        Quickshell.execDetached(["awww", "img", path, "--transition-type", "fade", "--transition-duration", "0.4"]);
    }

    function revert(): void {
        if (current !== "")
            preview(current);
    }

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
        currentReader.running = true;
    }

    function apply(path: string): void {
        Quickshell.execDetached(["change-wallpaper", path]);
    }
}
