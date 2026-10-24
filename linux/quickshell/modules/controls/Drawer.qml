import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.components
import qs.services

// The controls drawer (phase 3): network and bluetooth toggles, DND, the
// connected mute-everything, output devices with default selection, the
// per-app mixer, bluetooth devices, and the power row.
PanelWindow {
    id: panel

    visible: Panels.controlsOpen

    anchors {
        top: true
        right: true
    }

    margins {
        top: 8
        right: 8
    }

    exclusionMode: ExclusionMode.Ignore
    implicitWidth: 460
    implicitHeight: content.implicitHeight + 28
    color: "transparent"

    Panel {
        anchors.fill: parent
    }

    HyprlandFocusGrab {
        windows: [panel]
        active: Panels.controlsOpen
        onCleared: Panels.controlsOpen = false
    }

    ColumnLayout {
        id: content

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 14
        }
        spacing: 12

        RowLayout {
            spacing: 8

            ToggleChip {
                label: "Wi-Fi"
                active: Network.wifiEnabled
                onToggled: Network.setWifi(!Network.wifiEnabled)
            }

            ToggleChip {
                label: "Bluetooth"
                active: Bluez.enabled
                onToggled: Bluez.toggle()
            }

            ToggleChip {
                label: "DND"
                active: Notifs.dnd
                onToggled: Notifs.toggleDnd()
            }

            ToggleChip {
                label: "Mute all"
                active: Audio.muted
                onToggled: Audio.muteAll()
            }

            ToggleChip {
                label: Theme.light ? "󰖨 Light" : "󰖔 Dark"
                active: Theme.light
                onToggled: Quickshell.execDetached(["toggle-theme-mode"])
            }
        }

        Text {
            text: "Output devices"
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 2
        }

        Repeater {
            model: Audio.sinks.filter(n => n.name !== "virtmic")

            MixerRow {
                required property var modelData

                node: modelData
                label: modelData.nickname || modelData.description || modelData.name
                showDefault: true
                isDefault: Audio.sink === modelData
                onMakeDefault: Audio.setDefaultSink(modelData)
                Layout.fillWidth: true
            }
        }

        Text {
            visible: appRepeater.count > 0
            text: "Apps"
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 2
        }

        Repeater {
            id: appRepeater

            model: Audio.appStreams

            MixerRow {
                required property var modelData

                node: modelData
                label: Audio.appName(modelData)
                Layout.fillWidth: true
            }
        }

        Text {
            visible: btRepeater.count > 0
            text: "Bluetooth devices"
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 2
        }

        Repeater {
            id: btRepeater

            model: Bluez.devices

            RowLayout {
                id: btRow

                required property var modelData

                spacing: 10
                Layout.fillWidth: true

                Text {
                    text: btRow.modelData.name
                    color: btRow.modelData.connected ? Theme.fg : Theme.muted
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 1
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    visible: btRow.modelData.batteryAvailable && btRow.modelData.connected
                    text: Math.round(btRow.modelData.battery * 100) + "%"
                    color: Theme.muted
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                }

                Rectangle {
                    radius: 4
                    color: btMouse.containsMouse ? Theme.surface : Theme.bg
                    border.color: btMouse.containsMouse ? Theme.accent : Theme.muted
                    border.width: 1
                    implicitWidth: btAction.implicitWidth + 16
                    implicitHeight: btAction.implicitHeight + 6

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }
                    }

                    Text {
                        id: btAction

                        anchors.centerIn: parent
                        text: btRow.modelData.connected ? "Disconnect" : "Connect"
                        color: btRow.modelData.connected ? Theme.muted : Theme.accent
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 2
                    }

                    MouseArea {
                        id: btMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: btRow.modelData.connected ? btRow.modelData.disconnect() : btRow.modelData.connect()
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Theme.surface
        }

        // Lock, suspend, logout, reboot, shutdown
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 34

            Repeater {
                model: [
                    { icon: "󰌾", run: ["hyprlock"] },
                    { icon: "󰍃", run: ["hyprshutdown"] },
                    { icon: "󰒲", run: ["systemctl", "suspend"] },
                    { icon: "󰜉", run: ["hyprshutdown", "-t", "Rebooting...", "-p", "systemctl reboot"] },
                    { icon: "⏻", run: ["hyprshutdown", "-t", "Shutting down...", "-p", "systemctl poweroff"] }
                ]

                Text {
                    required property var modelData

                    text: modelData.icon
                    color: powerMouse.containsMouse ? Theme.accent : Theme.fg
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize + 6

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }
                    }

                    MouseArea {
                        id: powerMouse

                        anchors.fill: parent
                        anchors.margins: -8
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            Panels.controlsOpen = false;
                            Quickshell.execDetached(parent.modelData.run);
                        }
                    }
                }
            }
        }
    }
}
