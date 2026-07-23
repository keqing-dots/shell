pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

import qs.components
import qs.service
import qs.modules.settings
import qs.modules.settings.layout.components
import qs.config

ColumnLayout {
    id: root

    readonly property int previewH: Math.min(Math.round(280 * thumbRatio), 240)
    readonly property int previewW: (previewH < 240) ? 280 : Math.min(280, Math.round(previewH / thumbRatio))
    readonly property real thumbRatio: {
        var name = ColorSchemeService.selectedScreen;
        if (name) {
            for (var i = 0; i < Quickshell.screens.length; i++) {
                var s = Quickshell.screens[i];
                if (s.name === name && s.width > 0)
                    return s.height / s.width;
            }
        }
        return 9 / 16;
    }

    spacing: SettingsConfig.tileContentSpacing

    RowLayout {
        Layout.fillWidth: true
        spacing: SettingsConfig.tileContentSpacing

        Text {
            Layout.fillWidth: true
            color: ColorConfig.textDim
            font.family: FontConfig.fontFamily
            font.pixelSize: FontConfig.fontSettingsBody
            text: "Source Display"
        }
        DropdownMenu {
            activeValue: ColorSchemeService.selectedScreen
            disabled: ColorSchemeService.screens.length === 0
            model: ColorSchemeService.screens

            onItemSelected: value => ColorSchemeService.selectedScreen = value
        }
    }
    Rectangle {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredHeight: root.previewH
        Layout.preferredWidth: root.previewW
        clip: true
        color: ColorConfig.fieldBg
        radius: GlobalConfig.radiusSm
        visible: ColorSchemeService.selectedScreen !== ""

        Image {
            id: wpThumb

            anchors.fill: parent
            asynchronous: true
            clip: true
            fillMode: Image.PreserveAspectCrop
            opacity: status === Image.Ready ? 1.0 : 0.0
            smooth: true
            source: ColorSchemeService.wallpapers[ColorSchemeService.selectedScreen] ? "file://" + ColorSchemeService.wallpapers[ColorSchemeService.selectedScreen] : ""
            sourceSize: Qt.size(parent.width, parent.height)

            Behavior on opacity {
                NumberAnimation {
                    duration: SettingsConfig.wallpaperPreviewFadeMs
                }
            }
        }
        Text {
            anchors.centerIn: parent
            color: ColorConfig.textDim
            font.family: FontConfig.fontFamily
            font.pixelSize: FontConfig.fontCardIcon
            text: ""
            visible: wpThumb.status !== Image.Ready
        }
    }
    RowLayout {
        Layout.fillWidth: true
        spacing: SettingsConfig.tileContentSpacing
        visible: ColorSchemeService.selectedScreen !== ""

        Text {
            Layout.fillWidth: true
            color: ColorSchemeService.selectedStatus === "error" ? "#cf6679" : ColorConfig.textDim
            font.family: FontConfig.fontFamily
            font.pixelSize: FontConfig.fontSettingsBody
            text: {
                switch (ColorSchemeService.selectedStatus) {
                case "loading":
                    return "Extracting colors…";
                case "error":
                    return "Extraction failed";
                default:
                    return "";
                }
            }
        }
        Rectangle {
            border.color: ColorConfig.textAlpha12
            border.width: SettingsConfig.selectorBorderWidth
            color: "transparent"
            height: SettingsConfig.swatchSize
            radius: SettingsConfig.swatchRadius
            visible: ColorSchemeService.selectedStatus === "loading"
            width: SettingsConfig.swatchSize

            RotationAnimation on rotation {
                duration: SettingsConfig.spinnerRotationMs
                from: 0
                loops: Animation.Infinite
                running: ColorSchemeService.selectedStatus === "loading"
                to: 360
            }

            Rectangle {
                color: ColorConfig.accent
                height: SettingsConfig.spinnerDotSize
                radius: SettingsConfig.spinnerDotRadius
                width: SettingsConfig.spinnerDotSize

                anchors {
                    margins: SettingsConfig.spinnerDotInset
                    right: parent.right
                    top: parent.top
                }
            }
        }
    }
    ColumnLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: SettingsConfig.swatchGroupSpacing
        visible: ColorSchemeService.selectedStatus === "ready"

        Text {
            Layout.alignment: Qt.AlignHCenter
            color: ColorConfig.textDim
            font.family: FontConfig.fontFamily
            font.pixelSize: FontConfig.fontSettingsBody
            text: "Color Palette"
        }
        Column {
            Layout.alignment: Qt.AlignHCenter
            spacing: SettingsConfig.swatchRowSpacing

            Repeater {
                model: [[
                        {
                            name: "base",
                            key: "base"
                        },
                        {
                            name: "surface",
                            key: "surface"
                        },
                        {
                            name: "surfaceAlt",
                            key: "surfaceAlt"
                        },
                        {
                            name: "accentAltContainer",
                            key: "accentAltContainer"
                        },
                        {
                            name: "accentContainer",
                            key: "accentContainer"
                        },
                        {
                            name: "lavender",
                            key: "lavender"
                        },
                        {
                            name: "rose",
                            key: "rose"
                        },
                        {
                            name: "textMuted",
                            key: "textMuted"
                        }
                    ], [
                        {
                            name: "fieldBg",
                            key: "fieldBg"
                        },
                        {
                            name: "overlay",
                            key: "overlay"
                        },
                        {
                            name: "overlayAlt",
                            key: "overlayAlt"
                        },
                        {
                            name: "accentAlt",
                            key: "accentAlt"
                        },
                        {
                            name: "accentDim",
                            key: "accentDim"
                        },
                        {
                            name: "accent",
                            key: "accent"
                        },
                        {
                            name: "lavenderLight",
                            key: "lavenderLight"
                        },
                        {
                            name: "text",
                            key: "text"
                        }
                    ]]

                delegate: Row {
                    required property var modelData

                    spacing: SettingsConfig.swatchRowSpacing

                    Repeater {
                        model: parent.modelData

                        delegate: Rectangle {
                            required property var modelData

                            border.color: ColorConfig.textAlpha12
                            border.width: SettingsConfig.hairlineBorderWidth
                            color: ColorSchemeService.selectedColors ? (ColorSchemeService.selectedColors[modelData.key] ?? "transparent") : "transparent"
                            height: SettingsConfig.swatchSize
                            radius: SettingsConfig.swatchRadius
                            width: SettingsConfig.swatchSize

                            MouseArea {
                                ToolTip.delay: 300
                                ToolTip.text: parent.modelData.name + "\n" + (parent.color.toString().toUpperCase())
                                ToolTip.visible: containsMouse
                                anchors.fill: parent
                                hoverEnabled: true
                            }
                        }
                    }
                }
            }
        }
    }
    Text {
        Layout.alignment: Qt.AlignHCenter
        color: ColorConfig.textDim
        font.family: FontConfig.fontFamily
        font.pixelSize: FontConfig.fontSettingsBody
        text: "No active wallpapers configured"
        visible: ColorSchemeService.wallpapersLoaded && ColorSchemeService.screens.length === 0
    }
}
