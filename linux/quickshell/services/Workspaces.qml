pragma Singleton

import Quickshell
import Quickshell.Hyprland

// Workspace state, wrapped so modules never import Quickshell.Hyprland
// directly: the compositor is reachable only through services.
Singleton {
    readonly property var all: Hyprland.workspaces.values
    readonly property var focused: Hyprland.focusedWorkspace

    function focus(id: int): void {
        Hyprland.dispatch("workspace " + id);
    }
}
