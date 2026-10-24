import QtQuick
import qs.components
import qs.services

// Opens the controls drawer, which carries the power row.
Text {
    text: "⏻"
    color: Panels.controlsOpen ? Theme.accent : Theme.fg
    font.family: Theme.font
    font.pixelSize: Theme.barIconSize

    MouseArea {
        anchors.fill: parent
        onClicked: Panels.toggleControls()
    }
}
