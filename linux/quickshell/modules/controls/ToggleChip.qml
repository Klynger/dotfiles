import QtQuick
import qs.components

Rectangle {
    id: root

    property bool active: false
    property string label: ""

    signal toggled()

    radius: 6
    color: root.active
        ? (mouse.containsMouse ? Qt.lighter(Theme.accent, 1.15) : Theme.accent)
        : (mouse.containsMouse ? Theme.surface : Theme.bg)
    implicitHeight: 30
    implicitWidth: text.implicitWidth + 24

    Behavior on color {
        ColorAnimation {
            duration: 120
        }
    }

    Text {
        id: text

        anchors.centerIn: parent
        text: root.label
        color: root.active ? Theme.bg : Theme.fg
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 1
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
