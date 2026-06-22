pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import qs.modules.bar.layout.components
import qs.styles

WidgetCapsule {
    id: root

    iconGlyph: Icons.power

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: Quickshell.execDetached(["keqing-shell", "logout"])
    }
}
