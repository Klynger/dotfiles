pragma Singleton

import Quickshell
import Quickshell.Wayland

// The focused window, via the foreign-toplevel protocol rather than the
// Hyprland socket, so it keeps working if the compositor ever changes.
Singleton {
    readonly property string windowTitle: ToplevelManager.activeToplevel?.title ?? ""
}
