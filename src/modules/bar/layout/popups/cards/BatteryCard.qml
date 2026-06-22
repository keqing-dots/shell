pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.UPower

import qs.lib.service
import qs.modules.bar
import qs.modules.bar.layout.components
import qs.styles

ControlCenterCard {
    id: root

    function formatTime(seconds) {
        if (!seconds || seconds <= 0)
            return "";
        var h = Math.floor(seconds / 3600);
        var m = Math.floor((seconds % 3600) / 60);
        return h + " h " + m + " min";
    }

    cardKey: "battery"
    contentHeight: batRow.height
    gated: !BatteryService.detected
    title: "Battery"

    Column {
        id: batRow

        spacing: 8

        anchors {
            left: parent.left
            right: parent.right
        }
        Row {
            spacing: 10
            width: parent.width

            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: {
                    if (BatteryService.charging || BatteryService.allFull)
                        return GlobalConfig.accent;
                    if (BatteryService.pct <= 15)
                        return "#F44747";
                    if (BatteryService.pct <= 30)
                        return "#E0A83A";
                    return GlobalConfig.text;
                }
                font.family: Icons.fontFamily
                font.pixelSize: 28
                text: {
                    if (BatteryService.charging || BatteryService.allFull)
                        return Icons.batteryCharging;
                    if (BatteryService.pct > 75)
                        return Icons.battery4;
                    if (BatteryService.pct > 50)
                        return Icons.battery3;
                    if (BatteryService.pct > 25)
                        return Icons.battery2;
                    return Icons.battery1;
                }
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    color: GlobalConfig.text
                    font.bold: true
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: BarConfig.fontSize + 1
                    text: "Battery " + BatteryService.pct + "%"
                }
                Text {
                    color: GlobalConfig.textDim
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: BarConfig.fontSize - 1
                    text: {
                        if (BatteryService.allFull)
                            return "Full";
                        if (BatteryService.charging && BatteryService.battery) {
                            var t = root.formatTime(BatteryService.battery.timeToFull);
                            return t !== "" ? t + " to full" : "Charging";
                        }
                        if (BatteryService.battery) {
                            var te = root.formatTime(BatteryService.battery.timeToEmpty);
                            return te !== "" ? te + " remaining" : "Discharging";
                        }
                        return "";
                    }
                }
            }
        }
        Rectangle {
            color: GlobalConfig.textAlpha10
            height: 6
            radius: 3
            width: parent.width

            Rectangle {
                color: {
                    if (BatteryService.charging || BatteryService.allFull)
                        return GlobalConfig.accent;
                    if (BatteryService.pct <= 15)
                        return "#F44747";
                    if (BatteryService.pct <= 30)
                        return "#E0A83A";
                    return GlobalConfig.accent;
                }
                height: parent.height
                radius: parent.radius
                width: Math.max(radius * 2, parent.width * Math.min(BatteryService.pct, 100) / 100)

                Behavior on color {
                    ColorAnimation {
                        duration: 300
                    }
                }
                Behavior on width {
                    NumberAnimation {
                        duration: 400
                    }
                }
            }
        }
    }
}
