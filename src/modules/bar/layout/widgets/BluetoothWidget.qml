pragma ComponentBehavior: Bound

import QtQuick

import qs.lib.service
import qs.modules.bar
import qs.modules.bar.layout.components
import qs.modules.bar.service
import qs.styles

WidgetCapsule {
    id: root

    readonly property var connectedDevice: BluetoothService.connectedDevices.length > 0 ? BluetoothService.connectedDevices[0] : null
    readonly property string connectedName: connectedDevice ? BluetoothService.deviceName(connectedDevice) : ""
    readonly property bool powered: BluetoothService.enabled

    iconGlyph: {
        if (!root.powered)
            return Icons.bluetoothOff;
        if (root.connectedDevice !== null)
            return Icons.bluetoothConnected;
        return Icons.bluetoothOn;
    }
    labelText: {
        if (!BluetoothService.available)
            return "Unavailable";
        if (!root.powered)
            return "Disconnected";
        if (root.connectedDevice !== null)
            return root.connectedName;
        return "Idle";
    }
    panelName: "bluetoothPanel"
    showLabel: baseShowLabel

    MouseArea {
        acceptedButtons: Qt.LeftButton
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: PanelService.getPanel("bluetoothPanel", root.screen)?.toggle(root)
    }
}
