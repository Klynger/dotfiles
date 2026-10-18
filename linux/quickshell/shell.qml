import Quickshell
import Quickshell.Io
import qs.components
import qs.modules.bar
import qs.modules.calendar
import qs.modules.controls
import qs.modules.dashboard
import qs.modules.launcher
import qs.modules.lock
import qs.modules.notifications
import qs.modules.osd
import qs.modules.wallpapers
import qs.services

// Root of the shell (see quickshell-plan.html). Modules compose services and
// theme primitives; shell.qml only instantiates them.
ShellRoot {
    Bar {}
    Popups {}
    Center {}
    Drawer {}
    Launcher {}
    Dashboard {}
    Osd {}
    Picker {}
    Lock {}
    CalendarPopover {}

    // Proves `qs ipc` end to end: qs ipc call shell ping
    IpcHandler {
        target: "shell"

        function ping(): string {
            return "pong";
        }
    }

    // For keybinds: qs ipc call notifs toggleCenter / toggleDnd
    IpcHandler {
        target: "notifs"

        function toggleCenter(): void {
            Notifs.toggleCenter();
        }

        function toggleDnd(): void {
            Notifs.toggleDnd();
        }
    }

    // For keybinds: qs ipc call panels toggleControls / toggleLauncher
    IpcHandler {
        target: "panels"

        function toggleControls(): void {
            Panels.toggleControls();
        }

        function toggleLauncher(): void {
            Panels.toggleLauncher();
        }

        function toggleDashboard(): void {
            Panels.toggleDashboard();
        }

        function toggleWallpapers(): void {
            Panels.toggleWallpapers();
        }

        function toggleCalendar(): void {
            Panels.toggleCalendar();
        }
    }

    // The mute key: qs ipc call audio muteAll
    IpcHandler {
        target: "audio"

        function muteAll(): void {
            Audio.muteAll();
        }
    }

    // Light/dark, driven by toggle-theme-mode: qs ipc call theme setMode light
    IpcHandler {
        target: "theme"

        function setMode(mode: string): void {
            Theme.setMode(mode);
        }
    }

    // The lock screen. unlock is the trial-period escape hatch, reachable
    // only with a shell as this user (same exposure as pkill hyprlock was)
    IpcHandler {
        target: "lock"

        function lock(): void {
            Locker.lock();
        }

        function unlock(): void {
            Locker.unlock();
        }
    }
}
