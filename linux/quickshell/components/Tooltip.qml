import QtQuick
import qs.components

// A small label that fades in above its parent while it stays hovered,
// after a short pause so sweeping the pointer across a row stays quiet.
// Drop it inside any icon-only button and feed it the button's hover state.
Rectangle {
    id: root

    required property string label
    required property bool hovered

    anchors {
        horizontalCenter: parent.horizontalCenter
        bottom: parent.top
        bottomMargin: 6
    }
    implicitWidth: text.implicitWidth + 16
    implicitHeight: text.implicitHeight + 8
    radius: Theme.radiusSmall
    color: Theme.bg
    border.color: Theme.surface
    border.width: 1
    opacity: 0
    visible: opacity > 0

    onHoveredChanged: {
        if (hovered) {
            delay.restart();
        } else {
            delay.stop();
            opacity = 0;
        }
    }

    Timer {
        id: delay

        interval: 350
        onTriggered: root.opacity = 1
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 120
        }
    }

    Text {
        id: text

        anchors.centerIn: parent
        text: root.label
        color: Theme.fg
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 2
    }
}
