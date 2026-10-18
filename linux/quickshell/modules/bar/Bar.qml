import QtQuick
import Quickshell
import qs.components
import qs.services

// Phase 0 scaffold bar: anchored to the bottom edge, out of waybar's way
// while the two run side by side. It only lists workspaces, to prove the
// window, the service wiring and hot reload; the real bar is phase 1.
PanelWindow {
    anchors {
        bottom: true
        left: true
        right: true
    }

    implicitHeight: Theme.barHeight
    color: Theme.bg

    Row {
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: Workspaces.all

            Rectangle {
                id: pill

                required property var modelData

                width: 22
                height: 22
                radius: 4
                color: modelData.focused ? Theme.accent : Theme.surface

                Text {
                    anchors.centerIn: parent
                    text: pill.modelData.id
                    color: pill.modelData.focused ? Theme.bg : Theme.fg
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Workspaces.focus(pill.modelData.id)
                }
            }
        }
    }
}
