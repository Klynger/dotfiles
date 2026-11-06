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
    // repointed by switch-theme); the inline tokyo-night values keep the
    // shell alive when the symlink is missing or broken
    readonly property var fallbackPalette: ({
        light: { bg: "#e1e2e7", panel: "#c4e6e7ed", surface: "#66aab0c4", panelBorder: "#33343b59", fg: "#343b59", muted: "#6c7398", accent: "#2e7de9" },
        dark: { bg: "#1a1b26", panel: "#a916161e", surface: "#73222638", panelBorder: "#26c0caf5", fg: "#c0caf5", muted: "#787fa5", accent: "#7aa2f7" }
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
