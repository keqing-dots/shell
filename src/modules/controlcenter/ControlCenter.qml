pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import qs.modules.controlcenter.layout

Scope {
    id: root

    property alias controller: controller

    signal closeRequested

    // Controller
    Item {
        id: controller

        property bool isOpen: false

        function close() {
            isOpen = false;
        }
        function open() {
            isOpen = true;
        }
        function toggle() {
            if (isOpen)
                close();
            else
                open();
        }
    }

    // Window
    ControlCenterWindow {
        id: window

        isOpen: controller.isOpen

        onClosed: root.closeRequested()
        onDismissRequested: controller.close()
    }
}
