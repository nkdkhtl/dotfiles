pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

Singleton {
    id: root

    property string name: "AMD Radeon 680M"
    property real percentage: 0.0
    property real temperature: 0.0
    property bool hasGpu: true

    property string busyPath: "/sys/class/drm/card1/device/gpu_busy_percent"
    property string tempPath: "/sys/class/drm/card1/device/hwmon/hwmon4/temp1_input"

    property int refCount: 0

    function addRef(): void {
        refCount++;
        if (refCount === 1) {
            updateMetrics();
        }
    }

    function removeRef(): void {
        refCount = Math.max(0, refCount - 1);
    }

    function updateMetrics(): void {
        if (busyView.path)
            busyView.reload();
        if (tempView.path)
            tempView.reload();
    }

    Process {
        id: initProc

        running: true
        command: [
            "sh", "-c",
            "for card in /sys/class/drm/card[0-9]*; do\n" +
            "  [ -f \"$card/device/vendor\" ] || continue\n" +
            "  if [ \"$(cat \"$card/device/vendor\" 2>/dev/null)\" = \"0x1002\" ]; then\n" +
            "    echo \"CARD:$card\"\n" +
            "    [ -f \"$card/device/gpu_busy_percent\" ] && echo \"BUSY:$card/device/gpu_busy_percent\"\n" +
            "    temp=$(ls \"$card/device/hwmon\"/hwmon*/temp1_input 2>/dev/null | head -1)\n" +
            "    [ -n \"$temp\" ] && echo \"TEMP:$temp\"\n" +
            "    slot=$(basename \"$(readlink -f \"$card/device\")\" 2>/dev/null)\n" +
            "    echo \"NAME:$(lspci -s \"$slot\" 2>/dev/null)\"\n" +
            "    break\n" +
            "  fi\n" +
            "done\n"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                for (const line of lines) {
                    if (line.startsWith("CARD:")) {
                        root.hasGpu = true;
                    } else if (line.startsWith("BUSY:")) {
                        const p = line.substring(5).trim().split(" ")[0];
                        if (p && !p.includes("*")) {
                            root.busyPath = p;
                        }
                    } else if (line.startsWith("TEMP:")) {
                        const p = line.substring(5).trim().split(" ")[0];
                        if (p && !p.includes("*")) {
                            root.tempPath = p;
                        }
                    } else if (line.startsWith("NAME:")) {
                        const n = line.substring(5).trim();
                        const matches = n.match(/\[([^\]]+)\]/g);
                        if (matches && matches.length > 0) {
                            let model = "";
                            for (let i = matches.length - 1; i >= 0; i--) {
                                const raw = matches[i].slice(1, -1).trim();
                                if (!raw.includes("/") && !raw.toLowerCase().startsWith("amd")) {
                                    model = raw;
                                    break;
                                }
                            }
                            if (!model) {
                                model = matches[matches.length - 1].slice(1, -1).trim();
                            }
                            const clean = model.replace(/\(R\)|\(TM\)|Graphics/gi, "").trim();
                            root.name = clean.startsWith("Radeon") ? "AMD " + clean : clean;
                        }
                    }
                }
                if (root.refCount > 0) {
                    root.updateMetrics();
                }
            }
        }
    }

    FileView {
        id: busyView

        path: root.busyPath
        printErrors: false
        onLoaded: {
            const val = parseFloat(text().trim());
            if (!isNaN(val)) {
                root.percentage = Math.max(0, Math.min(1, val / 100.0));
            }
        }
    }

    FileView {
        id: tempView

        path: root.tempPath
        printErrors: false
        onLoaded: {
            const val = parseFloat(text().trim());
            if (!isNaN(val)) {
                root.temperature = val > 1000 ? Math.round(val / 1000.0) : Math.round(val);
            }
        }
    }

    Timer {
        id: pollTimer

        running: root.refCount > 0
        interval: 1000
        repeat: true
        onTriggered: root.updateMetrics()
    }

    IpcHandler {
        target: "dashboard"

        function setTab(tab: int): void {
            const ss = ShellState.forActive();
            if (ss)
                ss.dashboardTab = tab;
        }

        function getTab(): int {
            const ss = ShellState.forActive();
            return ss ? ss.dashboardTab : -1;
        }
    }
}
