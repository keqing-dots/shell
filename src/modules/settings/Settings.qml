pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import qs.lib.service
import qs.modules.settings.layout

Scope {
    id: root

    property alias controller: ctrl

    signal closeRequested

    QtObject {
        id: ctrl

        function close() {
            settingsWindow.close();
        }
        function open() {
            settingsWindow.open();
        }
    }
    SettingsWindow {
        id: settingsWindow

        onPanelClosed: root.closeRequested()
    }
}
