pragma ComponentBehavior: Bound

import QtQuick

import qs.components
import qs.service
import qs.modules.bar
import qs.modules.bar.layout.components
import qs.modules.bar.service
import qs.config

WidgetPanel {
    id: subRoot

    property var device: null
    property string mode: ""

    clip: true
    implicitHeight: inner.implicitHeight + 2 * BarConfig.panelPadding
    implicitWidth: 320

    MouseArea {
        anchors.fill: parent
    }
    Text {
        anchors.left: parent.left
        anchors.leftMargin: BarConfig.panelPadding
        anchors.top: parent.top
        anchors.topMargin: 6
        color: ColorConfig.textDim
        elide: Text.ElideRight
        font.family: FontConfig.fontFamily
        font.pixelSize: BarConfig.fontSize - 1
        height: 28
        text: BluetoothService.deviceName(subRoot.device)
        verticalAlignment: Text.AlignVCenter
        width: parent.width - BarConfig.panelPadding - closeBtn.width - 6 - 6
        z: 1
    }
    Rectangle {
        id: closeBtn

        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.top: parent.top
        anchors.topMargin: 6
        color: closeBtnMa.containsMouse ? BarConfig.capsuleBgHover : BarConfig.capsuleBg
        height: 28
        radius: 6
        width: 28
        z: 1

        Text {
            anchors.centerIn: parent
            color: ColorConfig.text
            font.family: IconConfig.fontFamily
            font.pixelSize: FontConfig.fontSubPanelClose
            text: IconConfig.close
        }
        MouseArea {
            id: closeBtnMa

            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            onClicked: PanelService.closeSubPanel()
        }
    }
    Column {
        id: inner

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: BarConfig.panelPadding
        spacing: 6
        width: parent.width - 2 * BarConfig.panelPadding

        // Disconnect
        Column {
            spacing: 6
            visible: subRoot.mode === "disconnect"
            width: parent.width

            Item {
                height: 14
                width: parent.width
            }
            Text {
                color: ColorConfig.text
                font.family: FontConfig.fontFamily
                font.pixelSize: BarConfig.fontSize - 1
                horizontalAlignment: Text.AlignHCenter
                text: "Disconnect?"
                width: parent.width
            }
            Item {
                height: 28
                width: parent.width

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6

                    Rectangle {
                        color: dOkMa.containsMouse ? Qt.rgba(1, 0.27, 0.27, 0.45) : Qt.rgba(1, 0.27, 0.27, 0.25)
                        height: 28
                        radius: 6
                        width: dOkLabel.implicitWidth + 16

                        Text {
                            id: dOkLabel

                            anchors.centerIn: parent
                            color: "#F44747"
                            font.family: FontConfig.fontFamily
                            font.pixelSize: BarConfig.fontSize - 1
                            text: "Disconnect"
                        }
                        MouseArea {
                            id: dOkMa

                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true

                            onClicked: {
                                BluetoothService.disconnectDevice(subRoot.device);
                                PanelService.closeSubPanel();
                            }
                        }
                    }
                    Rectangle {
                        color: dCancelMa.containsMouse ? BarConfig.capsuleBgHover : BarConfig.capsuleBg
                        height: 28
                        radius: 6
                        width: dCancelLabel.implicitWidth + 16

                        Text {
                            id: dCancelLabel

                            anchors.centerIn: parent
                            color: ColorConfig.text
                            font.family: FontConfig.fontFamily
                            font.pixelSize: BarConfig.fontSize - 1
                            text: "Cancel"
                        }
                        MouseArea {
                            id: dCancelMa

                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true

                            onClicked: PanelService.closeSubPanel()
                        }
                    }
                }
            }
        }

        // Forget
        Column {
            spacing: 6
            visible: subRoot.mode === "forget"
            width: parent.width

            Item {
                height: 14
                width: parent.width
            }
            Text {
                color: ColorConfig.text
                font.family: FontConfig.fontFamily
                font.pixelSize: BarConfig.fontSize - 1
                horizontalAlignment: Text.AlignHCenter
                text: "Forget?"
                width: parent.width
            }
            Item {
                height: 28
                width: parent.width

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6

                    Rectangle {
                        color: fOkMa.containsMouse ? Qt.rgba(1, 0.27, 0.27, 0.45) : Qt.rgba(1, 0.27, 0.27, 0.25)
                        height: 28
                        radius: 6
                        width: fOkLabel.implicitWidth + 16

                        Text {
                            id: fOkLabel

                            anchors.centerIn: parent
                            color: "#F44747"
                            font.family: FontConfig.fontFamily
                            font.pixelSize: BarConfig.fontSize - 1
                            text: "Forget"
                        }
                        MouseArea {
                            id: fOkMa

                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true

                            onClicked: {
                                BluetoothService.forgetDevice(subRoot.device);
                                PanelService.closeSubPanel();
                            }
                        }
                    }
                    Rectangle {
                        color: fCancelMa.containsMouse ? BarConfig.capsuleBgHover : BarConfig.capsuleBg
                        height: 28
                        radius: 6
                        width: fCancelLabel.implicitWidth + 16

                        Text {
                            id: fCancelLabel

                            anchors.centerIn: parent
                            color: ColorConfig.text
                            font.family: FontConfig.fontFamily
                            font.pixelSize: BarConfig.fontSize - 1
                            text: "Cancel"
                        }
                        MouseArea {
                            id: fCancelMa

                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true

                            onClicked: PanelService.closeSubPanel()
                        }
                    }
                }
            }
        }
    }
}
