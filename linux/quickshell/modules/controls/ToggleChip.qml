import QtQuick
import qs.components

Rectangle {
    id: root

    property bool active: false
    property string label: ""

    signal toggled()

    radius: 6
    color: active ? Theme.accent : Theme.bg
    implicitHeight: 30
    implicitWidth: text.implicitWidth + 24

    Text {
        id: text

        anchors.centerIn: parent
        text: root.label
        color: root.active ? Theme.bg : Theme.fg
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 1
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.toggled()
    }
}
