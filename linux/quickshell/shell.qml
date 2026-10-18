import Quickshell
import Quickshell.Io
import qs.modules.bar

// Root of the shell (see quickshell-plan.html). Modules compose services and
// theme primitives; shell.qml only instantiates them.
ShellRoot {
    Bar {}

    // Proves `qs ipc` end to end: qs ipc call shell ping
    IpcHandler {
        target: "shell"

        function ping(): string {
            return "pong";
        }
    }
}
