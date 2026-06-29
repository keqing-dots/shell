pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.SystemTray

import qs.modules.bar
import qs.modules.bar.layout.components
import qs.modules.bar.service
import qs.config

WidgetCapsule {
    id: root

    capsuleVisible: SystemTray.items.length > 0
    iconGlyph: IconConfig.apps
    labelText: "System Tray"
    panelName: "trayPanel"
    showLabel: baseShowLabel

    MouseArea {
        acceptedButtons: Qt.LeftButton
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            var p = PanelService.getPanel("trayPanel", root.screen);
            if (!p)
                return;
            if (p.isPanelOpen && !p.isClosing)
                p.close();
            else
                p.open(root, {screen: root.screen});
        }
    }
}
