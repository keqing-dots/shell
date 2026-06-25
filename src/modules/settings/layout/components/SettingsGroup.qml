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
        color: ColorConfig.text
        font.family: FontConfig.fontFamily
        font.pixelSize: FontConfig.fontSettingsBody
        font.weight: Font.DemiBold
        opacity: 0.45
        text: root.title
        visible: root.title !== ""
    }
    Rectangle {
        border.color: ColorConfig.textAlpha07
        border.width: 1
        color: ColorConfig.textAlpha04
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
