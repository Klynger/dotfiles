import Quickshell
import Quickshell.Io
import qs.modules.bar
import qs.modules.notifications
import qs.services

// Root of the shell (see quickshell-plan.html). Modules compose services and
// theme primitives; shell.qml only instantiates them.
ShellRoot {
    Bar {}
    Popups {}
    Center {}

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
}
