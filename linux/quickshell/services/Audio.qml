pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

// Default sink and source state. The same Pipewire objects every widget,
// OSD and mixer will read, so they can never disagree.
Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real micVolume: source?.audio?.volume ?? 0
    readonly property bool micMuted: source?.audio?.muted ?? false

    // Nodes only expose their audio properties while bound
    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    function setVolume(value: real): void {
        if (sink?.ready && sink?.audio)
            sink.audio.volume = Math.max(0, Math.min(1, value));
    }

    function toggleMute(): void {
        if (sink?.audio)
            sink.audio.muted = !sink.audio.muted;
    }
}
