import QtQuick
import qs.components
import qs.services

// The bar bell, mirroring the old waybar/swaync states: left click opens the
// center, right click toggles do-not-disturb.
Text {
    text: {
        if (Notifs.dnd)
            return Notifs.all.length > 0 ? "󰂠" : "󰪓";
        return Notifs.all.length > 0 ? "󱅫" : "󰂜";
    }
    color: Notifs.dnd ? Theme.muted : Theme.fg
    font.family: Theme.font
    font.pixelSize: Theme.fontSize

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: event => {
            if (event.button === Qt.RightButton)
                Notifs.toggleDnd();
            else
                Notifs.toggleCenter();
        }
    }
}
