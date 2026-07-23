pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell.Hyprland
import Quickshell.Io

import qs.service

QtObject {
    id: root

    property var _clientsProc: Process {
        command: ["hyprctl", "clients", "-j"]

        stdout: StdioCollector {
            id: clientsCollector

            onStreamFinished: {
                try {
                    root.windowList = JSON.parse(clientsCollector.text);
                } catch (e) {}
            }
        }
    }
    readonly property bool _hasMultiWindowWorkspace: {
        var counts = {};
        for (var i = 0; i < root.windowList.length; ++i) {
            var wsId = root.windowList[i]?.workspace?.id;
            if (wsId === undefined)
                continue;
            counts[wsId] = (counts[wsId] || 0) + 1;
            if (counts[wsId] > 1)
                return true;
        }
        return false;
    }
    property var _hyprConn: Connections {
        function onChanged() {
            root._clientsProc.running = true;
        }

        target: HyprlandService
    }
    property var _pollTimer: Timer {
        interval: 500
        repeat: true
        running: root._hasMultiWindowWorkspace

        onTriggered: root._clientsProc.running = true
    }
    property var windowList: []

    function activeWorkspaceId(screen) {
        var m = Hyprland.monitorFor(screen);
        return m && m.activeWorkspace ? m.activeWorkspace.id : -1;
    }
    function isFocused(address) {
        return root.normalizeAddress(address) === root.normalizeAddress(Hyprland.activeToplevel?.address);
    }
    function normalizeAddress(addr) {
        return String(addr ?? "").toLowerCase().replace(/^0x/, "");
    }
    function syncModel(model, windows) {
        for (var i = model.count - 1; i >= 0; i--) {
            var addr = model.get(i).address;
            if (!windows.some(w => w.address === addr))
                model.remove(i);
        }
        for (var idx = 0; idx < windows.length; idx++) {
            var w = windows[idx];
            var curIdx = -1;
            for (var j = 0; j < model.count; j++) {
                if (model.get(j).address === w.address) {
                    curIdx = j;
                    break;
                }
            }
            if (curIdx === -1) {
                model.insert(idx, {
                    "address": w.address,
                    "wsClass": w.class ?? ""
                });
            } else {
                if (curIdx !== idx)
                    model.move(curIdx, idx, 1);
                if (model.get(idx).wsClass !== (w.class ?? ""))
                    model.setProperty(idx, "wsClass", w.class ?? "");
            }
        }
    }
    function windowsForWorkspace(workspaceId) {
        return root.windowList.filter(w => w && w.workspace && w.workspace.id === workspaceId).sort((a, b) => (a.at?.[0] ?? 0) - (b.at?.[0] ?? 0));
    }

    Component.onCompleted: root._clientsProc.running = true
}
