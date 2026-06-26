pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Bluetooth

import qs.components
import qs.service
import qs.modules.bar
import qs.modules.bar.layout.components
import qs.modules.bar.service
import qs.config

WidgetPanel {
    id: panelRoot

    function startScan() {
        if (BluetoothService.available && BluetoothService.enabled) {
            BluetoothService.setScanning(true);
            scanTimeout.restart();
        }
    }

    clip: true
    implicitHeight: Math.min(480, BarConfig.panelPadding + header.height + 4 + topDiv.height + 8 + content.contentHeight + BarConfig.panelPadding)
    implicitWidth: 300

    Component.onCompleted: startScan()
    Component.onDestruction: BluetoothService.setScanning(false)

    Connections {
        function onEnabledChanged() {
            panelRoot.startScan();
        }

        target: BluetoothService
    }
    Timer {
        id: scanTimeout

        interval: 30000

        onTriggered: BluetoothService.setScanning(false)
    }
    MouseArea {
        anchors.fill: parent
    }
    Item {
        id: header

        anchors.margins: BarConfig.panelPadding
        height: 32

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            color: ColorConfig.text
            font.bold: true
            font.family: FontConfig.fontFamily
            font.pixelSize: BarConfig.fontSize + 1
            text: "Bluetooth"
        }
        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                color: ColorConfig.accent
                height: 8
                radius: 4
                visible: BluetoothService.available && BluetoothService.scanning
                width: 8
            }
            Toggle {
                active: BluetoothService.enabled
                anchors.verticalCenter: parent.verticalCenter
                visible: BluetoothService.available

                onToggled: BluetoothService.setEnabled(!BluetoothService.enabled)
            }
            Rectangle {
                color: closeMa.containsMouse ? BarConfig.capsuleBgHover : BarConfig.capsuleBg
                height: 22
                radius: 11
                width: 22

                Text {
                    anchors.centerIn: parent
                    color: ColorConfig.text
                    font.family: IconConfig.fontFamily
                    font.pixelSize: FontConfig.fontPanelActionIcon
                    text: IconConfig.close
                }
                MouseArea {
                    id: closeMa

                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked: PanelService.closePanel()
                }
            }
        }
    }
    Divider {
        id: topDiv

        anchors.topMargin: 4

        anchors {
            left: parent.left
            right: parent.right
            top: header.bottom
        }
    }
    Flickable {
        id: content

        anchors.margins: BarConfig.panelPadding
        anchors.topMargin: 8
        clip: true
        contentHeight: col.implicitHeight

        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            top: topDiv.bottom
        }
        Column {
            id: col

            spacing: 5
            width: content.width

            Item {
                height: visible ? 72 : 0
                visible: !BluetoothService.available
                width: parent.width

                Text {
                    anchors.centerIn: parent
                    color: ColorConfig.textDim
                    font.family: FontConfig.fontFamily
                    font.pixelSize: BarConfig.fontSize
                    text: "No adapter found"
                }
            }
            Item {
                height: visible ? 72 : 0
                visible: BluetoothService.available && !BluetoothService.enabled
                width: parent.width

                Text {
                    anchors.centerIn: parent
                    color: ColorConfig.textDim
                    font.family: FontConfig.fontFamily
                    font.pixelSize: BarConfig.fontSize
                    text: "Bluetooth is off"
                }
            }
            Item {
                height: visible ? 72 : 0
                visible: BluetoothService.enabled && BluetoothService.connectedDevices.length === 0 && BluetoothService.pairedDevices.length === 0 && BluetoothService.nearbyDevices.length === 0
                width: parent.width

                Text {
                    anchors.centerIn: parent
                    color: ColorConfig.textDim
                    font.family: FontConfig.fontFamily
                    font.pixelSize: BarConfig.fontSize
                    text: "No paired devices"
                }
            }
            Item {
                height: visible ? 20 : 0
                visible: BluetoothService.enabled && BluetoothService.connectedDevices.length > 0
                width: parent.width

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    color: ColorConfig.textDim
                    font.bold: true
                    font.family: FontConfig.fontFamily
                    font.pixelSize: BarConfig.fontSize - 1
                    text: "Connected"
                }
            }
            Repeater {
                model: BluetoothService.enabled ? BluetoothService.connectedDevices : []

                delegate: DevRow {}
            }
            Item {
                height: visible ? 24 : 0
                visible: BluetoothService.enabled && BluetoothService.pairedDevices.length > 0
                width: parent.width

                Text {
                    anchors.bottom: parent.bottom
                    color: ColorConfig.textDim
                    font.bold: true
                    font.family: FontConfig.fontFamily
                    font.pixelSize: BarConfig.fontSize - 1
                    text: "Paired"
                }
            }
            Repeater {
                model: BluetoothService.enabled ? BluetoothService.pairedDevices : []

                delegate: DevRow {}
            }
            Item {
                height: visible ? 24 : 0
                visible: BluetoothService.scanning && BluetoothService.nearbyDevices.length > 0
                width: parent.width

                Text {
                    anchors.bottom: parent.bottom
                    color: ColorConfig.textDim
                    font.bold: true
                    font.family: FontConfig.fontFamily
                    font.pixelSize: BarConfig.fontSize - 1
                    text: "Nearby"
                }
            }
            Repeater {
                model: BluetoothService.scanning ? BluetoothService.nearbyDevices : []

                delegate: DevRow {}
            }
            Item {
                height: 4
                width: 1
            }
        }
    }

    component DevRow: Item {
        id: devRow

        readonly property bool isBusy: BluetoothService.isBusy(modelData)
        readonly property bool isConnected: modelData.connected
        readonly property bool isPairedOrConnected: {
            try {
                return modelData.paired || modelData.trusted || modelData.connected;
            } catch (e) {
                return false;
            }
        }
        required property var modelData

        height: 50
        width: parent.width

        Rectangle {
            anchors.fill: parent
            color: {
                if (devRow.isConnected)
                    return ColorConfig.accentAlpha25;
                if (devRow.isBusy)
                    return ColorConfig.accentAlpha12;
                return devHover.containsMouse ? BarConfig.capsuleBgHover : BarConfig.capsuleBg;
            }
            radius: 8

            HoverHandler {
                id: devHover
            }
            Text {
                id: devIcon

                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                color: ColorConfig.text
                font.family: IconConfig.fontFamily
                font.pixelSize: BarConfig.iconSize
                horizontalAlignment: Text.AlignHCenter
                opacity: devRow.isConnected ? 1.0 : 0.6
                text: IconConfig.bluetoothDevice
                width: BarConfig.iconSize
            }
            Column {
                anchors.left: devIcon.right
                anchors.leftMargin: 8
                anchors.right: devActions.left
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Text {
                    color: devRow.isConnected ? ColorConfig.accent : ColorConfig.text
                    elide: Text.ElideRight
                    font.bold: devRow.isConnected
                    font.family: FontConfig.fontFamily
                    font.pixelSize: BarConfig.fontSize
                    text: BluetoothService.deviceName(devRow.modelData)
                    width: parent.width
                }
                Text {
                    color: ColorConfig.accent
                    font.family: FontConfig.fontFamily
                    font.pixelSize: BarConfig.fontSize - 2
                    text: {
                        try {
                            if (devRow.modelData.pairing)
                                return "Pairing…";
                            if (devRow.modelData.state === BluetoothDevice.Connecting)
                                return "Connecting…";
                            if (devRow.modelData.state === BluetoothDevice.Disconnecting)
                                return "Disconnecting…";
                        } catch (e) {}
                        return "";
                    }
                    visible: devRow.isBusy
                }
                Row {
                    spacing: 3
                    visible: !devRow.isBusy && devRow.modelData.batteryAvailable

                    Text {
                        color: ColorConfig.textDim
                        font.family: IconConfig.fontFamily
                        font.pixelSize: BarConfig.fontSize - 2
                        text: {
                            try {
                                var b = devRow.modelData.battery;
                                if (b === undefined)
                                    return "";
                                var pct = Math.round(b * 100);
                                if (pct <= 20)
                                    return IconConfig.battery1;
                                if (pct <= 40)
                                    return IconConfig.battery2;
                                if (pct <= 80)
                                    return IconConfig.battery3;
                                return IconConfig.battery4;
                            } catch (e) {
                                return "";
                            }
                        }
                    }
                    Text {
                        color: ColorConfig.textDim
                        font.family: FontConfig.fontFamily
                        font.pixelSize: BarConfig.fontSize - 2
                        text: {
                            try {
                                var b = devRow.modelData.battery;
                                if (b === undefined)
                                    return "";
                                return Math.round(b * 100) + "%";
                            } catch (e) {
                                return "";
                            }
                        }
                    }
                }
            }
            Row {
                id: devActions

                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Rectangle {
                    color: {
                        if (devRow.isConnected)
                            return actionMa.containsMouse ? ColorConfig.textAlpha18 : ColorConfig.textAlpha10;
                        return actionMa.containsMouse ? Qt.lighter(ColorConfig.accent, 1.2) : ColorConfig.accent;
                    }
                    height: 22
                    radius: 11
                    visible: !devRow.isBusy
                    width: actionLabel.implicitWidth + 16

                    Text {
                        id: actionLabel

                        anchors.centerIn: parent
                        color: devRow.isConnected ? ColorConfig.text : "white"
                        font.family: FontConfig.fontFamily
                        font.pixelSize: BarConfig.fontSize - 1
                        text: devRow.isConnected ? "Disconnect" : "Connect"
                    }
                    MouseArea {
                        id: actionMa

                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onClicked: {
                            if (devRow.isConnected) {
                                PanelService.openSubPanelForCurrent("bluetoothSubPanel", {
                                    "device": devRow.modelData,
                                    "mode": "disconnect"
                                });
                            } else {
                                BluetoothService.connectDevice(devRow.modelData);
                            }
                        }
                    }
                }
                Rectangle {
                    color: forgetMa.containsMouse ? Qt.rgba(1, 0.27, 0.27, 0.3) : Qt.rgba(1, 0.27, 0.27, 0.12)
                    height: 22
                    radius: 11
                    visible: devRow.isPairedOrConnected && !devRow.isConnected && !devRow.isBusy
                    width: 22

                    Text {
                        anchors.centerIn: parent
                        color: "#F44747"
                        font.family: IconConfig.fontFamily
                        font.pixelSize: FontConfig.fontListItemRemove
                        text: IconConfig.close
                    }
                    MouseArea {
                        id: forgetMa

                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onClicked: PanelService.openSubPanelForCurrent("bluetoothSubPanel", {
                            "device": devRow.modelData,
                            "mode": "forget"
                        })
                    }
                }
            }
        }
    }
}
