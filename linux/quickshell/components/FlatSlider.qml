import QtQuick
import qs.components

// A minimal horizontal slider on theme tokens; emits moved() while dragging.
Item {
    id: root

    property real value: 0
    signal moved(real value)

    implicitHeight: 18

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 6
        radius: 3
        color: Theme.bg

        Rectangle {
            width: Math.max(0, Math.min(1, root.value)) * parent.width
            height: parent.height
            radius: 3
            color: Theme.accent
        }
    }

    MouseArea {
        anchors.fill: parent

        function report(x: real) {
            root.moved(Math.max(0, Math.min(1, x / root.width)));
        }

        onPressed: event => report(event.x)
        onPositionChanged: event => {
            if (pressed)
                report(event.x);
        }
    }
}
