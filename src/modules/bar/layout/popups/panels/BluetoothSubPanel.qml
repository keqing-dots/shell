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

    clip: true
    implicitHeight: inner.implicitHeight + 2 * BarConfig.panelPadding
    implicitWidth: 320

    MouseArea {
        anchors.fill: parent
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

        Text {
            color: "#F44747"
            elide: Text.ElideRight
            font.family: FontConfig.fontFamily
            font.pixelSize: BarConfig.fontSize - 1
            horizontalAlignment: Text.AlignHCenter
            text: "Forget \"" + BluetoothService.deviceName(subRoot.device) + "\"?"
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
