import QtQuick
import Quickshell
import qs.components
import qs.services

// Icon and wifi name are separate texts so the icon can follow barIconSize
// while the name stays at the bar's text size.
Item {
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row

        spacing: 6

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Network.type === "ethernet" ? "󰀂"
                : Network.type === "wifi" ? "󰤨"
                : "󰤮"
            color: Network.type === "" ? Theme.muted : Theme.fg
            font.family: Theme.font
            font.pixelSize: Theme.barIconSize
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: Network.type === "wifi"
            text: Network.name
            color: Theme.fg
            font.family: Theme.font
            font.pixelSize: Theme.fontSize
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: Quickshell.execDetached(["launch-wifi"])
    }
}
