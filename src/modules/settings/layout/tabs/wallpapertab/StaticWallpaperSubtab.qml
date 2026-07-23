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
    readonly property var selectedFillModeMap: {
        var arr = WallpaperService.staticFillModes[root.selectedScreen] ?? [];
        var m = {};
        m[root.selectedScreen] = arr[root.selectedColumn] ?? "crop";
        return m;
    }
    property string selectedScreen: {
        var focusedName = HyprlandService.focusedMonitor?.name ?? "";
        if (focusedName && root.sortedScreens.some(s => s.name === focusedName))
            return focusedName;
        return root.sortedScreens.length > 0 ? root.sortedScreens[0].name : "";
    }
    readonly property var selectedWallpaperMap: {
        var arr = WallpaperService.staticWallpapers[root.selectedScreen] ?? [];
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
            columns: WallpaperService.staticColumns[root.selectedScreen] ?? 1
            selectedColumn: root.selectedColumn

            onColumnSelected: index => root.selectedColumn = index
            onColumnsRequested: n => {
                WallpaperService.setStaticColumns(root.selectedScreen, n);
                root.selectedColumn = 0;
            }
        }
        DirBar {
            id: dirBar

            Layout.fillWidth: true
            Layout.preferredHeight: WallpaperConfig.dirBarHeight
            currentDir: WallpaperService.staticDir
            scanning: WallpaperService.staticScanning

            onDirChangeRequested: path => WallpaperService.setStaticDir(path)
            onEscapePressed: {}
        }
        ControlRow {
            id: controlRow

            Layout.fillWidth: true
            Layout.preferredHeight: WallpaperConfig.controlRowHeight
            fillModes: root.selectedFillModeMap
            selectedScreen: root.selectedScreen
            wallpapers: root.selectedWallpaperMap

            onFillModeChanged: mode => WallpaperService.setStaticFillMode(root.selectedScreen, root.selectedColumn, mode)
            onWallpaperRemoved: WallpaperService.removeStaticWallpaper(root.selectedScreen, root.selectedColumn)
        }
        ImageGrid {
            Layout.fillHeight: true
            Layout.fillWidth: true
            imageFiles: WallpaperService.staticFiles
            selectedScreen: root.selectedScreen
            wallpapers: root.selectedWallpaperMap

            onWallpaperSelected: path => WallpaperService.setStaticWallpaper(root.selectedScreen, root.selectedColumn, path)
        }
    }
}
