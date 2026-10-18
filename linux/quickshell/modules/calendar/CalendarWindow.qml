import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.services

// The calendar app: a real floating window drawn by the shell itself, so it
// wears the glass theme natively with no GTK in sight. Launched from the
// app launcher (its desktop entry calls the IPC toggle), the clock popover
// or the dashboard.
Scope {
    LazyLoader {
        active: Panels.calendarWindowOpen

        FloatingWindow {
            title: "Calendar"
            implicitWidth: 560
            implicitHeight: 480
            minimumSize: Qt.size(420, 400)
            color: "transparent"

            onVisibleChanged: {
                if (!visible)
                    Panels.calendarWindowOpen = false;
            }

            Panel {
                anchors.fill: parent
                radius: 0

                ColumnLayout {
                    anchors {
                        fill: parent
                        margins: 20
                    }
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "󰸗"
                            color: Theme.accent
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize + 6
                        }

                        Text {
                            text: "Calendar"
                            color: Theme.fg
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize + 3
                            font.bold: true
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "«"
                            color: Theme.muted
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize + 4

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -8
                                onClicked: month.offset -= 12
                            }
                        }

                        Text {
                            text: "Today"
                            color: month.currentMonth ? Theme.muted : Theme.accent
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize - 1

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -6
                                onClicked: month.offset = 0
                            }
                        }

                        Text {
                            text: "»"
                            color: Theme.muted
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize + 4

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -8
                                onClicked: month.offset += 12
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Theme.surface
                    }

                    MonthView {
                        id: month

                        cellHeight: 44
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }
}
