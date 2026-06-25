pragma ComponentBehavior: Bound

import QtQuick

import qs.lib.layout
import qs.lib.service
import qs.modules.bar
import qs.modules.bar.layout.components
import qs.styles

ControlCenterCard {
    id: root

    cardKey: "systemStats"
    contentHeight: statsCol.implicitHeight
    title: "System"

    Column {
        id: statsCol

        spacing: 10

        anchors {
            left: parent.left
            right: parent.right
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 16

            Column {
                spacing: 4

                ArcGauge {
                    anchors.horizontalCenter: parent.horizontalCenter
                    arcColor: "#ef4444"
                    icon: Icons.cpu
                    value: SystemStatService.cpuUsage
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: ColorConfig.textDim
                    font.family: FontConfig.fontFamily
                    font.pixelSize: BarConfig.fontSize - 1
                    text: "CPU"
                }
            }
            Column {
                spacing: 4
                visible: SystemStatService.gpuAvailable
                width: visible ? implicitWidth : 0

                ArcGauge {
                    anchors.horizontalCenter: parent.horizontalCenter
                    arcColor: "#a855f7"
                    icon: Icons.gpu
                    value: SystemStatService.gpuUsage
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: ColorConfig.textDim
                    font.family: FontConfig.fontFamily
                    font.pixelSize: BarConfig.fontSize - 1
                    text: "GPU"
                }
            }
            Column {
                spacing: 4

                ArcGauge {
                    anchors.horizontalCenter: parent.horizontalCenter
                    arcColor: "#3b82f6"
                    icon: Icons.settings
                    value: SystemStatService.memPercent
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: ColorConfig.textDim
                    font.family: FontConfig.fontFamily
                    font.pixelSize: BarConfig.fontSize - 1
                    text: "RAM"
                }
            }
            Column {
                spacing: 4

                ArcGauge {
                    anchors.horizontalCenter: parent.horizontalCenter
                    arcColor: "#22c55e"
                    icon: Icons.folder
                    value: SystemStatService.diskRootPct
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: ColorConfig.textDim
                    font.family: FontConfig.fontFamily
                    font.pixelSize: BarConfig.fontSize - 1
                    text: "DISK"
                }
            }
        }
    }
}
