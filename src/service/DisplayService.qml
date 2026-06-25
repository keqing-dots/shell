pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick

import qs.service

QtObject {
    readonly property var screens: SettingsService.displays

    function _cfg(screen) {
        if (!screen)
            return {};
        if (screens[screen.name] !== undefined)
            return screens[screen.name];
        if (screens[screen.model] !== undefined)
            return screens[screen.model];
        return {};
    }
    function showBar(screen) {
        return _cfg(screen).bar !== false;
    }
    function showNotifications(screen) {
        return _cfg(screen).notifications !== false;
    }
    function showOsd(screen) {
        return _cfg(screen).osd !== false;
    }
    function showVisualizer(screen) {
        return _cfg(screen).visualizer !== false;
    }
    function widgetsForScreen(screen) {
        var all = SettingsService.allWidgets;
        var entry = screen ? (all[screen.name] || all[screen.model]) : null;
        if (!entry || entry._enabled === false)
            entry = all["default"] || SettingsService._defaultWidgets;
        var def = SettingsService._defaultWidgets;
        return {
            left: entry.left || def.left,
            center: entry.center || def.center,
            right: entry.right || def.right
        };
    }
}
