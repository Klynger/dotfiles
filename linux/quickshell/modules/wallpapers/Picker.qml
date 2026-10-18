import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.components
import qs.services

// The wallpaper picker (phase 5, replacing the rofi-based pick-wallpaper):
// a grid of the collection; clicking one applies it and regenerates the
// theme through change-wallpaper.
PanelWindow {
    id: panel

    visible: Panels.wallpapersOpen

    // Unanchored: centered on the output
    implicitWidth: 960
    implicitHeight: 600
    exclusionMode: ExclusionMode.Ignore
    focusable: true
    color: "transparent"

    onVisibleChanged: {
        if (visible) {
            Wallpapers.refresh();
            grid.forceActiveFocus();
        }
    }


    function applySelected() {
        const path = Wallpapers.files[grid.currentIndex];
        if (!path)
            return;
        Wallpapers.apply(path);
        Panels.wallpapersOpen = false;
    }

    HyprlandFocusGrab {
        windows: [panel]
        active: Panels.wallpapersOpen
        onCleared: Panels.wallpapersOpen = false
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.bg
        radius: 8
        border.color: Theme.surface
        border.width: 1

        GridView {
            id: grid

            anchors {
                fill: parent
                margins: 12
            }
            clip: true
            cellWidth: 304
            cellHeight: 180
            model: Wallpapers.files
            focus: true

            // The model arrives async and resets the selection; land on the
            // first tile whenever that happens
            onCountChanged: {
                if (count > 0 && currentIndex < 0)
                    currentIndex = 0;
            }

            // Arrows move natively; ctrl+hjkl matches the vim muscle memory,
            // enter applies, escape closes
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

                width: grid.cellWidth
                height: grid.cellHeight

                Image {
                    id: thumb

                    anchors {
                        fill: parent
                        margins: 6
                    }
                    source: "file://" + cell.modelData
                    sourceSize.width: 292
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }

                Rectangle {
                    anchors {
                        fill: parent
                        margins: 3
                    }
                    visible: cell.index === grid.currentIndex
                    color: "transparent"
                    border.color: Theme.accent
                    border.width: 3
                    radius: 4
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
