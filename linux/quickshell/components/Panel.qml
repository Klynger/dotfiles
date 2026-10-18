import QtQuick
import qs.components

// The glass surface every shell panel sits on: translucent fill over the
// compositor blur, a faint rim, and a small spring when its window appears.
Rectangle {
    id: root

    color: Theme.panel
    radius: Theme.radius
    border.color: Theme.panelBorder
    border.width: 1

    transformOrigin: Item.Center

    Connections {
        target: root.Window.window

        function onVisibleChanged() {
            if (root.Window.window.visible)
                pop.restart();
        }
    }

    ParallelAnimation {
        id: pop

        NumberAnimation {
            target: root
            property: "scale"
            from: 0.96
            to: 1
            duration: 180
            easing.type: Easing.OutBack
        }

        NumberAnimation {
            target: root
            property: "opacity"
            from: 0.4
            to: 1
            duration: 140
            easing.type: Easing.OutQuad
        }
    }
}
