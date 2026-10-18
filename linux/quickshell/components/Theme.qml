pragma Singleton

import QtQuick
import Quickshell

// The disposable skin layer: every color, size and font the shell shows
// comes from here, so restyling the desktop touches this file and the
// primitives built on it, never a module.
//
// Current skin: liquid glass (phase 7). Panels are translucent and Hyprland
// blurs what sits behind them (layer rule in hypr/windows.lua).
Singleton {
    // Solid base: the lock screen and anything needing full contrast
    readonly property color bg: "#1a1b26"

    // Glass: panel is the window surface, surface the cards on top of it
    readonly property color panel: "#a916161e"
    readonly property color surface: "#73222638"
    readonly property color panelBorder: "#26c0caf5"

    readonly property color fg: "#c0caf5"
    readonly property color muted: "#787fa5"
    readonly property color accent: "#7aa2f7"

    readonly property string font: "AdwaitaMono Nerd Font Propo"
    readonly property int fontSize: 13

    readonly property int radius: 12
    readonly property int radiusSmall: 7

    readonly property int barHeight: 32
}
