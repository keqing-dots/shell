pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import qs.modules.launcher
import qs.modules.launcher.layout
import qs.modules.launcher.service

Scope {
    id: root

    property alias controller: controller

    signal closeRequested

    LauncherController {
        id: controller

        browseRef: window.browseRef

        onCloseRequested: root.closeRequested()
    }
    LauncherWindow {
        id: window

        launcherRef: controller
        mode: controller.mode || LauncherConfig.modeDrun
        resultsModel: controller.resultsModel
        visible: controller.isOpen

        onDismissRequested: controller.goBack()
        onEntryActivated: controller.launch(modelData)
        onQueryEdited: text => controller.query = text
    }
}
