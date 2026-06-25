pragma ComponentBehavior: Bound

import QtQuick

import qs.lib.layout
import qs.lib.service
import qs.modules.bar
import qs.modules.bar.layout.components
import qs.modules.bar.service
import qs.styles

WidgetPanel {
    id: root

    clip: true
    implicitHeight: col.implicitHeight + BarConfig.panelPadding * 2
    implicitWidth: 300

    MouseArea {
        anchors.fill: parent
    }
    Column {
        id: col

        anchors.margins: BarConfig.panelPadding
        spacing: 0

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        Item {
            height: 32
            width: parent.width

            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: ColorConfig.text
                font.bold: true
                font.family: FontConfig.fontFamily
                font.pixelSize: BarConfig.fontSize + 1
                text: "System"
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
                    font.family: Icons.fontFamily
                    font.pixelSize: FontConfig.fontPanelActionIcon
                    text: Icons.close
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
        StatRow {
            extra: (SystemStatService.cpuTempC > 0 ? SystemStatService.cpuTempC + "°C · " : "") + SystemStatService.cpuFreq
            label: "CPU"
            pct: SystemStatService.cpuUsage / 100
            value: Math.round(SystemStatService.cpuUsage).toString().padStart(3) + "%"
            width: parent.width
        }
        Item {
            height: 10
            width: parent.width
        }
        StatRow {
            extra: SystemStatService.gpuTempC > 0 ? SystemStatService.gpuTempC + "°C" : ""
            height: visible ? implicitHeight : 0
            label: "GPU"
            pct: SystemStatService.gpuUsage / 100
            value: Math.round(SystemStatService.gpuUsage).toString().padStart(3) + "%"
            visible: SystemStatService.gpuAvailable
            width: parent.width
        }
        Item {
            height: visible ? 10 : 0
            visible: SystemStatService.gpuAvailable
            width: parent.width
        }
        StatRow {
            extra: SystemStatService.memUsedGb.toFixed(1) + " GiB / " + SystemStatService.memTotalGb.toFixed(1) + " GiB"
            label: "RAM"
            pct: SystemStatService.memPercent / 100
            value: SystemStatService.memPercent.toString().padStart(3) + "%"
            width: parent.width
        }
        Item {
            height: 10
            width: parent.width
        }
        StatRow {
            extra: SystemStatService.diskRootUsedGb.toFixed(1) + " GiB / " + SystemStatService.diskRootSizeGb.toFixed(1) + " GiB"
            label: "Disk"
            pct: SystemStatService.diskRootPct / 100
            value: SystemStatService.diskRootPct.toString().padStart(3) + "%"
            width: parent.width
        }
        Item {
            height: 10
            width: parent.width
        }
        Divider {
            width: parent.width
        }
        Item {
            height: 8
            width: parent.width
        }
        Row {
            spacing: 0
            width: parent.width

            Text {
                color: ColorConfig.textDim
                font.family: Icons.fontFamily
                font.pixelSize: BarConfig.fontSize
                text: Icons.arrowNarrowDown + " "
            }
            Text {
                color: ColorConfig.text
                font.family: FontConfig.fontFamily
                font.pixelSize: BarConfig.fontSize
                text: SystemStatService.formatSpeed(SystemStatService.rxBps)
                width: 60
            }
            Text {
                color: ColorConfig.textDim
                font.family: Icons.fontFamily
                font.pixelSize: BarConfig.fontSize
                text: Icons.arrowNarrowUp + " "
            }
            Text {
                color: ColorConfig.text
                font.family: FontConfig.fontFamily
                font.pixelSize: BarConfig.fontSize
                text: SystemStatService.formatSpeed(SystemStatService.txBps)
            }
        }
        Item {
            height: 10
            width: parent.width
        }
    }

    component StatRow: Item {
        id: statRow

        readonly property color barColor: {
            if (pct > 0.9)
                return "#F44747";
            if (pct > 0.7)
                return "#E0A83A";
            return ColorConfig.accent;
        }
        property string extra: ""
        property string label: ""
        property real pct: 0
        property string value: ""

        height: implicitHeight
        implicitHeight: rowCol.implicitHeight

        Column {
            id: rowCol

            spacing: 4

            anchors {
                left: parent.left
                right: parent.right
            }
            Item {
                height: labelText.implicitHeight
                width: parent.width

                Text {
                    id: labelText

                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    color: ColorConfig.textDim
                    font.family: FontConfig.fontFamily
                    font.pixelSize: BarConfig.fontSize
                    text: statRow.label + (statRow.extra !== "" ? "  " + statRow.extra : "")
                }
                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    color: statRow.barColor
                    font.bold: true
                    font.family: FontConfig.fontFamily
                    font.pixelSize: BarConfig.fontSize
                    text: statRow.value
                }
            }
            Rectangle {
                color: ColorConfig.textAlpha08
                height: 5
                radius: 3
                width: parent.width

                Rectangle {
                    color: statRow.barColor
                    height: parent.height
                    radius: parent.radius
                    width: Math.max(radius * 2, parent.width * Math.min(statRow.pct, 1.0))

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                    Behavior on width {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }
}
