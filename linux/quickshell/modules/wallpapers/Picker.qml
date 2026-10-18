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
        if (visible)
            Wallpapers.refresh();
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

            Keys.onEscapePressed: Panels.wallpapersOpen = false

            delegate: Item {
                required property string modelData

                width: grid.cellWidth
                height: grid.cellHeight

                Image {
                    id: thumb

                    anchors {
                        fill: parent
                        margins: 6
                    }
                    source: "file://" + parent.modelData
                    sourceSize.width: 292
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        Wallpapers.apply(parent.modelData);
                        Panels.wallpapersOpen = false;
                    }
                }
            }
        }
    }
}
