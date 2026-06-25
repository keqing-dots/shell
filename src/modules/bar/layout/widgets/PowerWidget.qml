pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import qs.modules.bar.layout.components
import qs.config

WidgetCapsule {
    id: root

    iconGlyph: IconConfig.power

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: Quickshell.execDetached(["keqing-shell", "logout"])
    }
}
