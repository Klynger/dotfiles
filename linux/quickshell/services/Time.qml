pragma Singleton

import Quickshell

Singleton {
    readonly property SystemClock clock: SystemClock {
        precision: SystemClock.Minutes
    }

    readonly property string pretty: Qt.formatDateTime(clock.date, "ddd dd MMM   HH:mm")
}
