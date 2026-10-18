import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.components
import qs.services

// The clock's popover: a month calendar in the same drawer style as the
// controls, with the full calendar app one click away.
PanelWindow {
    id: panel

    visible: Panels.calendarOpen

    anchors {
        top: true
        right: true
    }

    margins {
        top: 8
        right: 8
    }

    exclusionMode: ExclusionMode.Ignore
    implicitWidth: 340
    implicitHeight: content.implicitHeight + 28
    color: "transparent"

    onVisibleChanged: {
        if (visible)
            month.offset = 0;
    }

    HyprlandFocusGrab {
        windows: [panel]
        active: Panels.calendarOpen
        onCleared: Panels.calendarOpen = false
    }

    Panel {
        anchors.fill: parent
    }

    ColumnLayout {
        id: content

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 14
        }
        spacing: 10

        MonthView {
            id: month

            Layout.fillWidth: true
        }

        Text {
            text: "Open Calendar app"
            color: Theme.accent
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 1
            Layout.alignment: Qt.AlignHCenter

            MouseArea {
                anchors.fill: parent
                anchors.margins: -6

                onClicked: {
                    Panels.calendarOpen = false;
                    Quickshell.execDetached(["gtk-launch", "org.gnome.Calendar"]);
                }
            }
        }
    }
}
