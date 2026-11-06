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

    // Solid base: the lock screen and anything needing full contrast
    readonly property color bg: light ? "#ede4d3" : "#1e1915"

    // Glass: panel is the window surface, surface the cards on top of it
    readonly property color panel: light ? "#c4f0e8d7" : "#a91b1612"
    readonly property color surface: light ? "#66c0ab89" : "#73332a1f"
    readonly property color panelBorder: light ? "#334a3d28" : "#26e8d5b0"

    readonly property color fg: light ? "#463a28" : "#e8d5b0"
    readonly property color muted: light ? "#8a7a5e" : "#a08d72"
    readonly property color accent: light ? "#8c6c3e" : "#e0af68"

    readonly property string font: "AdwaitaMono Nerd Font Propo"
    readonly property int fontSize: 13

    // Bar icon glyphs render larger than the shell's text
    readonly property int barIconSize: 16

    readonly property int radius: 12
    readonly property int radiusSmall: 7

    readonly property int barHeight: 32
}
