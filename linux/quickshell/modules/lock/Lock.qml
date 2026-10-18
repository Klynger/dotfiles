import QtQuick
import Quickshell
import Quickshell.Services.Pam
import Quickshell.Wayland
import qs.components
import qs.services

// The lock screen (phase 6): ext-session-lock, so the compositor guarantees
// nothing else shows while locked. Authentication goes through PAM, and
// PAM's own messages (faillock warnings included) are shown verbatim, since
// wrong attempts count toward the system lockout.
Scope {
    id: lockRoot

    property string pendingPassword: ""
    property string status: ""
    property bool failed: false

    function submit(password: string): void {
        if (pam.active)
            return;
        pendingPassword = password;
        failed = false;
        status = "Checking…";
        pam.start();
    }

    PamContext {
        id: pam

        config: "login"

        onPamMessage: {
            if (responseRequired)
                respond(lockRoot.pendingPassword);
            else
                lockRoot.status = message;
        }

        onCompleted: result => {
            lockRoot.pendingPassword = "";
            if (result === PamResult.Success) {
                lockRoot.status = "";
                lockRoot.failed = false;
                Locker.unlock();
            } else {
                lockRoot.failed = true;
                if (lockRoot.status === "Checking…")
                    lockRoot.status = "Wrong password";
            }
        }

        onError: {
            lockRoot.pendingPassword = "";
            lockRoot.failed = true;
            lockRoot.status = "PAM error";
        }
    }

    WlSessionLock {
        id: sessionLock

        locked: Locker.locked

        WlSessionLockSurface {
            color: Theme.bg

            Image {
                anchors.fill: parent
                visible: Locker.wallpaper !== ""
                source: Locker.wallpaper === "" ? "" : "file://" + Locker.wallpaper
                fillMode: Image.PreserveAspectCrop
            }

            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: 0.45
            }

            Column {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(Time.clock.date, "HH:mm")
                    color: Theme.fg
                    font.family: Theme.font
                    font.pixelSize: 96
                    font.bold: true
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(Time.clock.date, "dddd, dd MMMM")
                    color: Theme.fg
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize + 2
                }

                Item {
                    width: 1
                    height: 24
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 320
                    height: 44
                    radius: 22
                    color: Theme.bg
                    opacity: 0.9
                    border.color: lockRoot.failed ? "#f7768e" : Theme.surface
                    border.width: 1

                    TextInput {
                        id: input

                        anchors {
                            fill: parent
                            leftMargin: 18
                            rightMargin: 18
                        }
                        verticalAlignment: TextInput.AlignVCenter
                        echoMode: TextInput.Password
                        color: Theme.fg
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize
                        clip: true

                        onAccepted: {
                            lockRoot.submit(text);
                            text = "";
                        }

                        Component.onCompleted: forceActiveFocus()
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: input.text === "" && !pam.active
                        text: "Password"
                        color: Theme.muted
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 420
                    horizontalAlignment: Text.AlignHCenter
                    visible: lockRoot.status !== ""
                    text: lockRoot.status
                    color: lockRoot.failed ? "#f7768e" : Theme.fg
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 1
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}
