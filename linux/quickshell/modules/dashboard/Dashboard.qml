import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.components
import qs.services

// The dashboard (phase 5, replacing quick-panel): the media card with
// playback controls and a month calendar that opens the calendar app.
PanelWindow {
    id: panel

    visible: Panels.dashboardOpen

    // Unanchored: centered on the output
    implicitWidth: 460
    implicitHeight: content.implicitHeight + 32
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    HyprlandFocusGrab {
        windows: [panel]
        active: Panels.dashboardOpen
        onCleared: Panels.dashboardOpen = false
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.bg
        radius: 8
        border.color: Theme.surface
        border.width: 1
    }

    ColumnLayout {
        id: content

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 16
        }
        spacing: 14

        // Media card
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: mediaContent.implicitHeight + 24
            radius: 8
            color: Theme.surface

            ColumnLayout {
                id: mediaContent

                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin: 12
                    rightMargin: 12
                }
                spacing: 10

                Text {
                    visible: !Media.hasPlayer || Media.title === ""
                    text: "No media playing"
                    color: Theme.muted
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                    Layout.alignment: Qt.AlignHCenter
                }

                RowLayout {
                    visible: Media.hasPlayer && Media.title !== ""
                    spacing: 12

                    Image {
                        visible: Media.artUrl !== ""
                        source: Media.artUrl
                        sourceSize.width: 84
                        sourceSize.height: 84
                        Layout.preferredWidth: 84
                        Layout.preferredHeight: 84
                    }

                    ColumnLayout {
                        spacing: 2
                        Layout.fillWidth: true

                        Text {
                            visible: Media.playerName !== ""
                            text: Media.playerName
                            color: Theme.muted
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize - 3
                        }

                        Text {
                            text: Media.title
                            color: Theme.fg
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize + 1
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            visible: Media.artist !== ""
                            text: Media.artist
                            color: Theme.fg
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize - 1
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            visible: Media.album !== ""
                            text: Media.album
                            color: Theme.muted
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize - 2
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }

                RowLayout {
                    visible: Media.hasPlayer && Media.title !== ""
                    spacing: 26
                    Layout.alignment: Qt.AlignHCenter

                    Text {
                        text: "󰒮"
                        color: Theme.fg
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize + 6

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -8
                            onClicked: Media.previous()
                        }
                    }

                    Text {
                        text: Media.playing ? "󰏤" : "󰐊"
                        color: Theme.accent
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize + 8

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -8
                            onClicked: Media.togglePlaying()
                        }
                    }

                    Text {
                        text: "󰒭"
                        color: Theme.fg
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize + 6

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -8
                            onClicked: Media.next()
                        }
                    }
                }
            }
        }

        // Month calendar; clicking it opens the calendar app, like the old
        // quick-panel launch button did
        ColumnLayout {
            id: calendar

            readonly property date now: panel.visible ? new Date() : new Date()
            readonly property int year: now.getFullYear()
            readonly property int month: now.getMonth()
            readonly property int today: now.getDate()
            readonly property int firstDay: new Date(year, month, 1).getDay()
            readonly property int daysInMonth: new Date(year, month + 1, 0).getDate()

            spacing: 8
            Layout.fillWidth: true

            Text {
                text: Qt.formatDate(calendar.now, "MMMM yyyy")
                color: Theme.fg
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
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
                    model: calendar.firstDay + calendar.daysInMonth

                    Item {
                        id: cell

                        required property int index

                        readonly property int day: index - calendar.firstDay + 1
                        readonly property bool isToday: day === calendar.today

                        implicitHeight: 26
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

            Text {
                text: "Open Calendar"
                color: Theme.accent
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 1
                Layout.alignment: Qt.AlignHCenter

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6

                    onClicked: {
                        Panels.dashboardOpen = false;
                        Quickshell.execDetached(["gtk-launch", "org.gnome.Calendar"]);
                    }
                }
            }
        }
    }
}
