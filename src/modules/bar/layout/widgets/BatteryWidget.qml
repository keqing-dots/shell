pragma ComponentBehavior: Bound

import QtQuick

import qs.lib.service
import qs.modules.bar
import qs.modules.bar.layout.components
import qs.modules.bar.service
import qs.styles

WidgetCapsule {
    id: root

    borderColor: {
        if (BatteryService.allFull)
            return ColorConfig.text;
        if (BatteryService.anyCharging)
            return ColorConfig.accentAlt;
        if (BatteryService.pct <= 25)
            return "#ff5555";
        return BarConfig.capsuleBorder;
    }
    capsuleVisible: BatteryService.detected
    iconGlyph: {
        if (BatteryService.allFull)
            return Icons.pluggedIn;
        if (BatteryService.anyCharging)
            return Icons.batteryCharging;
        if (BatteryService.pct <= 25)
            return Icons.battery1;
        if (BatteryService.pct <= 50)
            return Icons.battery2;
        if (BatteryService.pct <= 75)
            return Icons.battery3;
        return Icons.battery4;
    }
    implicitHeight: visible ? BarConfig.capsuleHeight : 0
    labelText: BatteryService.allFull ? "Plugged in" : BatteryService.pct.toString().padStart(3) + "%"
    panelName: "batteryPanel"
    showLabel: baseShowLabel
    visible: BatteryService.detected || !(config.hideIfNotDetected !== false)

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(1, 0, 0, 0.15)
        radius: BarConfig.capsuleRadius
        visible: !BatteryService.anyCharging && !BatteryService.allFull && BatteryService.pct <= 10
    }
    MouseArea {
        acceptedButtons: Qt.LeftButton
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: PanelService.getPanel("batteryPanel", root.screen)?.toggle(root)
    }
}
