import QtQuick
import qs.components
import qs.services

// Opens the controls drawer, which carries the power row that used to be
// wlogout's job.
Text {
    text: "⏻"
    color: Panels.controlsOpen ? Theme.accent : Theme.fg
    font.family: Theme.font
    font.pixelSize: Theme.fontSize

    MouseArea {
        anchors.fill: parent
        onClicked: Panels.toggleControls()
    }
}
