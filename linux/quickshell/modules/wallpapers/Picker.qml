import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.components
import qs.services

// The wallpaper picker: a glass grid where stepping through tiles previews
// the wallpaper live behind the panel; enter (or click) keeps it and
// re-themes through change-wallpaper, escape puts the old one back.
PanelWindow {
    id: panel

    visible: Panels.wallpapersOpen

    // Unanchored: centered on the output
    implicitWidth: 960
    implicitHeight: 600
    exclusionMode: ExclusionMode.Ignore
    focusable: true
    color: "transparent"

    property bool applied: false
    property bool suppressPreview: false

    onVisibleChanged: {
        if (visible) {
            applied = false;
            Wallpapers.refresh();
            grid.forceActiveFocus();
        } else if (!applied) {
            Wallpapers.revert();
        }
    }

    function applySelected() {
        const path = Wallpapers.files[grid.currentIndex];
        if (!path)
            return;
        applied = true;
        Wallpapers.apply(path);
        Panels.wallpapersOpen = false;
    }

    Timer {
        id: previewTimer

        interval: 250
        onTriggered: {
            const path = Wallpapers.files[grid.currentIndex];
            if (path && panel.visible)
                Wallpapers.preview(path);
        }
    }

    HyprlandFocusGrab {
        windows: [panel]
        active: Panels.wallpapersOpen
        onCleared: Panels.wallpapersOpen = false
    }

    Panel {
        anchors.fill: parent

        GridView {
            id: grid

            anchors {
                fill: parent
                margins: 14
            }
            clip: true
            cellWidth: 304
            cellHeight: 180
            model: Wallpapers.files
            focus: true

            // The model arrives async and resets the selection; land on the
            // first tile whenever that happens, without previewing it
            onCountChanged: {
                if (count > 0 && currentIndex < 0) {
                    panel.suppressPreview = true;
                    currentIndex = 0;
                    panel.suppressPreview = false;
                }
            }

            onCurrentIndexChanged: {
                if (panel.visible && !panel.suppressPreview && currentIndex >= 0)
                    previewTimer.restart();
            }

            // Arrows move natively; ctrl+hjkl matches the vim muscle memory,
            // enter applies, escape closes and reverts
            Keys.onEscapePressed: Panels.wallpapersOpen = false
            Keys.onReturnPressed: panel.applySelected()
            Keys.onEnterPressed: panel.applySelected()

            Keys.onPressed: event => {
                if (!(event.modifiers & Qt.ControlModifier))
                    return;
                if (event.key === Qt.Key_H)
                    grid.moveCurrentIndexLeft();
                else if (event.key === Qt.Key_L)
                    grid.moveCurrentIndexRight();
                else if (event.key === Qt.Key_J)
                    grid.moveCurrentIndexDown();
                else if (event.key === Qt.Key_K)
                    grid.moveCurrentIndexUp();
                else
                    return;
                event.accepted = true;
            }

            delegate: Item {
                id: cell

                required property string modelData
                required property int index

                readonly property bool current: index === grid.currentIndex

                width: grid.cellWidth
                height: grid.cellHeight

                ClippingRectangle {
                    anchors {
                        fill: parent
                        margins: 7
                    }
                    radius: Theme.radiusSmall
                    color: Theme.surface
                    scale: cell.current ? 1.04 : 0.97

                    Behavior on scale {
                        NumberAnimation {
                            duration: 160
                            easing.type: Easing.OutBack
                        }
                    }

                    Image {
                        anchors.fill: parent
                        source: "file://" + cell.modelData
                        sourceSize.width: 292
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }
                }

                Rectangle {
                    anchors {
                        fill: parent
                        margins: 7
                    }
                    visible: cell.current
                    scale: 1.04
                    color: "transparent"
                    border.color: Theme.accent
                    border.width: 2
                    radius: Theme.radiusSmall
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        grid.currentIndex = cell.index;
                        panel.applySelected();
                    }
                }
            }
        }
    }
}
