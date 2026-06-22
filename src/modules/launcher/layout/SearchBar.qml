pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.modules.launcher
import qs.styles

RowLayout {
    id: root

    property alias input: input
    property string mode
    property int size: LauncherConfig.entryHeight

    spacing: LauncherConfig.searchbarSpacing

    Rectangle {
        Layout.preferredHeight: root.size
        Layout.preferredWidth: root.size
        border.color: GlobalConfig.accent
        border.width: LauncherConfig.searchbarBorderWidth
        color: "transparent"
        radius: LauncherConfig.searchbarRadius

        Text {
            anchors.centerIn: parent
            color: GlobalConfig.text
            font.family: Icons.fontFamily
            font.pixelSize: LauncherConfig.searchbarFontPx
            text: LauncherConfig.modeIcons[root.mode] || ""
        }
    }
    TextField {
        id: input

        Layout.fillWidth: true
        Layout.preferredHeight: root.size
        color: GlobalConfig.text
        focus: true
        font.family: GlobalConfig.fontFamily
        font.pixelSize: LauncherConfig.searchbarFontPx
        leftPadding: LauncherConfig.searchbarPadding
        rightPadding: LauncherConfig.searchbarPadding
        verticalAlignment: Text.AlignVCenter
        z: 2

        background: Rectangle {
            border.color: GlobalConfig.accent
            border.width: LauncherConfig.searchbarBorderWidth
            color: "transparent"
            radius: LauncherConfig.searchbarRadius
        }
    }
}
