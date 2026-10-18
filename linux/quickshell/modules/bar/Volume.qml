import QtQuick
import Quickshell
import qs.components
import qs.services

// Click opens pavucontrol, middle
// click mutes the sink, scrolling nudges the volume by 1%.
Text {
    text: {
        const vol = Audio.muted ? "VOL muted" : "VOL " + Math.round(Audio.volume * 100) + "%";
        const mic = Audio.micMuted ? "MIC off" : "MIC " + Math.round(Audio.micVolume * 100) + "%";
        return vol + "    " + mic;
    }
    color: Theme.fg
    font.family: Theme.font
    font.pixelSize: Theme.fontSize

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton

        onClicked: event => {
            if (event.button === Qt.MiddleButton)
                Audio.toggleMute();
            else
                Quickshell.execDetached(["pavucontrol"]);
        }

        onWheel: wheel => {
            Audio.setVolume(Audio.volume + (wheel.angleDelta.y > 0 ? 0.01 : -0.01));
        }
    }
}
