pragma ComponentBehavior: Bound

import QtQuick

import qs.modules.settings.layout.components
import qs.modules.wallpaper
import qs.styles

Item {
    id: controlRow

    property var fillModes: ({})
    property string selectedScreen: ""
    property var wallpapers: ({})

    signal fillModeChanged(string mode)
    signal wallpaperRemoved

    height: WallpaperConfig.controlRowHeight

    Rectangle {
        anchors.centerIn: parent
        border.color: Qt.rgba(1, 0.3, 0.3, 0.5)
        border.width: 1
        color: removeMa.containsMouse ? "#44FF5555" : "transparent"
        height: WallpaperConfig.controlRowHeight - 8
        radius: GlobalConfig.radiusSm
        visible: !!controlRow.wallpapers[controlRow.selectedScreen]
        width: removeLabel.implicitWidth + WallpaperConfig.dropdownBtnPadding

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }

        Text {
            id: removeLabel

            anchors.centerIn: parent
            color: Qt.rgba(1, 0.4, 0.4, 1)
            font.family: GlobalConfig.fontFamily
            font.pixelSize: GlobalConfig.fontPixelSmaller
            text: "Remove"
        }
        MouseArea {
            id: removeMa

            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            onClicked: controlRow.wallpaperRemoved()
        }
    }
    DropdownMenu {
        activeValue: controlRow.fillModes[controlRow.selectedScreen] ?? "crop"
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        disabled: !controlRow.wallpapers[controlRow.selectedScreen]
        height: WallpaperConfig.controlRowHeight
        labelRole: "label"
        model: WallpaperConfig.fillModes
        valueRole: "mode"

        onItemSelected: mode => controlRow.fillModeChanged(mode)
    }
}
