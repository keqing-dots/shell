pragma ComponentBehavior: Bound

import QtQuick

import qs.lib.service
import qs.modules.bar
import qs.modules.bar.layout.components
import qs.modules.bar.service
import qs.styles

WidgetCapsule {
    id: root

    implicitWidth: label.implicitWidth + 16

    Text {
        id: label

        anchors.centerIn: parent
        color: ColorConfig.text
        font.family: FontConfig.fontFamily
        font.pixelSize: BarConfig.fontSize
        text: Qt.formatDateTime(DateTimeService.date, config.format || "ddd yyyy-MM-dd hh:mm:ss")
    }
    MouseArea {
        acceptedButtons: Qt.LeftButton
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: PanelService.getPanel("clockPanel", root.screen)?.toggle(root)
    }
}
