import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import qs.components
import qs.services

// One notification, shared by the popups and the center. Clicking the card
// invokes the app's default action when it has one, otherwise dismisses.
Rectangle {
    id: card

    required property var notif
    property bool popup: false

    color: Theme.surface
    radius: 6
    implicitHeight: content.implicitHeight + 20

    // Popups fold away on their own, honoring the app's requested expiry
    // when it set one; critical ones stay until acted on
    Timer {
        interval: card.notif.expireTimeout > 0 ? card.notif.expireTimeout : Notifs.popupTimeout
        running: card.popup && card.notif.urgency !== NotificationUrgency.Critical
        onTriggered: Notifs.removePopup(card.notif)
    }

    // The app can retract its own notification while a popup shows it
    Connections {
        target: card.notif

        function onClosed() {
            Notifs.removePopup(card.notif);
        }
    }

    MouseArea {
        anchors.fill: parent

        onClicked: {
            const def = card.notif.actions.find(a => a.identifier === "default");
            if (def)
                def.invoke();
            else
                card.notif.dismiss();
            Notifs.removePopup(card.notif);
        }
    }

    ColumnLayout {
        id: content

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 10
            rightMargin: 10
        }
        spacing: 6

        RowLayout {
            spacing: 8
            Layout.fillWidth: true

            IconImage {
                visible: source.toString() !== ""
                source: {
                    if (card.notif.image !== "")
                        return card.notif.image;
                    if (card.notif.appIcon !== "")
                        return Quickshell.iconPath(card.notif.appIcon, true);
                    return "";
                }
                implicitSize: 28
            }

            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true

                Text {
                    visible: card.notif.appName !== ""
                    text: card.notif.appName
                    color: Theme.muted
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 3
                }

                Text {
                    text: card.notif.summary
                    color: Theme.fg
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    visible: card.notif.body !== ""
                    text: card.notif.body
                    color: Theme.muted
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 1
                    wrapMode: Text.Wrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    textFormat: Text.StyledText
                    Layout.fillWidth: true
                }
            }

            Text {
                text: "✕"
                color: Theme.muted
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
                Layout.alignment: Qt.AlignTop

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6

                    onClicked: {
                        card.notif.dismiss();
                        Notifs.removePopup(card.notif);
                    }
                }
            }
        }

        RowLayout {
            visible: actionRepeater.count > 0
            spacing: 6

            Repeater {
                id: actionRepeater

                model: card.notif.actions.filter(a => a.identifier !== "default")

                Rectangle {
                    required property var modelData

                    color: Theme.bg
                    radius: 4
                    implicitWidth: actionText.implicitWidth + 16
                    implicitHeight: actionText.implicitHeight + 8

                    Text {
                        id: actionText

                        anchors.centerIn: parent
                        text: parent.modelData.text
                        color: Theme.accent
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 1
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            parent.modelData.invoke();
                            Notifs.removePopup(card.notif);
                        }
                    }
                }
            }
        }
    }
}
