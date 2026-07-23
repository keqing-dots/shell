pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

import qs.service

QtObject {
    id: root

    property var lastActivity: ({})
    property IdleMonitor recentActivity: IdleMonitor {
        enabled: SettingsService.adapter.idle.enabled
        respectInhibitors: true
        timeout: 2
    }
    property int tick: 0
    property Timer ticker: Timer {
        interval: 1000
        repeat: true
        running: SettingsService.adapter.idle.enabled

        onTriggered: {
            if (LockService.locked) {
                for (var i = 0; i < Quickshell.screens.length; i++)
                    root._touch(Quickshell.screens[i].name);
            } else if (!recentActivity.isIdle) {
                root._touch(Hyprland.focusedMonitor?.name);
            }
            root.tick += 1;
        }
    }
    readonly property int timeoutMs: SettingsService.adapter.idle.autoHideTimeoutSeconds * 1000

    function _touch(monitorName) {
        if (!monitorName)
            return;
        var next = Object.assign({}, root.lastActivity);
        next[monitorName] = Date.now();
        root.lastActivity = next;
    }
    function isIdle(screen, timeoutMs) {
        root.tick;
        if (!screen)
            return false;
        if (!SettingsService.adapter.idle.enabled)
            return false;
        var last = root.lastActivity[screen.name];
        if (last === undefined)
            return false;
        return (Date.now() - last) > (timeoutMs !== undefined ? timeoutMs : root.timeoutMs);
    }
    function reset(screenName) {
        if (!screenName || screenName === "default") {
            for (var i = 0; i < Quickshell.screens.length; i++)
                root._touch(Quickshell.screens[i].name);
        } else {
            root._touch(screenName);
        }
    }

    Component.onCompleted: {
        for (var i = 0; i < Quickshell.screens.length; i++)
            root._touch(Quickshell.screens[i].name);
    }
}
