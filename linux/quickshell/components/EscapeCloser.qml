import QtQuick

// Escape dismisses the popover this sits in. The window needs
// focusable: true so it takes keyboard focus while open; the scope
// grabs that focus on every open and turns the key into the signal.
FocusScope {
    id: root

    signal dismissed()

    anchors.fill: parent
    focus: true

    Connections {
        target: root.Window.window

        function onVisibleChanged() {
            if (root.Window.window.visible)
                root.forceActiveFocus();
        }
    }

    Keys.onEscapePressed: root.dismissed()
}
