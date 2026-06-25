pragma ComponentBehavior: Bound

import QtQuick

import qs.lib.service
import qs.modules.bar.layout.components
import qs.styles

ControlCenterCard {
    cardKey: "gpuTemp"
    contentHeight: 26
    gated: !SystemStatService.gpuAvailable
    title: "GPU Temperature"

    Text {
        color: {
            var t = SystemStatService.gpuTempC;
            if (t >= 85)
                return "#ef4444";
            if (t >= 70)
                return "#f97316";
            return ColorConfig.text;
        }
        font.bold: true
        font.family: FontConfig.fontFamily
        font.pixelSize: FontConfig.fontTempValue
        text: SystemStatService.gpuTempC + " °C"

        anchors {
            left: parent.left
            right: parent.right
        }
    }
}
