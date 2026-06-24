pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    readonly property var _defaultWidgets: ({
            left: [
                {
                    "id": "Power"
                },
                {
                    "id": "Workspace"
                }
            ],
            center: [
                {
                    "id": "Clock",
                    "format": "ddd yyyy-MM-dd hh:mm:ss"
                }
            ],
            right: [
                {
                    "id": "Tray",
                    "startExpanded": false,
                    "arrowSide": "right",
                    "direction": "rtl"
                },
                {
                    "id": "SystemMonitor"
                },
                {
                    "id": "Network"
                },
                {
                    "id": "Bluetooth"
                },
                {
                    "id": "Volume"
                },
                {
                    "id": "Battery",
                    "hideIfNotDetected": true
                },
                {
                    "id": "ControlCenter"
                }
            ]
        })
    readonly property JsonAdapter adapter: JsonAdapter {
        property JsonObject bar: JsonObject {
            property real backgroundOpacity: 0
            property int height: 35
            property int marginH: 20
            property int marginTop: 10
            property int screenMargin: 20
        }
        property JsonObject controlCenter: JsonObject {
            property var cardOrder: []
            property list<var> cards: ["battery", "systemStats", "cpuTemp", "gpuTemp", "media", "volume"]
        }
        property var displays: ({})
        property JsonObject osd: JsonObject {
            property list<var> active: ["Sink", "Source"]
        }
        property var powerButtons: ([])
        property var widgets: ({})
    }
    readonly property var allWidgets: {
        var p = adapter.widgets || {};
        if (Object.keys(p).length === 0)
            return {
                "default": root._defaultWidgets
            };
        if (!p["default"] && (p.left !== undefined || p.center !== undefined || p.right !== undefined)) {
            return {
                "default": {
                    left: p.left || root._defaultWidgets.left,
                    center: p.center || root._defaultWidgets.center,
                    right: p.right || root._defaultWidgets.right
                }
            };
        }
        return p;
    }
    readonly property string configDir: {
        var xdg = Quickshell.env("XDG_CONFIG_HOME");
        return (xdg || Quickshell.env("HOME") + "/.config") + "/keqing-shell/";
    }
    readonly property var controlCenter: adapter.controlCenter
    readonly property var displays: adapter.displays || {}
    readonly property string filePath: configDir + "settings.json"
    property Timer firstRunTimer: Timer {
        interval: 250

        onTriggered: root.settingsFile.writeAdapter()
    }
    property bool loaded: false
    readonly property var powerButtons: adapter.powerButtons || []
    property Timer saveTimer: Timer {
        interval: 600

        onTriggered: root.settingsFile.writeAdapter()
    }
    property FileView settingsFile: FileView {
        adapter: root.adapter
        path: root.filePath
        printErrors: false
        watchChanges: true

        onLoadFailed: error => {
            var msg = error.toString();
            if (msg.includes("No such file") || msg.includes("ENOENT") || error === 2) {
                Quickshell.execDetached(["mkdir", "-p", root.configDir]);
                firstRunTimer.start();
            }
            root.loaded = true;
        }
        onLoaded: root.loaded = true
    }
    property bool widgetPopupOpen: false
    readonly property var widgets: {
        var def = allWidgets["default"] || root._defaultWidgets;
        return {
            left: def.left || root._defaultWidgets.left,
            center: def.center || root._defaultWidgets.center,
            right: def.right || root._defaultWidgets.right
        };
    }

    function save() {
        saveTimer.restart();
    }
    function setControlCenter(obj) {
        if (obj.cards !== undefined)
            adapter.controlCenter.cards = obj.cards;
        if (obj.cardOrder !== undefined)
            adapter.controlCenter.cardOrder = obj.cardOrder;
        save();
    }
    function setDisplays(obj) {
        adapter.displays = obj;
        save();
    }
    function setOsd(arr) {
        adapter.osd.active = arr;
        save();
    }
    function setPowerButtons(arr) {
        adapter.powerButtons = arr;
        save();
    }
    function ensureScreen(screenName) {
        var all = JSON.parse(JSON.stringify(allWidgets));
        if (!all[screenName]) {
            var def = all["default"] || root._defaultWidgets;
            all[screenName] = {
                left: (def.left || root._defaultWidgets.left).slice(),
                center: (def.center || root._defaultWidgets.center).slice(),
                right: (def.right || root._defaultWidgets.right).slice()
            };
        }
        return all;
    }
    function setWidgetOverrideEnabled(screenName, enabled) {
        if (!allWidgets[screenName] && !enabled)
            return;
        var all = ensureScreen(screenName);
        all[screenName]._enabled = enabled;
        adapter.widgets = all;
        save();
    }
    function setWidgets(screenName, section, arr) {
        var all = ensureScreen(screenName);
        all[screenName][section] = arr;
        adapter.widgets = all;
        save();
    }
}
