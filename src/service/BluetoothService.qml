pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell.Bluetooth

QtObject {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: !!adapter
    readonly property var connectedDevices: {
        if (!adapter?.devices)
            return [];
        var out = [];
        var vals = adapter.devices.values;
        for (var i = 0; i < vals.length; i++) {
            var d = vals[i];
            if (d && d.connected && !d.blocked)
                out.push(d);
        }
        return out;
    }
    readonly property bool enabled: adapter?.enabled ?? false
    readonly property var nearbyDevices: {
        if (!adapter?.devices)
            return [];
        var out = [];
        var vals = adapter.devices.values;
        for (var i = 0; i < vals.length; i++) {
            var d = vals[i];
            if (d && !d.connected && !d.paired && !d.trusted && !d.blocked && (d.name || d.deviceName))
                out.push(d);
        }
        return out;
    }
    readonly property var pairedDevices: {
        if (!adapter?.devices)
            return [];
        var out = [];
        var vals = adapter.devices.values;
        for (var i = 0; i < vals.length; i++) {
            var d = vals[i];
            if (d && !d.connected && (d.paired || d.trusted) && !d.blocked)
                out.push(d);
        }
        return out;
    }
    readonly property bool scanning: adapter?.discovering ?? false

    function connectDevice(device) {
        if (!device)
            return;
        try {
            device.trusted = true;
            device.connect();
        } catch (e) {}
    }
    function deviceName(device) {
        if (!device)
            return "Unknown";
        return device.name || device.deviceName || device.address || "Unknown";
    }
    function disconnectDevice(device) {
        if (!device)
            return;
        try {
            device.disconnect();
        } catch (e) {}
    }
    function forgetDevice(device) {
        if (!device)
            return;
        try {
            device.trusted = false;
            device.forget();
        } catch (e) {}
    }
    function isBusy(device) {
        if (!device)
            return false;
        try {
            return device.pairing || device.state === BluetoothDevice.Connecting || device.state === BluetoothDevice.Disconnecting;
        } catch (e) {
            return false;
        }
    }
    function setEnabled(state) {
        if (!adapter)
            return;
        try {
            adapter.enabled = state;
        } catch (e) {}
    }
    function setScanning(state) {
        if (!adapter)
            return;
        try {
            adapter.discovering = state;
        } catch (e) {}
    }
}
