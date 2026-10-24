import QtQuick
import Quickshell
import qs.components

// A bar button that only shells out, bridging to the parts of the old stack
// the shell has not absorbed (bluetui).
Text {
    id: root

    required property var command

    color: Theme.fg
    font.family: Theme.font
    font.pixelSize: Theme.barIconSize

    MouseArea {
        anchors.fill: parent
        onClicked: Quickshell.execDetached(root.command)
    }
}
