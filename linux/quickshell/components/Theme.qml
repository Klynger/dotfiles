pragma Singleton

import QtQuick
import Quickshell

// The disposable skin layer: every color, size and font the shell shows comes
// from here, so restyling the desktop touches this file and the primitives
// built on it, never a module. Placeholder flat palette until the design pass.
Singleton {
    readonly property color bg: "#1a1b26"
    readonly property color surface: "#20212e"
    readonly property color fg: "#c0caf5"
    readonly property color muted: "#565f89"
    readonly property color accent: "#7aa2f7"

    readonly property string font: "JetBrainsMono Nerd Font Propo"
    readonly property int fontSize: 13

    readonly property int barHeight: 30
}
