pragma Singleton

import Quickshell
import Quickshell.Bluetooth

// Bluetooth adapter and device state. Named Bluez because the upstream
// singleton this wraps is already called Bluetooth.
Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool enabled: adapter?.enabled ?? false

    // Devices worth showing: paired or currently connected
    readonly property var devices: Bluetooth.devices.values.filter(d => d.paired || d.bonded || d.connected)
    readonly property var connected: Bluetooth.devices.values.filter(d => d.connected)

    function toggle(): void {
        if (adapter)
            adapter.enabled = !adapter.enabled;
    }
}
