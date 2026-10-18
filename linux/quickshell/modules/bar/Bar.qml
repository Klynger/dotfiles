import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components

// A floating glass pill along the top edge.
PanelWindow {
    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: 8
        left: 8
        right: 8
    }

    implicitHeight: Theme.barHeight
    color: "transparent"

    Panel {
        anchors.fill: parent
        radius: Theme.barHeight / 2
    }

    WorkspacePills {
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.verticalCenter: parent.verticalCenter
    }

    NowPlaying {
        anchors.centerIn: parent
    }

    RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 18

        Volume {}
        Stats {}
        Tray {}
        BtIndicator {}
        NetworkStatus {}
        Clock {}
        ThemeSwitch {}
        NotifButton {}
        ControlsButton {}
    }
}
