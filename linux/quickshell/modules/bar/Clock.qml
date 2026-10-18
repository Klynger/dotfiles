import QtQuick
import Quickshell
import qs.components
import qs.services

Text {
    text: Time.pretty
    color: Theme.fg
    font.family: Theme.font
    font.pixelSize: Theme.fontSize

    MouseArea {
        anchors.fill: parent
        onClicked: Quickshell.execDetached(["gtk-launch", "org.gnome.Calendar"])
    }
}
