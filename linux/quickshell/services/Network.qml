pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Connectivity state via NetworkManager. Polled because nmcli is cheap and
// phase 1 only needs the bar indicator; a richer event-driven service can
// come with the controls drawer.
Singleton {
    id: root

    // "ethernet", "wifi" or "" while disconnected
    property string type: ""
    property string name: ""
    property bool wifiEnabled: false

    function setWifi(on: bool): void {
        wifiEnabled = on;
        Quickshell.execDetached(["nmcli", "radio", "wifi", on ? "on" : "off"]);
    }

    Process {
        id: query

        command: ["sh", "-c", "nmcli -t -f NAME,TYPE,DEVICE connection show --active; printf 'RADIO:%s\\n' \"$(nmcli radio wifi)\""]

        stdout: StdioCollector {
            onStreamFinished: {
                root.type = "";
                root.name = "";
                for (const line of text.trim().split("\n")) {
                    if (line.startsWith("RADIO:")) {
                        root.wifiEnabled = line.slice(6).trim() === "enabled";
                        continue;
                    }
                    const parts = line.split(":");
                    if (parts.length < 3)
                        continue;
                    if (parts[1].endsWith("ethernet")) {
                        root.type = "ethernet";
                        root.name = parts[0];
                        break;
                    }
                    if (parts[1].endsWith("wireless")) {
                        root.type = "wifi";
                        root.name = parts[0];
                        break;
                    }
                }
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: query.running = true
    }
}
