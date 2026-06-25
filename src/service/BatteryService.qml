pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

QtObject {
    id: root

    property bool _notified10: false
    property bool _notified25: false
    readonly property bool allFull: {
        var vals = UPower.devices.values;
        for (var i = 0; i < vals.length; i++) {
            if ((vals[i].type === 2 || vals[i].type === 4) && vals[i].isPresent && vals[i].state !== 4)
                return false;
        }
        return !UPower.onBattery;
    }
    readonly property bool anyCharging: {
        var vals = UPower.devices.values;
        for (var i = 0; i < vals.length; i++) {
            if ((vals[i].type === 2 || vals[i].type === 4) && vals[i].isPresent && vals[i].state === 1)
                return true;
        }
        return false;
    }
    readonly property var battery: {
        var vals = UPower.devices.values;
        for (var i = 0; i < vals.length; i++) {
            if (vals[i].type === 2 && vals[i].isPresent)
                return vals[i];
        }
        return null;
    }
    readonly property bool charging: battery ? (battery.state === 1) : false
    readonly property bool detected: battery !== null
    readonly property int pct: battery ? Math.round(battery.percentage * 100) : 0

    onAnyChargingChanged: {
        if (anyCharging) {
            _notified25 = false;
            _notified10 = false;
        }
    }
    onPctChanged: {
        if (anyCharging || allFull)
            return;
        if (pct > 25) {
            _notified25 = false;
            _notified10 = false;
        } else if (pct > 10) {
            _notified10 = false;
            if (!_notified25) {
                _notified25 = true;
                Quickshell.execDetached(["notify-send", "Battery Low", pct + "% remaining", "--urgency", "normal", "--app-name", "Battery"]);
            }
        } else if (!_notified10) {
            _notified25 = true;
            _notified10 = true;
            Quickshell.execDetached(["notify-send", "Battery Critical", pct + "% remaining", "--urgency", "critical", "--app-name", "Battery"]);
        }
    }
}
