import QtQuick
import qs.components
import qs.services

// Workspaces 1-5 always visible (matching the old persistent-workspaces
// setup), plus any further workspace that exists.
Row {
    id: root

    spacing: 6

    readonly property var shown: {
        const ids = [1, 2, 3, 4, 5];
        for (const ws of Workspaces.all) {
            if (!ids.includes(ws.id))
                ids.push(ws.id);
        }
        return ids.sort((a, b) => a - b);
    }

    Repeater {
        model: root.shown

        Rectangle {
            id: pill

            required property int modelData

            readonly property bool focused: Workspaces.focused?.id === modelData
            readonly property bool exists: Workspaces.all.some(ws => ws.id === pill.modelData)

            width: 22
            height: 22
            radius: 4
            color: focused ? Theme.accent : exists ? Theme.surface : "transparent"

            Text {
                anchors.centerIn: parent
                text: pill.modelData
                color: pill.focused ? Theme.bg : pill.exists ? Theme.fg : Theme.muted
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Workspaces.focus(pill.modelData)
            }
        }
    }
}
