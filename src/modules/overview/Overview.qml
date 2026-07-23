pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import qs.modules.overview.layout
import qs.modules.overview.service

Scope {
    id: root

    property alias controller: controller

    signal closeRequested

    Component.onCompleted: controller.open()

    Item {
        id: controller

        function close() {
            GlobalStates.overviewOpen = false;
        }
        function open() {
            GlobalStates.overviewOpen = true;
        }
    }
    OverviewWindow {
        onOverviewClosed: root.closeRequested()
        onRequestClose: root.controller.close()
    }
}
