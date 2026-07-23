pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

QtObject {
    id: root

    property Process _connectProc: Process {
        property string password: ""
        property bool saved: false
        property string ssid: ""

        command: {
            if (saved)
                return ["nmcli", "-t", "connection", "up", "id", ssid];
            var cmd = ["nmcli", "-t", "device", "wifi", "connect", ssid];
            if (password)
                cmd.push("password", password);
            return cmd;
        }
        environment: ({
                "LC_ALL": "C"
            })
        running: false

        stderr: StdioCollector {
            onStreamFinished: {
                root.connecting = false;
                root.connectingTo = "";
                if (text.trim()) {
                    if (text.indexOf("Secrets were required") !== -1 || text.indexOf("no secrets provided") !== -1) {
                        root.lastError = "Incorrect password";
                        root.forget(root._connectProc.ssid);
                    } else if (text.indexOf("No network with SSID") !== -1) {
                        root.lastError = "Network not found";
                    } else if (text.indexOf("Timeout") !== -1) {
                        root.lastError = "Connection timed out";
                    } else {
                        root.lastError = "Connection failed";
                    }
                }
            }
        }
        stdout: StdioCollector {
            onStreamFinished: {
                const ok = text.indexOf("successfully activated") !== -1 || text.indexOf("Connection successfully") !== -1;
                if (ok) {
                    var nets = root.networks;
                    if (nets[root._connectProc.ssid]) {
                        nets[root._connectProc.ssid].connected = true;
                        nets[root._connectProc.ssid].existing = true;
                    }
                    root.networks = Object.assign({}, nets);
                }
                root.connecting = false;
                root.connectingTo = "";
                root._delayedScan.nextInterval = 5000;
                root._delayedScan.restart();
            }
        }
    }
    property Process _connectivityProc: Process {
        command: ["nmcli", "networking", "connectivity", "check"]
        environment: ({
                "LC_ALL": "C"
            })
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                var r = text.trim().toLowerCase();
                root.connectivity = (r === "none") ? "unknown" : r;
            }
        }
    }
    property Timer _connectivityTimer: Timer {
        interval: 30000
        repeat: true
        running: root.connectedSsid !== "" || root.ethernetConnected

        onTriggered: {
            if (!root._connectivityProc.running)
                root._connectivityProc.running = true;
        }
    }
    property Timer _delayedScan: Timer {
        property int nextInterval: 7000

        interval: nextInterval

        onTriggered: root.scan()
    }
    property Process _deviceProc: Process {
        command: ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device", "status"]
        environment: ({
                "LC_ALL": "C"
            })
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                var wifi = false;
                var eth = false;
                var ethConn = false;
                var ethName = "";
                var lines = text.trim().split("\n");
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim();
                    if (!line)
                        continue;
                    var parts = line.split(":");
                    if (parts.length < 3)
                        continue;
                    var type = parts[1];
                    var state = parts[2];
                    var conn = parts.slice(3).join(":");
                    if (state === "unmanaged")
                        continue;
                    if (type === "wifi") {
                        wifi = true;
                    } else if (type === "ethernet") {
                        eth = true;
                        if (state.indexOf("connected") === 0) {
                            ethConn = true;
                            if (!ethName)
                                ethName = conn;
                        }
                    }
                }
                root.wifiAvailable = wifi;
                root.ethernetAvailable = eth;
                root.ethernetConnected = ethConn;
                root.ethernetConnectionName = ethName;
            }
        }
    }
    property Process _disconnectProc: Process {
        property string ssid: ""

        command: ["nmcli", "connection", "down", "id", ssid]
        running: false

        stderr: StdioCollector {
            onStreamFinished: {
                root._delayedScan.nextInterval = 5000;
                root._delayedScan.restart();
            }
        }
        stdout: StdioCollector {
            onStreamFinished: {
                var nets = root.networks;
                if (nets[root._disconnectProc.ssid])
                    nets[root._disconnectProc.ssid].connected = false;
                root.networks = Object.assign({}, nets);
                root._delayedScan.nextInterval = 3000;
                root._delayedScan.restart();
            }
        }
    }
    property Process _forgetProc: Process {
        property string ssid: ""

        command: {
            const script = `
ssid="$1"
UUID=$(nmcli -t -f NAME,UUID,TYPE connection show | awk -F: -v target="$ssid" '$1 == target && $3 == "802-11-wireless" { print $2; exit }')
if [ -n "$UUID" ]; then
    nmcli connection delete uuid "$UUID" 2>/dev/null || true
fi
`;

            return ["sh", "-c", script, "--", ssid];
        }
        environment: ({
                "LC_ALL": "C"
            })
        running: false

        stderr: StdioCollector {
            onStreamFinished: {}
        }
        stdout: StdioCollector {
            onStreamFinished: {
                var nets = root.networks;
                if (nets[root._forgetProc.ssid]) {
                    nets[root._forgetProc.ssid].existing = false;
                    root.networks = Object.assign({}, nets);
                }
                root._delayedScan.nextInterval = 3000;
                root._delayedScan.restart();
            }
        }
    }
    property bool _init: false
    property Timer _initTimer: Timer {
        interval: 500

        onTriggered: {
            root._init = true;
            if (root.wifiEnabled)
                root.scan();
        }
    }
    property Process _monitorProc: Process {
        command: ["nmcli", "-t", "monitor"]
        environment: ({
                "LC_ALL": "C"
            })
        running: true

        stdout: SplitParser {
            onRead: data => {
                if (data.endsWith(": connected") || data.endsWith(": disconnected")) {
                    root._deviceProc.running = true;
                    if (!root._scanProc.running)
                        root._scanProc.running = true;
                } else if (data.indexOf("Connectivity is now") !== -1) {
                    var m = data.match(/Connectivity is now '(\w+)'/);
                    if (m)
                        root.connectivity = m[1] === "none" ? "unknown" : m[1];
                }
            }
        }
    }
    property Connections _netConn: Connections {
        function onWifiEnabledChanged() {
            if (!root._init)
                return;
            if (!Networking.wifiEnabled) {
                root._profileProc.running = false;
                root._quickScanProc.running = false;
                root._scanProc.running = false;
                root.networks = ({});
                root.scanning = false;
                return;
            }
            root.scanning = true;
            root._wifiDebounce.restart();
        }

        target: Networking
    }
    property Process _notifyProc: Process {
        property string body: ""
        property string icon: ""
        property string summary: ""

        command: ["notify-send", "-a", "Network", "-i", icon, summary, body]
        running: false
    }
    property string _prevSsid: ""
    property Process _profileProc: Process {
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]
        running: false

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim()) {
                    root.scanning = false;
                    if (root._scanPending) {
                        root._scanPending = false;
                        root._delayedScan.nextInterval = 3000;
                        root._delayedScan.restart();
                    }
                }
            }
        }
        stdout: StdioCollector {
            onStreamFinished: {
                var profiles = {};
                var lines = text.split("\n");
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim();
                    if (!line)
                        continue;
                    var sep = line.lastIndexOf(":");
                    if (sep < 0)
                        continue;
                    var type = line.slice(sep + 1);
                    if (type !== "802-11-wireless")
                        continue;
                    var name = line.slice(0, sep).trim();
                    if (name)
                        profiles[name] = true;
                }
                root.existingProfiles = profiles;
                if (!root.wifiEnabled) {
                    root.scanning = false;
                    return;
                }
                if (Object.keys(root.networks).length === 0) {
                    var preNets = {};
                    var ssids = Object.keys(profiles);
                    for (var k = 0; k < ssids.length; k++) {
                        preNets[ssids[k]] = {
                            ssid: ssids[k],
                            security: "--",
                            signal: 0,
                            connected: false,
                            existing: true,
                            inRange: false
                        };
                    }
                    if (ssids.length > 0)
                        root.networks = preNets;
                }
                root._quickScanProc.running = true;
            }
        }
    }
    // Fast pass: returns the driver's cached scan list instantly, no hardware rescan.
    // Populates the panel immediately so the user sees networks on open even before
    // the full --rescan yes pass completes.
    property Process _quickScanProc: Process {
        command: ["nmcli", "-t", "-f", "SSID,SECURITY,SIGNAL,IN-USE", "device", "wifi", "list", "--rescan", "no"]
        environment: ({
                "LC_ALL": "C"
            })
        running: false

        stderr: StdioCollector {
            onStreamFinished: {
                if (!root.wifiEnabled) {
                    root.scanning = false;
                    return;
                }
                if (!root._scanProc.running)
                    root._scanProc.running = true;
            }
        }
        stdout: StdioCollector {
            onStreamFinished: {
                if (!root.wifiEnabled) {
                    root.scanning = false;
                    return;
                }
                var quick = root._parseNetworks(text);
                if (Object.values(quick).some(n => n.inRange))
                    root.networks = quick;
                if (!root._scanProc.running)
                    root._scanProc.running = true;
            }
        }
    }
    property bool _scanPending: false
    property Process _scanProc: Process {
        command: ["nmcli", "-t", "-f", "SSID,SECURITY,SIGNAL,IN-USE", "device", "wifi", "list", "--rescan", "yes"]
        environment: ({
                "LC_ALL": "C"
            })
        running: false

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim()) {
                    root.scanning = false;
                    root._delayedScan.nextInterval = root._scanPending ? 3000 : 10000;
                    root._scanPending = false;
                    root._delayedScan.restart();
                }
                // empty stderr = success; stdout handler owns scanning state
            }
        }
        stdout: StdioCollector {
            onStreamFinished: {
                var result = root._parseNetworks(text);
                root.networks = result;
                var hasReal = Object.values(result).some(n => n.inRange);
                if (root._scanPending) {
                    root._scanPending = false;
                    root.scanning = false;
                    root._delayedScan.nextInterval = 100;
                } else if (root.wifiEnabled && !hasReal) {
                    // No networks found yet — keep scanning indicator visible
                    // and retry soon so the panel doesn't go blank.
                    root._delayedScan.nextInterval = 2000;
                } else {
                    root.scanning = false;
                    root._delayedScan.nextInterval = 7000;
                }
                root._delayedScan.restart();
            }
        }
    }
    property Timer _wifiDebounce: Timer {
        interval: 400

        onTriggered: root.scan()
    }
    readonly property int connectedSignal: {
        var net = networks[connectedSsid];
        return net ? net.signal : 0;
    }
    readonly property string connectedSsid: {
        var vals = Object.values(networks);
        for (var i = 0; i < vals.length; i++) {
            if (vals[i].connected)
                return vals[i].ssid;
        }
        return "";
    }
    property bool connecting: false
    property string connectingTo: ""
    property string connectivity: "unknown"
    property bool ethernetAvailable: false
    property bool ethernetConnected: false
    property string ethernetConnectionName: ""
    property var existingProfiles: ({})
    property string lastError: ""
    property var networks: ({})
    property bool scanning: false
    property bool wifiAvailable: false
    readonly property bool wifiEnabled: Networking.wifiEnabled

    function _notify(summary, body, icon) {
        if (_notifyProc.running)
            _notifyProc.running = false;
        _notifyProc.summary = summary;
        _notifyProc.body = body;
        _notifyProc.icon = icon;
        _notifyProc.running = true;
    }
    function _parseNetworks(text) {
        const lines = text.trim().split("\n");
        const result = {};
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim();
            if (!line)
                continue;
            const parts = line.split(":");
            if (parts.length < 4)
                continue;
            const inUse = parts[parts.length - 1];
            const signal = parseInt(parts[parts.length - 2]) || 0;
            let security = parts[parts.length - 3];
            if (security)
                security = security.replace("WPA2 WPA3", "WPA2/WPA3").replace("WPA1 WPA2", "WPA1/WPA2");
            const ssid = parts.slice(0, parts.length - 3).join(":");
            if (!ssid)
                continue;
            const isConnected = (inUse === "*");
            if (!result[ssid]) {
                result[ssid] = {
                    ssid: ssid,
                    security: security || "--",
                    signal: signal,
                    connected: isConnected,
                    existing: !!root.existingProfiles[ssid],
                    inRange: true
                };
            } else if (isConnected) {
                result[ssid].connected = true;
            }
        }
        // Merge in saved profiles the scan didn't (yet) see, so the Known
        // section never vanishes when a hardware scan returns empty/partial
        // (e.g. right after enabling WiFi). These stubs are replaced by real
        // scan data on the next pass that picks them up.
        if (root.wifiEnabled) {
            var saved = Object.keys(root.existingProfiles);
            for (var s = 0; s < saved.length; s++) {
                var sname = saved[s];
                if (!result[sname]) {
                    result[sname] = {
                        ssid: sname,
                        security: "--",
                        signal: 0,
                        connected: false,
                        existing: true,
                        inRange: false
                    };
                }
            }
        }
        return result;
    }
    function connect(ssid, password) {
        if (connecting)
            return;
        connecting = true;
        connectingTo = ssid;
        lastError = "";
        _connectProc.ssid = ssid;
        _connectProc.password = password;
        _connectProc.saved = !!existingProfiles[ssid];
        _connectProc.running = true;
    }
    function disconnect(ssid) {
        _disconnectProc.ssid = ssid;
        _disconnectProc.running = true;
    }
    function forget(ssid) {
        _forgetProc.ssid = ssid;
        _forgetProc.running = true;
    }
    function scan() {
        if (!wifiEnabled)
            return;
        lastError = "";
        if (_profileProc.running || _quickScanProc.running || _scanProc.running) {
            _scanPending = true;
            return;
        }
        _profileProc.running = true;
        scanning = true;
    }
    function setWifiEnabled(state) {
        Networking.wifiEnabled = state;
    }

    Component.onCompleted: {
        _deviceProc.running = true;
        _initTimer.start();
    }
    onConnectedSsidChanged: {
        if (root.connectedSsid !== "")
            root._connectivityProc.running = true;
        else if (!root.ethernetConnected)
            root.connectivity = "unknown";
        if (root._init) {
            if (root.connectedSsid !== "")
                root._notify("Connected", "Connected to " + root.connectedSsid, "network-wireless-connected-symbolic");
            else if (root._prevSsid !== "")
                root._notify("Disconnected", "Disconnected from " + root._prevSsid, "network-wireless-offline-symbolic");
        }
        root._prevSsid = root.connectedSsid;
    }
    onConnectivityChanged: {
        if (root._init && root.connectivity === "portal")
            root._notify("Captive Portal", "Sign in required for " + root.connectedSsid, "network-wireless-acquiring-symbolic");
    }
    onEthernetConnectedChanged: {
        if (root.ethernetConnected)
            root._connectivityProc.running = true;
        else if (root.connectedSsid === "")
            root.connectivity = "unknown";
        if (root._init) {
            if (root.ethernetConnected)
                root._notify("Connected", "Connected via Ethernet", "network-wired-symbolic");
            else
                root._notify("Disconnected", "Ethernet disconnected", "network-wired-offline-symbolic");
        }
    }
}
