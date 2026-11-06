pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// The disposable skin layer: every color, size and font the shell shows
// comes from here, so restyling the desktop touches this file and the
// primitives built on it, never a module.
//
// Current skin: liquid glass (phase 7) in Tokyo Night, with a light (Day)
// and a dark (Night) mode. The mode follows the GTK color scheme; the
// toggle-theme-mode script flips everything together.
Singleton {
    id: root

    property bool light: false

    function setMode(mode: string): void {
        root.light = (mode === "light");
    }

    // Follow whatever mode the session was left in
    Process {
        running: true
        command: ["gsettings", "get", "org.gnome.desktop.interface", "color-scheme"]

        stdout: StdioCollector {
            onStreamFinished: root.light = text.includes("prefer-light")
        }
    }

    // The palette comes from the current theme (~/.config/current-theme,
    // repointed by switch-theme); the inline honey values keep the shell
    // alive when the symlink is missing or broken
    readonly property var fallbackPalette: ({
        light: { bg: "#ede4d3", panel: "#c4f0e8d7", surface: "#66c0ab89", panelBorder: "#334a3d28", fg: "#463a28", muted: "#8a7a5e", accent: "#8c6c3e" },
        dark: { bg: "#1e1915", panel: "#a91b1612", surface: "#73332a1f", panelBorder: "#26e8d5b0", fg: "#e8d5b0", muted: "#a08d72", accent: "#e0af68" }
    })

    FileView {
        id: paletteFile

        path: Quickshell.env("HOME") + "/.config/current-theme/palette.json"
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
        printErrors: false
    }

    readonly property var palette: {
        try {
            const p = JSON.parse(paletteFile.text());
            return light ? p.light : p.dark;
        } catch (e) {
            return light ? fallbackPalette.light : fallbackPalette.dark;
        }
    }

    // Solid base: the lock screen and anything needing full contrast
    readonly property color bg: palette.bg

    // Glass: panel is the window surface, surface the cards on top of it
    readonly property color panel: palette.panel
    readonly property color surface: palette.surface
    readonly property color panelBorder: palette.panelBorder

    readonly property color fg: palette.fg
    readonly property color muted: palette.muted
    readonly property color accent: palette.accent

    readonly property string font: "AdwaitaMono Nerd Font Propo"
    readonly property int fontSize: 13

    // Bar icon glyphs render larger than the shell's text
    readonly property int barIconSize: 16

    readonly property int radius: 12
    readonly property int radiusSmall: 7

    readonly property int barHeight: 32
}
