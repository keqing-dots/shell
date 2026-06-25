pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

import qs.modules.bar
import qs.modules.bar.layout.components
import qs.modules.bar.layout.popups
import qs.modules.bar.service
import qs.styles

WidgetCapsule {
    id: root

    readonly property string arrowGlyph: {
        var pointRight = (arrowSide === "right") !== collapsed;
        return pointRight ? IconConfig.chevronRight : IconConfig.chevronLeft;
    }
    readonly property string arrowSide: config.arrowSide || "right"
    property bool collapsed: !config.startExpanded

    capsuleVisible: trayRepeater.count > 0
    implicitWidth: contentRow.implicitWidth + 12

    TrayMenu {
        id: trayMenu

        screen: root.screen
    }
    Row {
        id: contentRow

        anchors.centerIn: parent
        layoutDirection: (config.direction || (root.arrowSide === "right" ? "rtl" : "ltr")) === "rtl" ? Qt.RightToLeft : Qt.LeftToRight
        spacing: 0

        Item {
            height: BarConfig.capsuleHeight
            width: BarConfig.iconSize + 8

            Text {
                anchors.centerIn: parent
                color: ColorConfig.text
                font.family: IconConfig.fontFamily
                font.pixelSize: BarConfig.iconSize
                text: root.arrowGlyph
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onClicked: root.collapsed = !root.collapsed
            }
        }
        Repeater {
            id: trayRepeater

            model: SystemTray.items

            delegate: Item {
                id: trayBtn

                required property SystemTrayItem modelData
                readonly property bool shown: !root.collapsed && (!root.config.hidePassive || modelData.status !== SystemTrayItem.Passive)

                clip: true
                height: BarConfig.capsuleHeight
                width: shown ? BarConfig.iconSize + 8 : 0

                Behavior on width {
                    NumberAnimation {
                        duration: GlobalConfig.animationFast
                        easing.type: Easing.OutCubic
                    }
                }

                IconImage {
                    anchors.centerIn: parent
                    height: BarConfig.iconSize
                    smooth: true
                    source: trayBtn.modelData.icon
                    width: BarConfig.iconSize
                }
                MouseArea {
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

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
