import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.services

// The center of the bar: album art and
// track when something plays, the focused window title otherwise. Click
// opens the quick panel, middle click toggles playback, right click skips.
Item {
    id: root

    readonly property bool showingMedia: Media.hasPlayer && Media.title !== ""

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    RowLayout {
        id: row

        spacing: 8

        Image {
            visible: root.showingMedia && Media.artUrl !== ""
            source: Media.artUrl
            sourceSize.width: 20
            sourceSize.height: 20
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
        }

        Text {
            text: root.showingMedia
                ? (Media.artist !== "" ? Media.artist + " - " : "") + Media.title
                : Focus.windowTitle
            color: Theme.fg
            font.family: Theme.font
            font.pixelSize: Theme.fontSize
            elide: Text.ElideRight
            Layout.maximumWidth: 480
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

        onClicked: event => {
            if (event.button === Qt.MiddleButton)
                Media.togglePlaying();
            else if (event.button === Qt.RightButton)
                Media.next();
            else
                Panels.toggleDashboard();
        }
    }
}
