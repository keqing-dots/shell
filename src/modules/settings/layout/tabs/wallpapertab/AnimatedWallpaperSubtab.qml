pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.service
import qs.modules.settings
import qs.modules.settings.layout.tabs.wallpapertab
import qs.modules.wallpaper
import qs.config

Item {
    id: root

    property int selectedColumn: 0
    property string selectedScreen: {
        var focusedName = HyprlandService.focusedMonitor?.name ?? "";
        if (focusedName && root.sortedScreens.some(s => s.name === focusedName))
            return focusedName;
        return root.sortedScreens.length > 0 ? root.sortedScreens[0].name : "";
    }
    readonly property var selectedVideoMap: {
        var arr = WallpaperService.animatedWallpapers[root.selectedScreen] ?? [];
        var m = {};
        m[root.selectedScreen] = arr[root.selectedColumn] ?? "";
        return m;
    }
    readonly property var sortedScreens: {
        var screens = [];
        for (var i = 0; i < Quickshell.screens.length; i++)
            screens.push(Quickshell.screens[i]);
        screens.sort(function (a, b) {
            return a.name < b.name ? -1 : a.name > b.name ? 1 : 0;
        });
        return screens;
    }

    onSelectedScreenChanged: root.selectedColumn = 0

    ColumnLayout {
        id: colLayout

        anchors.fill: parent
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
                    border.width: SettingsConfig.selectorBorderWidth
                    color: ColorConfig.lavenderAlpha20
                    height: WallpaperConfig.controlRowHeight
                    radius: GlobalConfig.radiusSm
                    width: (monitorRow.width - (root.sortedScreens.length - 1) * monitorRow.spacing) / Math.max(1, root.sortedScreens.length)

                    Behavior on border.color {
                        ColorAnimation {
                            duration: SettingsConfig.quickColorAnimMs
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
        RegionPicker {
            Layout.fillWidth: true
            columns: WallpaperService.animatedColumns[root.selectedScreen] ?? 1
            selectedColumn: root.selectedColumn

            onColumnSelected: index => root.selectedColumn = index
            onColumnsRequested: n => {
                WallpaperService.setAnimatedColumns(root.selectedScreen, n);
                root.selectedColumn = 0;
            }
        }
        DirBar {
            id: dirBar

            Layout.fillWidth: true
            Layout.preferredHeight: WallpaperConfig.dirBarHeight
            currentDir: WallpaperService.animatedDir
            scanning: WallpaperService.animatedScanning

            onDirChangeRequested: path => WallpaperService.setAnimatedDir(path)
            onEscapePressed: {}
        }
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: WallpaperConfig.controlRowHeight

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                border.color: Qt.rgba(1, 0.3, 0.3, 0.5)
                border.width: SettingsConfig.hairlineBorderWidth
                color: removeMa.containsMouse ? "#44FF5555" : "transparent"
                height: WallpaperConfig.controlRowHeight - SettingsConfig.groupContentSpacingSm
                radius: GlobalConfig.radiusSm
                visible: !!root.selectedVideoMap[root.selectedScreen]
                width: removeLabel.implicitWidth + WallpaperConfig.dropdownBtnPadding

                Behavior on color {
                    ColorAnimation {
                        duration: SettingsConfig.quickColorAnimMs
                    }
                }

                Text {
                    id: removeLabel

                    anchors.centerIn: parent
                    color: Qt.rgba(1, 0.4, 0.4, 1)
                    font.family: FontConfig.fontFamily
                    font.pixelSize: FontConfig.fontSettingsBody
                    text: "Remove"
                }
                MouseArea {
                    id: removeMa

                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked: WallpaperService.removeAnimatedWallpaper(root.selectedScreen, root.selectedColumn)
                }
            }
        }
        ImageGrid {
            Layout.fillHeight: true
            Layout.fillWidth: true
            imageFiles: WallpaperService.animatedFiles
            previewSources: WallpaperService.animatedThumbnails
            selectedScreen: root.selectedScreen
            wallpapers: root.selectedVideoMap

            onWallpaperSelected: path => WallpaperService.setAnimatedWallpaper(root.selectedScreen, root.selectedColumn, path)
        }
    }
}
