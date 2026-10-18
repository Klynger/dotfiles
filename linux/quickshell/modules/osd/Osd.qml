import QtQuick
import Quickshell
import qs.components
import qs.services

// Volume OSD: appears bottom-center when the volume or mute state changes
// (keys, drawer sliders, anything, since all of them move the same Pipewire
// objects) and fades after a moment. Quiet while the drawer is open.
PanelWindow {
    id: osd

    visible: false

    anchors {
        bottom: true
    }

    margins {
        bottom: 120
    }

    exclusionMode: ExclusionMode.Ignore
    implicitWidth: 280
    implicitHeight: 48
    color: "transparent"

    // The Pipewire graph settles during startup; ignore that churn
    property bool ready: false

    Timer {
        interval: 2000
        running: true
        onTriggered: osd.ready = true
    }

    Timer {
        id: hide

        interval: 1400
        onTriggered: osd.visible = false
    }

    function poke() {
        if (!ready || Panels.controlsOpen)
            return;
        visible = true;
        hide.restart();
    }

    Connections {
        target: Audio

        function onVolumeChanged() {
            osd.poke();
        }

        function onMutedChanged() {
            osd.poke();
        }
    }

    Panel {
        anchors.fill: parent
        radius: height / 2

        Row {
            anchors.centerIn: parent
            spacing: 12

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Audio.muted ? "󰝟" : "󰕾"
                color: Audio.muted ? Theme.muted : Theme.fg
                font.family: Theme.font
                font.pixelSize: Theme.fontSize + 2
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 160
                height: 6
                radius: 3
                color: Theme.surface

                Rectangle {
                    width: Math.min(1, Audio.volume) * parent.width
                    height: parent.height
                    radius: 3
                    color: Audio.muted ? Theme.muted : Theme.accent
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Math.round(Audio.volume * 100) + "%"
                color: Theme.fg
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 1
            }
        }
    }
}
