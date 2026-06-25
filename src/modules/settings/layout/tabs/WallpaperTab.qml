pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.service
import qs.modules.settings.layout.tabs
import qs.modules.settings.layout.tabs.wallpapertab
import qs.modules.wallpaper
import qs.config

Item {
    id: root

    property string selectedScreen: root.sortedScreens.length > 0 ? root.sortedScreens[0].name : ""
    readonly property var sortedScreens: {
        var screens = [];
        for (var i = 0; i < Quickshell.screens.length; i++)
            screens.push(Quickshell.screens[i]);
        screens.sort(function (a, b) {
            return a.name < b.name ? -1 : a.name > b.name ? 1 : 0;
        });
        return screens;
    }

    ColumnLayout {
        id: colLayout

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: WallpaperConfig.columnSpacing

        Row {
            id: monitorRow

            Layout.fillWidth: true
            Layout.preferredHeight: WallpaperConfig.controlRowHeight
            spacing: WallpaperConfig.dropdownBtnSpacing

            Repeater {
                model: root.sortedScreens

                delegate: Rectangle {
                    required property var modelData

                    border.color: root.selectedScreen === modelData.name ? ColorConfig.accentAlt : "transparent"
                    border.width: 2
                    color: WallpaperConfig.tabInactive
                    height: WallpaperConfig.controlRowHeight
                    radius: GlobalConfig.radiusSm
                    width: (monitorRow.width - (root.sortedScreens.length - 1) * monitorRow.spacing) / Math.max(1, root.sortedScreens.length)

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 100
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        color: ColorConfig.text
                        font.family: FontConfig.fontFamily
                        font.pixelSize: FontConfig.fontSettingsBody
                        text: modelData.name
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: root.selectedScreen = parent.modelData.name
                    }
                }
            }
        }
        DirBar {
            id: dirBar

            Layout.fillWidth: true
            Layout.preferredHeight: WallpaperConfig.dirBarHeight
            currentDir: WallpaperService.currentDir
            scanning: WallpaperService.scanning

            onDirChangeRequested: path => WallpaperService.setDir(path)
            onEscapePressed: {}
        }
        ControlRow {
            id: controlRow

            Layout.fillWidth: true
            Layout.preferredHeight: WallpaperConfig.controlRowHeight
            fillModes: WallpaperService.currentFillModes
            selectedScreen: root.selectedScreen
            wallpapers: WallpaperService.currentWallpapers

            onFillModeChanged: mode => WallpaperService.setFillMode(root.selectedScreen, mode)
            onWallpaperRemoved: WallpaperService.removeWallpaper(root.selectedScreen)
        }
        ImageGrid {
            Layout.fillHeight: true
            Layout.fillWidth: true
            imageFiles: WallpaperService.imageFiles
            selectedScreen: root.selectedScreen
            wallpapers: WallpaperService.currentWallpapers

            onWallpaperSelected: path => WallpaperService.setWallpaper(root.selectedScreen, path)
        }
    }
}
