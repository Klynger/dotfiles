pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

// Default sink and source state, every output device and every app playback
// stream: one view of the Pipewire graph shared by the bar, the mixer, the
// OSD and the mute key, so they can never disagree.
Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream)
    readonly property var streams: Pipewire.nodes.values.filter(n => n.type === PwNodeType.AudioOutStream)

    // What the mixer shows: real apps, not the virtmic chain's loopbacks
    // (pipewire's loopback module names them output.loopback-<pid>-<n>)
    readonly property var appStreams: streams.filter(n => !n.name.includes("loopback"))

    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real micVolume: source?.audio?.volume ?? 0
    readonly property bool micMuted: source?.audio?.muted ?? false

    // Nodes only expose their audio properties while bound
    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    PwObjectTracker {
        objects: root.sinks
    }

    PwObjectTracker {
        objects: root.streams
    }

    function setVolume(value: real): void {
        if (sink?.ready && sink?.audio)
            sink.audio.volume = Math.max(0, Math.min(1, value));
    }

    function toggleMute(): void {
        if (sink?.audio)
            sink.audio.muted = !sink.audio.muted;
    }

    function setDefaultSink(node: PwNode): void {
        Pipewire.preferredDefaultAudioSink = node;
    }

    // The connected successor to bin/toggle-mute-all: flips every output
    // device together so apps routed to another device go silent too.
    // virtmic is the microphone chain, not a listening device; it stays
    // untouched.
    function muteAll(): void {
        const state = !(sink?.audio?.muted ?? false);
        for (const n of sinks) {
            if (n.name !== "virtmic" && n.audio)
                n.audio.muted = state;
        }
    }

    // The volume keys, same philosophy as muteAll: nudge every output
    // device, so the keys work no matter which device the sound is
    // actually routed to. Each device keeps its own level, shifted
    // together.
    function changeVolumeAll(delta: real): void {
        for (const n of sinks) {
            if (n.name !== "virtmic" && n.audio)
                n.audio.volume = Math.max(0, Math.min(1, n.audio.volume + delta));
        }
    }

    // A human name for a mixer row's stream; || because the fields can be
    // empty strings, not just missing
    function appName(node: PwNode): string {
        return node.properties["application.name"] || node.nickname || node.description || node.name || "Unknown";
    }
}
