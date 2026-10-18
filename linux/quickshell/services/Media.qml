pragma Singleton

import Quickshell
import Quickshell.Services.Mpris

// The media player the bar and later the dashboard act on. playerctld
// proxies whichever player was used last, so prefer it when present, then
// anything playing, then any player at all.
Singleton {
    id: root

    readonly property MprisPlayer active: {
        const players = Mpris.players.values;
        return players.find(p => (p.dbusName ?? "").endsWith("playerctld"))
            ?? players.find(p => p.isPlaying)
            ?? players[0]
            ?? null;
    }

    readonly property bool hasPlayer: active !== null
    readonly property bool playing: active?.isPlaying ?? false
    readonly property string title: active?.trackTitle ?? ""
    readonly property string artist: active?.trackArtist ?? ""
    readonly property string artUrl: active?.trackArtUrl ?? ""

    function togglePlaying(): void {
        active?.togglePlaying();
    }

    function next(): void {
        active?.next();
    }
}
