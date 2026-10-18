import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.components
import qs.services

// The app launcher (phase 4, replacing rofi): type to filter, arrows to
// move, enter to launch, escape to close. An arithmetic query shows its
// result as the first row; enter copies it to the clipboard.
PanelWindow {
    id: panel

    visible: Panels.launcherOpen

    // No anchors on purpose: an unanchored layer surface sits centered
    implicitWidth: 560
    implicitHeight: 440
    exclusionMode: ExclusionMode.Ignore
    focusable: true
    color: "transparent"

    readonly property string calcResult: {
        const q = input.text.trim();
        if (!/^[\d\s()+\-*/.%]+$/.test(q) || !/\d/.test(q) || !/[+\-*/%]/.test(q))
            return "";
        try {
            const v = eval(q);
            return (typeof v === "number" && isFinite(v)) ? String(v) : "";
        } catch (e) {
            return "";
        }
    }

    readonly property var rows: {
        const r = [];
        if (calcResult !== "")
            r.push({ calc: true });
        for (const entry of Apps.search(input.text))
            r.push({ entry: entry });
        return r;
    }

    property int selected: 0

    onVisibleChanged: {
        if (visible) {
            input.text = "";
            selected = 0;
            input.forceActiveFocus();
        }
    }

    function activate() {
        const row = rows[selected];
        if (!row)
            return;
        if (row.calc)
            Quickshell.execDetached(["wl-copy", calcResult]);
        else
            row.entry.execute();
        Panels.launcherOpen = false;
    }

    HyprlandFocusGrab {
        windows: [panel]
        active: Panels.launcherOpen
        onCleared: Panels.launcherOpen = false
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.bg
        radius: 8
        border.color: Theme.surface
        border.width: 1

        ColumnLayout {
            anchors {
                fill: parent
                margins: 12
            }
            spacing: 10

            RowLayout {
                spacing: 8
                Layout.fillWidth: true

                Text {
                    text: "󰍉"
                    color: Theme.muted
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize + 2
                }

                TextInput {
                    id: input

                    color: Theme.fg
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize + 2
                    clip: true
                    Layout.fillWidth: true

                    onTextChanged: panel.selected = 0

                    Keys.onDownPressed: panel.selected = Math.min(panel.selected + 1, panel.rows.length - 1)
                    Keys.onUpPressed: panel.selected = Math.max(panel.selected - 1, 0)
                    Keys.onReturnPressed: panel.activate()
                    Keys.onEnterPressed: panel.activate()
                    Keys.onEscapePressed: Panels.launcherOpen = false

                    // ctrl+n / ctrl+p move like rofi (and nvim) did
                    Keys.onPressed: event => {
                        if (!(event.modifiers & Qt.ControlModifier))
                            return;
                        if (event.key === Qt.Key_N) {
                            panel.selected = Math.min(panel.selected + 1, panel.rows.length - 1);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_P) {
                            panel.selected = Math.max(panel.selected - 1, 0);
                            event.accepted = true;
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.surface
            }

            ListView {
                id: list

                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: panel.rows
                currentIndex: panel.selected

                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                delegate: Rectangle {
                    id: row

                    required property var modelData
                    required property int index

                    width: list.width
                    height: 44
                    radius: 6
                    color: index === panel.selected ? Theme.surface : "transparent"

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 10
                            rightMargin: 10
                        }
                        spacing: 10

                        Text {
                            visible: row.modelData.calc ?? false
                            text: "="
                            color: Theme.accent
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize + 2
                        }

                        IconImage {
                            visible: !(row.modelData.calc ?? false) && source.toString() !== ""
                            source: row.modelData.entry ? Quickshell.iconPath(row.modelData.entry.icon, true) : ""
                            implicitSize: 26
                        }

                        ColumnLayout {
                            spacing: 0
                            Layout.fillWidth: true

                            Text {
                                text: (row.modelData.calc ?? false)
                                    ? panel.calcResult + "   (enter copies)"
                                    : row.modelData.entry.name
                                color: Theme.fg
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSize
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                visible: !(row.modelData.calc ?? false) && row.modelData.entry.comment !== ""
                                text: row.modelData.calc ? "" : row.modelData.entry.comment
                                color: Theme.muted
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSize - 3
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: panel.selected = row.index
                        onClicked: panel.activate()
                    }
                }
            }
        }
    }
}
