pragma Singleton

import Quickshell

// Which shell surfaces are open. Widgets toggle these; windows bind to them.
Singleton {
    id: root

    property bool controlsOpen: false
    property bool launcherOpen: false
    property bool dashboardOpen: false
    property bool wallpapersOpen: false
    property bool calendarOpen: false

    function toggleControls(): void {
        root.controlsOpen = !root.controlsOpen;
    }

    function toggleLauncher(): void {
        root.launcherOpen = !root.launcherOpen;
    }

    function toggleDashboard(): void {
        root.dashboardOpen = !root.dashboardOpen;
    }

    function toggleWallpapers(): void {
        root.wallpapersOpen = !root.wallpapersOpen;
    }

    function toggleCalendar(): void {
        root.calendarOpen = !root.calendarOpen;
    }
}
