pragma ComponentBehavior: Bound

import QtQuick

import qs.modules.settings
import qs.styles

Column {
    id: root

    default property alias content: inner.data
    property int contentSpacing: 0
    property string title: ""

    spacing: 8

    Text {
        color: GlobalConfig.text
        font.family: GlobalConfig.fontFamily
        font.pixelSize: GlobalConfig.fontPixelSmaller
        font.weight: Font.DemiBold
        opacity: 0.45
        text: root.title
        visible: root.title !== ""
    }
    Rectangle {
        border.color: GlobalConfig.textAlpha07
        border.width: 1
        color: GlobalConfig.textAlpha04
        implicitHeight: inner.implicitHeight + 24
        radius: 8
        width: root.width

        Column {
            id: inner

            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.top: parent.top
            anchors.topMargin: 12
            spacing: root.contentSpacing
        }
    }
}
