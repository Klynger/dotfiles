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
    readonly property color bg: light ? "#e1e2e7" : "#1a1b26"

    // Glass: panel is the window surface, surface the cards on top of it
    readonly property color panel: light ? "#c4e6e7ed" : "#a916161e"
    readonly property color surface: light ? "#66aab0c4" : "#73222638"
    readonly property color panelBorder: light ? "#33343b59" : "#26c0caf5"

    readonly property color fg: light ? "#343b59" : "#c0caf5"
    readonly property color muted: light ? "#6c7398" : "#787fa5"
    readonly property color accent: light ? "#2e7de9" : "#7aa2f7"

    readonly property string font: "AdwaitaMono Nerd Font Propo"
    readonly property int fontSize: 13

    readonly property int radius: 12
    readonly property int radiusSmall: 7

    readonly property int barHeight: 32
}
