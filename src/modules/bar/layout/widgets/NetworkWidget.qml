pragma ComponentBehavior: Bound

import QtQuick

import qs.lib.service
import qs.modules.bar
import qs.modules.bar.layout.components
import qs.modules.bar.service
import qs.styles

WidgetCapsule {
    id: root

    readonly property bool connected: ethernet || ssid !== ""
    readonly property bool ethernet: NetworkService.ethernetConnected
    readonly property bool isPortal: NetworkService.connectivity === "portal"
    readonly property string networkLabel: ethernet ? "Ethernet" : ssid
    readonly property string ssid: NetworkService.connectedSsid

    iconGlyph: {
        if (root.isPortal)
            return Icons.lock;
        if (root.ethernet)
            return Icons.router;
        if (root.ssid !== "") {
            var sig = NetworkService.connectedSignal;
            if (sig > 75)
                return Icons.wifi;
            if (sig > 50)
                return Icons.wifi2;
            if (sig > 25)
                return Icons.wifi1;
            return Icons.wifi0;
        }
        if (NetworkService.ethernetAvailable && !NetworkService.wifiAvailable)
            return Icons.router;
        return Icons.wifiOff;
    }
    labelText: root.isPortal ? "Sign in" : (root.networkLabel !== "" ? root.networkLabel : "Wi-Fi")
    panelName: "networkPanel"
    showLabel: isPanelOpen || (baseShowLabel && (root.networkLabel !== "" || root.isPortal))

    MouseArea {
        acceptedButtons: Qt.LeftButton
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: PanelService.getPanel("networkPanel", root.screen)?.toggle(root)
    }
}
