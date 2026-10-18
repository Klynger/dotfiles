import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.components
import qs.services

// Notification history, toggled from the bar bell. Newest first; clicking
// outside closes it.
PanelWindow {
    id: panel

    visible: Notifs.centerOpen

    anchors {
        top: true
        right: true
        bottom: true
    }

    margins {
        top: 8
        right: 8
        bottom: 8
    }

    implicitWidth: 420
    color: "transparent"

    Panel {
        anchors.fill: parent
    }

    HyprlandFocusGrab {
        windows: [panel]
        active: Notifs.centerOpen
        onCleared: Notifs.centerOpen = false
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: 12
        }
        spacing: 10

        RowLayout {
            spacing: 14
            Layout.fillWidth: true

            Text {
                text: "Notifications"
                color: Theme.fg
                font.family: Theme.font
                font.pixelSize: Theme.fontSize + 2
                font.bold: true
                Layout.fillWidth: true
            }

            Text {
                text: Notifs.dnd ? "DND on" : "DND off"
                color: Notifs.dnd ? Theme.accent : Theme.muted
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 1

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    onClicked: Notifs.toggleDnd()
                }
            }

            Text {
                text: "Clear all"
                color: Theme.muted
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 1

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    onClicked: Notifs.dismissAll()
                }
            }
        }

        Text {
            visible: Notifs.all.length === 0
            text: "Nothing here"
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: Theme.fontSize
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 24
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8
            clip: true

            model: [...Notifs.all].reverse()

            delegate: NotifCard {
                required property var modelData

                notif: modelData
                width: ListView.view.width
            }
        }
    }
}
