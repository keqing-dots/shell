pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.service
import qs.modules.settings
import qs.config

ColumnLayout {
    Layout.alignment: Qt.AlignHCenter
    spacing: SettingsConfig.swatchGroupSpacing

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
                        "name": "base",
                        "key": "base"
                    },
                    {
                        "name": "surface",
                        "key": "surface"
                    },
                    {
                        "name": "surfaceAlt",
                        "key": "surfaceAlt"
                    },
                    {
                        "name": "accentAltContainer",
                        "key": "accentAltContainer"
                    },
                    {
                        "name": "accentContainer",
                        "key": "accentContainer"
                    },
                    {
                        "name": "lavender",
                        "key": "lavender"
                    },
                    {
                        "name": "rose",
                        "key": "rose"
                    },
                    {
                        "name": "textMuted",
                        "key": "textMuted"
                    }
                ], [
                    {
                        "name": "fieldBg",
                        "key": "fieldBg"
                    },
                    {
                        "name": "overlay",
                        "key": "overlay"
                    },
                    {
                        "name": "overlayAlt",
                        "key": "overlayAlt"
                    },
                    {
                        "name": "accentAlt",
                        "key": "accentAlt"
                    },
                    {
                        "name": "accentDim",
                        "key": "accentDim"
                    },
                    {
                        "name": "accent",
                        "key": "accent"
                    },
                    {
                        "name": "lavenderLight",
                        "key": "lavenderLight"
                    },
                    {
                        "name": "text",
                        "key": "text"
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
                        color: ColorSchemeService.currentColors ? (ColorSchemeService.currentColors[modelData.key] ?? "transparent") : "transparent"
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
