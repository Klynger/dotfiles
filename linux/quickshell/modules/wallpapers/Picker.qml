import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.components
import qs.services

// The wallpaper picker: a glass sheet that slides up from the bottom edge,
// leaving the rest of the screen to the live preview. Two rows of tiles
// scroll sideways like a filmstrip; hovering or stepping onto a tile
// previews it behind the shell, enter (or click) keeps it and re-themes
// through change-wallpaper, escape puts the old one back.
PanelWindow {
    id: panel

    visible: Panels.wallpapersOpen

    // Bottom-anchored only, so the sheet centers itself: four tiles wide,
    // two rows tall, the rest of the screen left to the live preview
    anchors {
        bottom: true
    }

    margins {
        bottom: 8
    }

    exclusionMode: ExclusionMode.Ignore
    implicitWidth: 1244
    implicitHeight: content.implicitHeight + 28
    focusable: true
    color: "transparent"

    property bool applied: false
    property bool suppressPreview: false

    onVisibleChanged: {
        if (visible) {
            applied = false;
            Wallpapers.refresh();
            grid.forceActiveFocus();
            slideIn.restart();
            settle.restart();
        } else if (!applied) {
            Wallpapers.revert();
        }
    }

    // Opening is noisy: the sheet slides up under wherever the pointer
    // happens to rest (mapping alone fires hover enter there), and the
    // async model reset lands the view on tile 0 (an index change like any
    // other). Both would preview a wallpaper nobody picked, so hover and
    // previews only arm once the open has settled.
    Timer {
        id: settle

        interval: 400
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

    // The sheet rises from the bottom edge on every open. Sized by hand
    // instead of anchored, so the slide can drive y.
    Item {
        id: sheet

        width: parent.width
        height: parent.height

        ParallelAnimation {
            id: slideIn

            NumberAnimation {
                target: sheet
                property: "y"
                from: sheet.height
                to: 0
                duration: 300
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                target: sheet
                property: "opacity"
                from: 0
                to: 1
                duration: 180
            }
        }

        Panel {
            anchors.fill: parent
        }

        ColumnLayout {
            id: content

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 14
            }
            spacing: 8

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Wallpapers"
                    color: Theme.muted
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "enter keeps · esc reverts"
                    color: Theme.muted
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                }
            }

            GridView {
                id: grid

                Layout.fillWidth: true
                Layout.preferredHeight: 360
                clip: true

                // Rows of four scrolling vertically, two rows on screen:
                // stepping below the bottom row slides the strip up
                cellWidth: 304
                cellHeight: 180
                model: Wallpapers.files
                focus: true

                // Tiles cascade in whenever the model lands
                populate: Transition {
                    id: populateTr

                    SequentialAnimation {
                        PropertyAction {
                            property: "opacity"
                            value: 0
                        }

                        PauseAnimation {
                            duration: populateTr.ViewTransition.index * 18
                        }

                        ParallelAnimation {
                            NumberAnimation {
                                property: "opacity"
                                from: 0
                                to: 1
                                duration: 180
                            }

                            NumberAnimation {
                                property: "y"
                                from: populateTr.ViewTransition.destination.y + 60
                                to: populateTr.ViewTransition.destination.y
                                duration: 240
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }

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
                    if (panel.visible && !panel.suppressPreview && !settle.running && currentIndex >= 0)
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

                    // Hovering steps onto the tile, which previews it live
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onEntered: {
                            if (!settle.running)
                                grid.currentIndex = cell.index;
                        }

                        onClicked: {
                            grid.currentIndex = cell.index;
                            panel.applySelected();
                        }
                    }
                }
            }
        }
    }
}
