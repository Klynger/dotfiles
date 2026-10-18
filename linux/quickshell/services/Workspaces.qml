pragma Singleton

import Quickshell
import Quickshell.Hyprland

// Workspace state, wrapped so modules never import Quickshell.Hyprland
// directly: the compositor is reachable only through services.
Singleton {
    readonly property var all: Hyprland.workspaces.values
    readonly property var focused: Hyprland.focusedWorkspace

    function focus(id: int): void {
        // This Hyprland build (Lua config DSL) evaluates IPC dispatch strings
        // as Lua, so plain hyprlang like "workspace 3" is a syntax error here
        Hyprland.dispatch("hl.dsp.focus({ workspace = " + id + " })");
    }
}
