import QtQuick
import qs.components
import qs.services

Text {
    text: Time.pretty
    color: Panels.calendarOpen ? Theme.accent : Theme.fg
    font.family: Theme.font
    font.pixelSize: Theme.fontSize

    MouseArea {
        anchors.fill: parent
        onClicked: Panels.toggleCalendar()
    }
}
