import QtQuick
import Quickshell
import qs.components
import qs.services

// Light/dark as a small sliding switch in the bar, mirroring the drawer
// chip; both run toggle-theme-mode so every surface flips together.
Rectangle {
    id: root

    width: 36
    height: 18
    radius: 9
    color: Theme.light ? Theme.accent : Theme.surface
    border.color: Theme.panelBorder
    border.width: 1

    Rectangle {
        id: knob

        width: 14
        height: 14
        radius: 7
        y: 2
        x: Theme.light ? root.width - width - 2 : 2
        color: Theme.light ? "#f5f6fa" : Theme.muted

        Behavior on x {
            NumberAnimation {
                duration: 160
                easing.type: Easing.OutBack
            }
        }

        Text {
            anchors.centerIn: parent
            text: Theme.light ? "󰖨" : "󰖔"
            color: Theme.light ? Theme.accent : Theme.bg
            font.family: Theme.font
            font.pixelSize: 9
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: Quickshell.execDetached(["toggle-theme-mode"])
    }
}
