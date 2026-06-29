pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

import qs.components
import qs.modules.bar
import qs.modules.bar.layout.components
import qs.modules.bar.layout.popups
import qs.modules.bar.service
import qs.config

WidgetPanel {
    id: root

    property var screen: null

    readonly property int cellSize: BarConfig.iconSize + 16
    readonly property int columns: 5

    implicitHeight: headerItem.height + 12 + grid.implicitHeight + BarConfig.panelPadding * 2
    implicitWidth: columns * cellSize + BarConfig.panelPadding * 2

    TrayMenu {
        id: trayMenu

        screen: root.screen
    }
    MouseArea {
        anchors.fill: parent
    }
    Column {
        spacing: 0

        anchors {
            fill: parent
            margins: BarConfig.panelPadding
        }
        Item {
            id: headerItem

            height: 32
            width: parent.width

            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: ColorConfig.text
                font.bold: true
                font.family: FontConfig.fontFamily
                font.pixelSize: BarConfig.fontSize + 1
                text: "System Tray"
            }
            Rectangle {
                color: closeMa.containsMouse ? BarConfig.capsuleBgHover : BarConfig.capsuleBg
                height: 20
                radius: 10
                width: 20

                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
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
        Divider {
            width: parent.width
        }
        Item {
            height: 10
            width: parent.width
        }
        Grid {
            id: grid

            columns: root.columns
            spacing: 4
            width: parent.width

            Repeater {
                model: SystemTray.items

                delegate: Item {
                    id: trayBtn

                    required property SystemTrayItem modelData

                    height: root.cellSize
                    width: root.cellSize

                    Rectangle {
                        anchors.fill: parent
                        color: btnHover.containsMouse ? BarConfig.capsuleBgHover : "transparent"
                        radius: 6
                    }
                    IconImage {
                        anchors.centerIn: parent
                        height: BarConfig.iconSize
                        smooth: true
                        source: trayBtn.modelData.icon
                        width: BarConfig.iconSize
                    }
                    MouseArea {
                        id: btnHover

                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onClicked: function (mouse) {
                            if (mouse.button === Qt.RightButton && trayBtn.modelData.hasMenu)
                                PanelService.showTrayMenu(root.screen, trayBtn.modelData, trayMenu, trayBtn);
                            else
                                trayBtn.modelData.activate();
                        }
                    }
                }
            }
        }
    }
}
