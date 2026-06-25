pragma ComponentBehavior: Bound

import QtQuick

import qs.modules.bar.layout.components
import qs.modules.bar.service
import qs.styles

WidgetCapsule {
    id: root

    iconGlyph: IconConfig.controlCenter
    labelText: GlobalConfig.user
    panelName: "controlCenterPanel"
    showLabel: baseShowLabel

    MouseArea {
        acceptedButtons: Qt.LeftButton
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: PanelService.getPanel("controlCenterPanel", root.screen)?.toggle(root)
    }
}
