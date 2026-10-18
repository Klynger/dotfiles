import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.components
import qs.modules.calendar
import qs.services

// The dashboard: the media card with
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

    Panel {
        anchors.fill: parent
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

        // Month calendar (shared with the clock popover); the full app
        // is one click below
        ColumnLayout {
            spacing: 8
            Layout.fillWidth: true

            MonthView {
                Layout.fillWidth: true
            }
            Text {
                text: "Open full calendar"
                color: Theme.accent
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 1
                Layout.alignment: Qt.AlignHCenter

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6

                    onClicked: {
                        Panels.dashboardOpen = false;
                        Panels.calendarWindowOpen = true;
                    }
                }
            }
        }
    }
}
