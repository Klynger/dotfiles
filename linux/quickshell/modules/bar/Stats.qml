import QtQuick
import Quickshell
import qs.components
import qs.services

Text {
    text: "TEMP " + SysStats.tempC + "°C  CPU " + SysStats.cpuPercent + "%  RAM " + SysStats.memPercent + "%"
    color: Theme.fg
    font.family: Theme.font
    font.pixelSize: Theme.fontSize

    MouseArea {
        anchors.fill: parent
        onClicked: Quickshell.execDetached(["gtk-launch", "btop"])
    }
}
