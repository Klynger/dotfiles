import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.services

// Incoming notifications, top-right, under the bar. The window exists only
// while there is something to show and reserves no space.
PanelWindow {
    visible: Notifs.popups.length > 0

    anchors {
        top: true
        right: true
    }

    margins {
        top: 8
        right: 8
    }

    exclusionMode: ExclusionMode.Ignore
    implicitWidth: 380
    implicitHeight: column.implicitHeight
    color: "transparent"

    ColumnLayout {
        id: column

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        spacing: 8

        Repeater {
            model: Notifs.popups

            NotifCard {
                required property var modelData

                notif: modelData
                popup: true
                Layout.fillWidth: true
            }
        }
    }
}
