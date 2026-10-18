pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// CPU, memory and CPU-die temperature, sampled every few seconds. One shell
// pipeline per tick; the CPU percentage is the delta between ticks. The
// temperature sensor is found by name (k10temp on AMD) instead of trusting
// hwmon numbering, which shifts between boots.
Singleton {
    id: root

    property int cpuPercent: 0
    property int memPercent: 0
    property int tempC: 0

    property real lastBusy: 0
    property real lastTotal: 0

    Process {
        id: sample

        command: ["sh", "-c",
            "read -r _ u n s idle io irq sirq steal _ < /proc/stat; " +
            "busy=$((u + n + s + irq + sirq + steal)); total=$((busy + idle + io)); " +
            "mem=$(awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf \"%d\", (t - a) * 100 / t}' /proc/meminfo); " +
            "hw=$(grep -ls k10temp /sys/class/hwmon/*/name | head -n1); " +
            "temp=0; [ -n \"$hw\" ] && temp=$(cat \"${hw%name}temp1_input\"); " +
            "echo \"$busy $total $mem $temp\""]

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(" ");
                if (parts.length < 4)
                    return;
                const busy = Number(parts[0]);
                const total = Number(parts[1]);
                if (root.lastTotal > 0 && total > root.lastTotal)
                    root.cpuPercent = Math.round((busy - root.lastBusy) * 100 / (total - root.lastTotal));
                root.lastBusy = busy;
                root.lastTotal = total;
                root.memPercent = Number(parts[2]);
                root.tempC = Math.round(Number(parts[3]) / 1000);
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: sample.running = true
    }
}
