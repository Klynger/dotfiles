import QtQuick
import Quickshell
import qs.components
import qs.services

// Bluetooth state in the bar: click opens the controls drawer, right click
// still reaches the full bluetui manager.
Text {
    text: Bluez.enabled ? (Bluez.connected.length > 0 ? "󰂱" : "󰂯") : "󰂲"
    color: Bluez.enabled ? Theme.fg : Theme.muted
    font.family: Theme.font
    font.pixelSize: Theme.fontSize

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: event => {
            if (event.button === Qt.RightButton)
                Quickshell.execDetached(["launch-tui", "bluetui"]);
            else
                Panels.toggleControls();
        }
    }
}
