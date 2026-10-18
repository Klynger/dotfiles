import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components

// Still anchored to the bottom edge, out of waybar's way, until the cutover
// flips it to the top.
PanelWindow {
    anchors {
        bottom: true
        left: true
        right: true
    }

    implicitHeight: Theme.barHeight
    color: Theme.bg

    WorkspacePills {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
    }

    NowPlaying {
        anchors.centerIn: parent
    }

    RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 18

        Volume {}
        Stats {}
        Tray {}
        ExecButton { text: "󰂯"; command: ["launch-tui", "bluetui"] }
        NetworkStatus {}
        Clock {}
        ExecButton { text: "󰂜"; command: ["swaync-client", "-t", "-sw"] }
        ExecButton { text: "⏻"; command: ["wlogout", "-b", "5"] }
    }
}
