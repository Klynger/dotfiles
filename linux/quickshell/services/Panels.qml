pragma Singleton

import Quickshell

// Which shell surfaces are open. Widgets toggle these; windows bind to them.
Singleton {
    id: root

    property bool controlsOpen: false
    property bool launcherOpen: false

    function toggleControls(): void {
        root.controlsOpen = !root.controlsOpen;
    }

    function toggleLauncher(): void {
        root.launcherOpen = !root.launcherOpen;
    }
}
