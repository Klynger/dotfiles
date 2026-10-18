import QtQuick
import Quickshell
import qs.components
import qs.services

Text {
    text: Network.type === "ethernet" ? "󰀂"
        : Network.type === "wifi" ? "󰤨  " + Network.name
        : "󰤮"
    color: Network.type === "" ? Theme.muted : Theme.fg
    font.family: Theme.font
    font.pixelSize: Theme.fontSize

    MouseArea {
        anchors.fill: parent
        onClicked: Quickshell.execDetached(["launch-wifi"])
    }
}
