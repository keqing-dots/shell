pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.modules.settings
import qs.modules.wallpaper
import qs.config

Item {
    id: root

    property int columns: 1
    property int selectedColumn: 0

    signal columnSelected(int index)
    signal columnsRequested(int n)

    implicitHeight: WallpaperConfig.controlRowHeight * 2 + WallpaperConfig.dropdownBtnSpacing

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: WallpaperConfig.dropdownBtnSpacing

        Row {
            id: countRow

            Layout.fillWidth: true
            Layout.preferredHeight: WallpaperConfig.controlRowHeight
            spacing: WallpaperConfig.dropdownBtnSpacing

            Repeater {
                model: WallpaperConfig.maxColumns

                delegate: Rectangle {
                    id: countBtn

                    readonly property int count: index + 1
                    required property int index

                    border.color: root.columns === countBtn.count ? ColorConfig.accentAlt : "transparent"
                    border.width: SettingsConfig.selectorBorderWidth
                    color: ColorConfig.lavenderAlpha20
                    height: WallpaperConfig.controlRowHeight
                    radius: GlobalConfig.radiusSm
                    width: (countRow.width - (WallpaperConfig.maxColumns - 1) * countRow.spacing) / WallpaperConfig.maxColumns

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
                        text: countBtn.count
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: root.columnsRequested(countBtn.count)
                    }
                }
            }
        }
        Row {
            id: previewRow

            Layout.fillWidth: true
            Layout.preferredHeight: WallpaperConfig.controlRowHeight
            spacing: SettingsConfig.regionPreviewSpacing

            Repeater {
                model: root.columns

                delegate: Rectangle {
                    id: previewSlice

                    required property int index

                    border.color: root.selectedColumn === previewSlice.index ? ColorConfig.accentAlt : ColorConfig.textAlpha12
                    border.width: SettingsConfig.selectorBorderWidth
                    color: ColorConfig.lavenderAlpha20
                    height: previewRow.height
                    radius: GlobalConfig.radiusSm
                    width: (previewRow.width - (root.columns - 1) * previewRow.spacing) / root.columns

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
                        text: previewSlice.index + 1
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: root.columnSelected(previewSlice.index)
                    }
                }
            }
        }
    }
}
