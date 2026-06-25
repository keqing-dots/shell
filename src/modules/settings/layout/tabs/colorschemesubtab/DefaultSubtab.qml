pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.lib.service
import qs.modules.settings
import qs.styles

ColumnLayout {
    Layout.alignment: Qt.AlignHCenter
    spacing: 6

    Text {
        Layout.alignment: Qt.AlignHCenter
        color: GlobalConfig.textDim
        font.family: GlobalConfig.fontFamily
        font.pixelSize: GlobalConfig.fontPixelSmaller
        text: "Color Palette"
    }
    Column {
        Layout.alignment: Qt.AlignHCenter
        spacing: 4

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

                spacing: 4

                Repeater {
                    model: parent.modelData

                    delegate: Rectangle {
                        required property var modelData

                        border.color: ColorSchemeConfig.border
                        border.width: 1
                        color: ColorSchemeService.currentColors ? (ColorSchemeService.currentColors[modelData.key] ?? "transparent") : "transparent"
                        height: 28
                        radius: 14
                        width: 28

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
