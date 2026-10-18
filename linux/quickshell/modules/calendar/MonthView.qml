import QtQuick
import QtQuick.Layouts
import qs.components

// A month grid with arrows to step between months; today is marked when
// the shown month is the current one. Shared by the calendar popover and
// the dashboard.
ColumnLayout {
    id: root

    // Months away from today; 0 is now
    property int offset: 0

    // Row height of the day cells; the popover stays compact, the window
    // stretches
    property int cellHeight: 26

    readonly property date today: new Date()
    readonly property date shown: new Date(today.getFullYear(), today.getMonth() + offset, 1)
    readonly property int year: shown.getFullYear()
    readonly property int month: shown.getMonth()
    readonly property int firstDay: new Date(year, month, 1).getDay()
    readonly property int daysInMonth: new Date(year, month + 1, 0).getDate()
    readonly property bool currentMonth: offset === 0

    spacing: 8

    RowLayout {
        Layout.fillWidth: true

        Text {
            text: "󰅁"
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: Theme.fontSize + 2

            MouseArea {
                anchors.fill: parent
                anchors.margins: -8
                onClicked: root.offset--
            }
        }

        Text {
            text: Qt.formatDate(root.shown, "MMMM yyyy")
            color: Theme.fg
            font.family: Theme.font
            font.pixelSize: Theme.fontSize
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true

            MouseArea {
                anchors.fill: parent
                visible: !root.currentMonth
                onClicked: root.offset = 0
            }
        }

        Text {
            text: "󰅂"
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: Theme.fontSize + 2

            MouseArea {
                anchors.fill: parent
                anchors.margins: -8
                onClicked: root.offset++
            }
        }
    }

    GridLayout {
        columns: 7
        columnSpacing: 0
        rowSpacing: 2
        Layout.fillWidth: true

        Repeater {
            model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

            Text {
                required property string modelData

                text: modelData
                color: Theme.muted
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 3
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
        }

        Repeater {
            model: root.firstDay + root.daysInMonth

            Item {
                id: cell

                required property int index

                readonly property int day: index - root.firstDay + 1
                readonly property bool isToday: root.currentMonth && day === root.today.getDate()

                implicitHeight: root.cellHeight
                Layout.fillWidth: true

                Rectangle {
                    visible: cell.isToday
                    anchors.centerIn: parent
                    width: 24
                    height: 24
                    radius: 12
                    color: Theme.accent
                }

                Text {
                    anchors.centerIn: parent
                    visible: cell.day > 0
                    text: cell.day
                    color: cell.isToday ? Theme.bg : Theme.fg
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                }
            }
        }
    }
}
