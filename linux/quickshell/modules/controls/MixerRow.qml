import QtQuick
import QtQuick.Layouts
import qs.components

// One Pipewire node in the mixer: label, volume slider, mute. Used for both
// output devices and app streams; devices add the default marker.
RowLayout {
    id: root

    required property var node
    required property string label
    property bool showDefault: false
    property bool isDefault: false

    signal makeDefault()

    spacing: 10

    Text {
        visible: root.showDefault
        text: root.isDefault ? "●" : "○"
        color: root.isDefault || defaultMouse.containsMouse ? Theme.accent : Theme.muted
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 2

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }

        MouseArea {
            id: defaultMouse

            anchors.fill: parent
            anchors.margins: -6
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.makeDefault()
        }
    }

    Text {
        text: root.label
        color: Theme.fg
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 1
        elide: Text.ElideRight
        Layout.preferredWidth: 130
    }

    FlatSlider {
        value: root.node.audio?.volume ?? 0
        onMoved: value => {
            if (root.node.audio)
                root.node.audio.volume = value;
        }
        Layout.fillWidth: true
    }

    Text {
        text: (root.node.audio?.muted ?? false) ? "󰝟" : "󰕾"
        color: muteMouse.containsMouse ? Theme.accent : ((root.node.audio?.muted ?? false) ? Theme.muted : Theme.fg)
        font.family: Theme.font
        font.pixelSize: Theme.fontSize

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }

        MouseArea {
            id: muteMouse

            anchors.fill: parent
            anchors.margins: -6
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.node.audio)
                    root.node.audio.muted = !root.node.audio.muted;
            }
        }
    }
}
