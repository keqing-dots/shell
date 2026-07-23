pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property string cpuFreq: "0.0GHz"
    property Timer cpuFreqTimer: Timer {
        id: cpuFreqTimer

        interval: 3000
        repeat: true
        running: true
        triggeredOnStart: true

        onTriggered: cpuInfoFile.reload()
    }
    property FileView cpuInfoFile: FileView {
        id: cpuInfoFile

        path: "/proc/cpuinfo"

        onLoaded: root.parseCpuFreq(text())
    }
    property FileView cpuStatFile: FileView {
        id: cpuStatFile

        path: "/proc/stat"

        onLoaded: root.parseCpuUsage(text())
    }
    property real cpuTempC: 0
    property string cpuTempHwmonPath: ""
    property FileView cpuTempReader: FileView {
        id: cpuTempReader

        printErrors: false

        onLoadFailed: {
            if (root.cpuTempSensorName === "coretemp") {
                Qt.callLater(function () {
                    root.checkNextIntelTemp();
                });
            }
        }
        onLoaded: {
            var data = text().trim();
            if (root.cpuTempSensorName === "coretemp") {
                var t = parseInt(data) / 1000.0;
                var arr = root.intelTempValues.slice();
                arr.push(t);
                root.intelTempValues = arr;
                Qt.callLater(function () {
                    root.checkNextIntelTemp();
                });
            } else {
                root.cpuTempC = Math.round(parseInt(data) / 1000.0);
            }
        }
    }
    property FileView cpuTempScanner: FileView {
        id: cpuTempScanner

        property int currentIndex: 0

        function checkNext() {
            if (currentIndex >= 16) {
                if (!root.thermalScanDone) {
                    root.thermalScanDone = true;
                    thermalZoneScanner.startScan();
                }
                return;
            }
            path = "/sys/class/hwmon/hwmon" + currentIndex + "/name";
            reload();
        }

        printErrors: false

        onLoadFailed: {
            currentIndex++;
            Qt.callLater(function () {
                cpuTempScanner.checkNext();
            });
        }
        onLoaded: {
            var name = text().trim();
            if (root.supportedCpuSensorNames.includes(name)) {
                root.cpuTempSensorName = name;
                root.cpuTempHwmonPath = "/sys/class/hwmon/hwmon" + currentIndex;
            } else {
                currentIndex++;
                Qt.callLater(function () {
                    cpuTempScanner.checkNext();
                });
            }
        }
    }
    property string cpuTempSensorName: ""
    property FileView cpuThermalReader: FileView {
        id: cpuThermalReader

        property var collectedTemps: []
        property int currentZoneIndex: 0

        printErrors: false

        onLoadFailed: {
            currentZoneIndex++;
            Qt.callLater(function () {
                root.readNextCpuThermalZone();
            });
        }
        onLoaded: {
            var temp = parseInt(text().trim()) / 1000.0;
            if (!isNaN(temp) && temp > 0) {
                var arr = collectedTemps.slice();
                arr.push(temp);
                collectedTemps = arr;
            }
            currentZoneIndex++;
            Qt.callLater(function () {
                root.readNextCpuThermalZone();
            });
        }
    }
    property var cpuThermalZonePaths: []
    property Timer cpuTimer: Timer {
        id: cpuTimer

        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true

        onTriggered: {
            cpuStatFile.reload();
            root.updateCpuTemp();
        }
    }
    property real cpuUsage: 0
    property Process dfShell: Process {
        id: dfShell

        command: ["sh"]
        running: true
        stdinEnabled: true

        stdout: SplitParser {
            splitMarker: "@@DF_END@@"

            onRead: data => {
                var lines = data.trim().split('\n');
                for (var i = 1; i < lines.length; i++) {
                    var parts = lines[i].trim().split(/\s+/);
                    if (parts.length >= 5 && parts[0] === "/") {
                        root.diskRootPct = parseInt(parts[1].replace(/[^0-9]/g, '')) || 0;
                        root.diskRootUsedGb = parseFloat(parts[2]) / 1073741824;
                        root.diskRootSizeGb = parseFloat(parts[3]) / 1073741824;
                    }
                }
            }
        }

        onRunningChanged: {
            if (!running)
                Qt.callLater(function () {
                    dfShell.running = true;
                });
        }
    }
    property int diskRootPct: 0
    property real diskRootSizeGb: 0
    property real diskRootUsedGb: 0
    property Timer diskTimer: Timer {
        id: diskTimer

        interval: 30000
        repeat: true
        running: true
        triggeredOnStart: true

        onTriggered: {
            if (dfShell.running)
                dfShell.write("df --output=target,pcent,used,size,avail --block-size=1 -x efivarfs 2>/dev/null; echo '@@DF_END@@'\n");
        }
    }
    property var foundGpuSensors: []
    property bool gpuAvailable: false
    property real gpuTempC: 0
    property string gpuTempHwmonPath: ""
    property FileView gpuTempReader: FileView {
        id: gpuTempReader

        printErrors: false

        onLoaded: root.gpuTempC = Math.round(parseInt(text().trim()) / 1000.0)
    }
    property FileView gpuTempScanner: FileView {
        id: gpuTempScanner

        property int currentIndex: 0

        function checkNext() {
            if (currentIndex >= 16) {
                nvidiaSmiCheck.running = true;
                return;
            }
            path = "/sys/class/hwmon/hwmon" + currentIndex + "/name";
            reload();
        }

        printErrors: false

        onLoadFailed: {
            currentIndex++;
            Qt.callLater(function () {
                gpuTempScanner.checkNext();
            });
        }
        onLoaded: {
            var name = text().trim();
            if (root.supportedGpuSensorNames.includes(name)) {
                var arr = root.foundGpuSensors.slice();
                arr.push({
                    "hwmonPath": "/sys/class/hwmon/hwmon" + currentIndex,
                    "type": name === "amdgpu" ? "amd" : "intel",
                    "hasDedicatedVram": false
                });
                root.foundGpuSensors = arr;
            }
            currentIndex++;
            Qt.callLater(function () {
                gpuTempScanner.checkNext();
            });
        }
    }
    property FileView gpuThermalReader: FileView {
        id: gpuThermalReader

        property var collectedTemps: []
        property int currentZoneIndex: 0

        printErrors: false

        onLoaded: {
            var temp = parseInt(text().trim()) / 1000.0;
            if (!isNaN(temp) && temp > 0) {
                var arr = collectedTemps.slice();
                arr.push(temp);
                collectedTemps = arr;
            }
            currentZoneIndex++;
            Qt.callLater(function () {
                root.readNextGpuThermalZone();
            });
        }
    }
    property string gpuThermalZonePath: ""
    property var gpuThermalZonePaths: []
    property Timer gpuTimer: Timer {
        id: gpuTimer

        interval: 5000
        repeat: true
        running: root.gpuAvailable
        triggeredOnStart: true

        onTriggered: root.updateGpuTemp()
    }
    property string gpuType: ""
    property real gpuUsage: 0
    property int gpuVramCheckIndex: 0
    property FileView gpuVramChecker: FileView {
        id: gpuVramChecker

        printErrors: false

        onLoadFailed: {
            root.gpuVramCheckIndex++;
            Qt.callLater(function () {
                root.checkNextGpuVram();
            });
        }
        onLoaded: {
            var vram = parseInt(text().trim());
            if (vram > 0) {
                var arr = root.foundGpuSensors.slice();
                var entry = Object.assign({}, arr[root.gpuVramCheckIndex]);
                entry.hasDedicatedVram = true;
                arr[root.gpuVramCheckIndex] = entry;
                root.foundGpuSensors = arr;
            }
            root.gpuVramCheckIndex++;
            Qt.callLater(function () {
                root.checkNextGpuVram();
            });
        }
    }
    property int intelTempFilesChecked: 0
    readonly property int intelTempMaxFiles: 20
    property var intelTempValues: []
    property FileView memInfoFile: FileView {
        id: memInfoFile

        path: "/proc/meminfo"

        onLoaded: root.parseMemInfo(text())
    }
    property real memPercent: 0
    property Timer memTimer: Timer {
        id: memTimer

        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true

        onTriggered: memInfoFile.reload()
    }
    property real memTotalGb: 0
    property real memUsedGb: 0
    property FileView netDevFile: FileView {
        id: netDevFile

        path: "/proc/net/dev"

        onLoaded: root.parseNetDev(text())
    }
    property Timer netTimer: Timer {
        id: netTimer

        interval: 3000
        repeat: true
        running: true
        triggeredOnStart: true

        onTriggered: netDevFile.reload()
    }
    property Process nvidiaSmiCheck: Process {
        id: nvidiaSmiCheck

        command: ["sh", "-c", "command -v nvidia-smi"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    var arr = root.foundGpuSensors.slice();
                    arr.push({
                        "hwmonPath": "",
                        "type": "nvidia",
                        "hasDedicatedVram": true
                    });
                    root.foundGpuSensors = arr;
                }
                root.gpuVramCheckIndex = 0;
                root.checkNextGpuVram();
            }
        }
    }
    property Process nvidiaTempProcess: Process {
        id: nvidiaTempProcess

        command: ["nvidia-smi", "--query-gpu=temperature.gpu,utilization.gpu", "--format=csv,noheader,nounits"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                var parts = text.trim().split(",");
                var temp = parseInt(parts[0]);
                var usage = parseInt(parts[1]);
                if (!isNaN(temp))
                    root.gpuTempC = temp;
                if (!isNaN(usage))
                    root.gpuUsage = usage;
            }
        }
    }
    property var prevCpuStats: null
    property real prevNetTime: 0
    property real prevRxBytes: 0
    property real prevTxBytes: 0
    property real rxBps: 0
    readonly property var supportedCpuSensorNames: ["coretemp", "k10temp", "zenpower"]
    readonly property var supportedGpuSensorNames: ["amdgpu", "xe"]
    property bool thermalScanDone: false
    property FileView thermalZoneScanner: FileView {
        id: thermalZoneScanner

        property var cpuZones: []
        property int currentIndex: 0
        property string gpuAvgZonePath: ""
        property var gpuZones: []

        function checkNext() {
            if (currentIndex >= 20) {
                finishScan();
                return;
            }
            path = "/sys/class/thermal/thermal_zone" + currentIndex + "/type";
            reload();
        }
        function finishScan() {
            if (cpuZones.length > 0) {
                root.cpuTempSensorName = "thermal_zone";
                root.cpuThermalZonePaths = cpuZones;
            }
            if (gpuAvgZonePath !== "") {
                root.gpuThermalZonePath = gpuAvgZonePath;
                root.gpuType = "thermal_zone";
                root.gpuAvailable = true;
            } else if (gpuZones.length > 0) {
                root.gpuThermalZonePaths = gpuZones;
                root.gpuThermalZonePath = gpuZones[0];
                root.gpuType = "thermal_zone";
                root.gpuAvailable = true;
            }
        }
        function startScan() {
            currentIndex = 0;
            cpuZones = [];
            gpuZones = [];
            gpuAvgZonePath = "";
            checkNext();
        }

        printErrors: false

        onLoadFailed: {
            currentIndex++;
            Qt.callLater(function () {
                thermalZoneScanner.checkNext();
            });
        }
        onLoaded: {
            var name = text().trim();
            var zonePath = "/sys/class/thermal/thermal_zone" + currentIndex;
            if (name.startsWith("cpu") && name.endsWith("thermal")) {
                var cpuArr = cpuZones.slice();
                cpuArr.push(zonePath + "/temp");
                cpuZones = cpuArr;
            } else if (name === "gpu-avg-thermal") {
                gpuAvgZonePath = zonePath + "/temp";
            } else if (/^gpu[0-9]+-?thermal$/.test(name)) {
                var gpuArr = gpuZones.slice();
                gpuArr.push(zonePath + "/temp");
                gpuZones = gpuArr;
            }
            currentIndex++;
            Qt.callLater(function () {
                thermalZoneScanner.checkNext();
            });
        }
    }
    property real txBps: 0
    readonly property var virtualIfacePrefixes: ["lo", "docker", "veth", "br-", "virbr", "vnet", "tun", "tap", "wg", "tailscale", "nordlynx", "flannel", "cni"]

    function checkNextGpuVram() {
        while (root.gpuVramCheckIndex < root.foundGpuSensors.length) {
            var gpu = root.foundGpuSensors[root.gpuVramCheckIndex];
            if (gpu.type === "amd") {
                gpuVramChecker.path = gpu.hwmonPath + "/device/mem_info_vram_total";
                gpuVramChecker.reload();
                return;
            }
            root.gpuVramCheckIndex++;
        }
        selectBestGpu();
    }
    function checkNextIntelTemp() {
        if (root.intelTempFilesChecked >= root.intelTempMaxFiles) {
            if (root.intelTempValues.length > 0) {
                var sum = 0;
                for (var i = 0; i < root.intelTempValues.length; i++)
                    sum += root.intelTempValues[i];
                root.cpuTempC = Math.round(sum / root.intelTempValues.length);
            }
            return;
        }
        root.intelTempFilesChecked++;
        cpuTempReader.path = root.cpuTempHwmonPath + "/temp" + root.intelTempFilesChecked + "_input";
        cpuTempReader.reload();
    }
    function computeCpuUsage(prev, curr) {
        if (!prev || !curr)
            return -1;
        var prevTotal = prev.user + prev.nice + prev.system + prev.idle + prev.iowait + prev.irq + prev.softirq + prev.steal;
        var currTotal = curr.user + curr.nice + curr.system + curr.idle + curr.iowait + curr.irq + curr.softirq + curr.steal;
        var diffTotal = currTotal - prevTotal;
        var diffIdle = (curr.idle + curr.iowait) - (prev.idle + prev.iowait);
        if (diffTotal > 0)
            return parseFloat((((diffTotal - diffIdle) / diffTotal) * 100).toFixed(1));
        return -1;
    }
    function formatSpeed(bps) {
        var v = bps / 1024;
        var units = ["KiB", "MiB", "GiB"];
        var i = 0;
        while (v >= 1024 && i < units.length - 1) {
            v /= 1024;
            i++;
        }
        var s = v < 10 ? v.toFixed(1) : Math.round(v).toString();
        return s + units[i];
    }
    function parseCpuFreq(text) {
        if (!text)
            return;
        var matches = text.match(/cpu MHz\s+:\s+([0-9.]+)/g);
        if (matches && matches.length > 0) {
            var total = 0;
            for (var i = 0; i < matches.length; i++)
                total += parseFloat(matches[i].split(':')[1]);
            root.cpuFreq = (total / matches.length / 1000).toFixed(1) + "GHz";
        }
    }
    function parseCpuLine(line) {
        var parts = line.split(/\s+/);
        return {
            "user": parseInt(parts[1]) || 0,
            "nice": parseInt(parts[2]) || 0,
            "system": parseInt(parts[3]) || 0,
            "idle": parseInt(parts[4]) || 0,
            "iowait": parseInt(parts[5]) || 0,
            "irq": parseInt(parts[6]) || 0,
            "softirq": parseInt(parts[7]) || 0,
            "steal": parseInt(parts[8]) || 0
        };
    }
    function parseCpuUsage(text) {
        if (!text)
            return;
        var lines = text.split('\n');
        if (!lines[0].startsWith('cpu '))
            return;
        var curr = parseCpuLine(lines[0]);
        var usage = computeCpuUsage(root.prevCpuStats, curr);
        if (usage >= 0)
            root.cpuUsage = usage;
        root.prevCpuStats = curr;
    }
    function parseMemInfo(text) {
        if (!text)
            return;
        var memTotal = 0;
        var memAvailable = 0;
        var lines = text.split('\n');
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i];
            if (line.startsWith('MemTotal:'))
                memTotal = parseInt(line.split(/\s+/)[1]) || 0;
            else if (line.startsWith('MemAvailable:'))
                memAvailable = parseInt(line.split(/\s+/)[1]) || 0;
        }
        if (memTotal > 0) {
            var usedKb = memTotal - memAvailable;
            root.memUsedGb = parseFloat((usedKb / 1048576).toFixed(1));
            root.memTotalGb = parseFloat((memTotal / 1048576).toFixed(1));
            root.memPercent = Math.round((usedKb / memTotal) * 100);
        }
    }
    function parseNetDev(text) {
        if (!text)
            return;
        var now = Date.now() / 1000;
        var totalRx = 0;
        var totalTx = 0;
        var lines = text.split('\n');
        for (var i = 2; i < lines.length; i++) {
            var line = lines[i].trim();
            if (!line)
                continue;
            var ci = line.indexOf(':');
            if (ci < 0)
                continue;
            var iface = line.substring(0, ci).trim();
            var skip = false;
            for (var j = 0; j < root.virtualIfacePrefixes.length; j++) {
                if (iface.startsWith(root.virtualIfacePrefixes[j])) {
                    skip = true;
                    break;
                }
            }
            if (skip)
                continue;
            var stats = line.substring(ci + 1).trim().split(/\s+/);
            totalRx += parseInt(stats[0]) || 0;
            totalTx += parseInt(stats[8]) || 0;
        }
        if (root.prevNetTime > 0) {
            var dt = now - root.prevNetTime;
            if (dt > 0) {
                root.rxBps = Math.round(Math.max(0, totalRx - root.prevRxBytes) / dt);
                root.txBps = Math.round(Math.max(0, totalTx - root.prevTxBytes) / dt);
            }
        }
        root.prevRxBytes = totalRx;
        root.prevTxBytes = totalTx;
        root.prevNetTime = now;
    }
    function readNextCpuThermalZone() {
        if (cpuThermalReader.currentZoneIndex >= root.cpuThermalZonePaths.length) {
            if (cpuThermalReader.collectedTemps.length > 0)
                root.cpuTempC = Math.round(Math.max.apply(null, cpuThermalReader.collectedTemps));
            return;
        }
        cpuThermalReader.path = root.cpuThermalZonePaths[cpuThermalReader.currentZoneIndex];
        cpuThermalReader.reload();
    }
    function readNextGpuThermalZone() {
        if (gpuThermalReader.currentZoneIndex >= root.gpuThermalZonePaths.length) {
            if (gpuThermalReader.collectedTemps.length > 0)
                root.gpuTempC = Math.round(Math.max.apply(null, gpuThermalReader.collectedTemps));
            return;
        }
        gpuThermalReader.path = root.gpuThermalZonePaths[gpuThermalReader.currentZoneIndex];
        gpuThermalReader.reload();
    }
    function selectBestGpu() {
        if (root.foundGpuSensors.length === 0) {
            if (!root.thermalScanDone) {
                root.thermalScanDone = true;
                thermalZoneScanner.startScan();
            }
            return;
        }
        var best = null;
        for (var i = 0; i < root.foundGpuSensors.length; i++) {
            var gpu = root.foundGpuSensors[i];
            if (gpu.type === "nvidia") {
                best = gpu;
                break;
            }
            if (gpu.type === "amd" && gpu.hasDedicatedVram && !best)
                best = gpu;
            if (gpu.type === "intel" && !best)
                best = gpu;
            if (gpu.type === "amd" && !gpu.hasDedicatedVram && !best)
                best = gpu;
        }
        if (best) {
            root.gpuTempHwmonPath = best.hwmonPath;
            root.gpuType = best.type;
            root.gpuAvailable = true;
        }
    }
    function updateCpuTemp() {
        if (root.cpuTempSensorName === "k10temp" || root.cpuTempSensorName === "zenpower") {
            cpuTempReader.path = root.cpuTempHwmonPath + "/temp1_input";
            cpuTempReader.reload();
        } else if (root.cpuTempSensorName === "coretemp") {
            root.intelTempValues = [];
            root.intelTempFilesChecked = 0;
            checkNextIntelTemp();
        } else if (root.cpuTempSensorName === "thermal_zone") {
            cpuThermalReader.currentZoneIndex = 0;
            cpuThermalReader.collectedTemps = [];
            readNextCpuThermalZone();
        }
    }
    function updateGpuTemp() {
        if (root.gpuType === "nvidia") {
            nvidiaTempProcess.running = true;
        } else if (root.gpuType === "amd" || root.gpuType === "intel") {
            gpuTempReader.path = root.gpuTempHwmonPath + "/temp1_input";
            gpuTempReader.reload();
        } else if (root.gpuType === "thermal_zone") {
            if (root.gpuThermalZonePaths && root.gpuThermalZonePaths.length > 0) {
                gpuThermalReader.currentZoneIndex = 0;
                gpuThermalReader.collectedTemps = [];
                readNextGpuThermalZone();
            } else if (root.gpuThermalZonePath !== "") {
                gpuTempReader.path = root.gpuThermalZonePath;
                gpuTempReader.reload();
            }
        }
    }

    Component.onCompleted: {
        cpuTempScanner.checkNext();
        gpuTempScanner.checkNext();
    }
}
