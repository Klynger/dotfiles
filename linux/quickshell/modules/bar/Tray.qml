import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.components

// System tray icons: left click activates the app, right click opens its
// own menu.
Row {
    spacing: 10

    // An empty item still claims a slot in the parent layout, leaving double
    // spacing where the icons were; collapse instead
    visible: SystemTray.items.values.length > 0

    Repeater {
        model: SystemTray.items

        IconImage {
            id: icon

            required property var modelData

            implicitSize: 20
            source: modelData.icon

            QsMenuAnchor {
                id: menuAnchor

                menu: icon.modelData.menu
                anchor.item: icon
                anchor.edges: Edges.Top
                anchor.gravity: Edges.Top
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: event => {
                    if (event.button === Qt.RightButton && icon.modelData.hasMenu)
                        menuAnchor.open();
                    else
                        icon.modelData.activate();
                }
            }
        }
    }
}
