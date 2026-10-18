pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// The notification server: the shell owns org.freedesktop.Notifications
// (replacing swaync), so popups, the bar bell and the center all read one
// state. Everything is tracked into history; popups are the recent subset
// still on screen, and do-not-disturb only silences popups, never history.
Singleton {
    id: root

    // How long a popup stays, in ms, when the app does not ask for a
    // specific expiry itself. Critical notifications never auto-expire.
    property int popupTimeout: 6000

    property bool dnd: false
    property bool centerOpen: false

    readonly property var all: server.trackedNotifications.values

    property var popups: []

    NotificationServer {
        id: server

        actionsSupported: true
        bodySupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: notif => {
            notif.tracked = true;
            if (!root.dnd)
                root.popups = root.popups.concat([notif]);
        }
    }

    function removePopup(notif) {
        root.popups = root.popups.filter(p => p !== notif);
    }

    function dismissAll(): void {
        const tracked = [...server.trackedNotifications.values];
        tracked.forEach(n => n.dismiss());
        root.popups = [];
    }

    function toggleCenter(): void {
        root.centerOpen = !root.centerOpen;
    }

    function toggleDnd(): void {
        root.dnd = !root.dnd;
        if (root.dnd)
            root.popups = [];
    }
}
