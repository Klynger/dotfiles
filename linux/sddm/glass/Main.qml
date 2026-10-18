import QtQuick

// The login screen, mirroring the quickshell lock screen (modules/lock):
// wallpaper, dark scrim, big clock and a glass password pill. Colors are
// the shell's static Tokyo Night dark tokens (components/Theme.qml); sddm
// runs before the user session, so it cannot follow the light/dark switch.
Rectangle {
    id: root

    width: Screen.width || 1920
    height: Screen.height || 1080

    readonly property color bg: "#1a1b26"
    readonly property color surface: "#73222638"
    readonly property color fg: "#c0caf5"
    readonly property color muted: "#787fa5"
    readonly property color error: "#f7768e"
    // The Nerd Font build lives in the user's home, which sddm cannot read;
    // the plain family ships system-wide via adwaita-fonts
    readonly property string font: "Adwaita Mono"

    property string currentUser: userModel.lastUser || "User"
    property bool failed: false
    property int sessionIndex: {
        for (var i = 0; i < sessionModel.rowCount(); i++) {
            var name = (sessionModel.data(sessionModel.index(i, 0), Qt.DisplayRole) || "").toString();
            if (name.toLowerCase().indexOf("uwsm") !== -1 || name.toLowerCase().indexOf("hyprland") !== -1)
                return i;
        }
        return sessionModel.lastIndex;
    }

    color: bg

    Connections {
        target: sddm

        function onLoginFailed() {
            root.failed = true;
            password.text = "";
            password.forceActiveFocus();
        }
    }

    Image {
        id: wallpaper

        anchors.fill: parent
        source: "background.jpg"
        fillMode: Image.PreserveAspectCrop
        visible: status === Image.Ready
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: wallpaper.status === Image.Ready ? 0.45 : 0
    }

    Column {
        anchors.centerIn: parent
        spacing: 10

        Text {
            id: clock

            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(new Date(), "HH:mm")
            color: root.fg
            font.family: root.font
            font.pixelSize: 96
            font.bold: true

            Timer {
                interval: 10000
                running: true
                repeat: true
                onTriggered: {
                    clock.text = Qt.formatDateTime(new Date(), "HH:mm");
                    dateLabel.text = Qt.formatDateTime(new Date(), "dddd, dd MMMM");
                }
            }
        }

        Text {
            id: dateLabel

            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(new Date(), "dddd, dd MMMM")
            color: root.fg
            font.family: root.font
            font.pixelSize: 15
        }

        Item {
            width: 1
            height: 24
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.currentUser
            color: root.muted
            font.family: root.font
            font.pixelSize: 13
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 320
            height: 44
            radius: 22
            color: root.bg
            opacity: 0.9
            border.color: root.failed ? root.error : root.surface
            border.width: 1

            TextInput {
                id: password

                anchors {
                    fill: parent
                    leftMargin: 18
                    rightMargin: 18
                }
                verticalAlignment: TextInput.AlignVCenter
                echoMode: TextInput.Password
                color: root.fg
                font.family: root.font
                font.pixelSize: 13
                clip: true

                onAccepted: sddm.login(root.currentUser, text, root.sessionIndex)

                Component.onCompleted: forceActiveFocus()
            }

            Text {
                anchors.centerIn: parent
                visible: password.text === ""
                text: "Password"
                color: root.muted
                font.family: root.font
                font.pixelSize: 13
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.failed
            text: "Authentication failed"
            color: root.error
            font.family: root.font
            font.pixelSize: 12
        }
    }
}
