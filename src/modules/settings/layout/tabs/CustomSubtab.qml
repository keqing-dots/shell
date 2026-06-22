pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.lib.service
import qs.modules.settings
import qs.styles

ColumnLayout {
    spacing: 10

    // Surface
    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Text {
            Layout.preferredWidth: 80
            color: GlobalConfig.textDim
            font.family: GlobalConfig.fontFamily
            font.pixelSize: GlobalConfig.fontPixelSmaller
            text: "Background"
        }
        Rectangle {
            Layout.fillWidth: true
            border.color: bgField.activeFocus ? GlobalConfig.accent : GlobalConfig.textAlpha15
            border.width: 1
            color: GlobalConfig.textAlpha07
            height: 28
            radius: 4

            Behavior on border.color {
                ColorAnimation {
                    duration: GlobalConfig.animationFast
                }
            }

            TextInput {
                id: bgField

                anchors.fill: parent
                anchors.margins: 6
                color: GlobalConfig.text
                font.family: GlobalConfig.fontFamily
                font.pixelSize: GlobalConfig.fontPixelSmaller
                selectByMouse: true
                text: ColorSchemeService.customBg

                onEditingFinished: {
                    var c = text.trim();
                    if (!c.startsWith("#"))
                        c = "#" + c;
                    if (Qt.colorValid(c))
                        ColorSchemeService.setCustomColors(c, ColorSchemeService.customAccent, ColorSchemeService.customAccentAlt, ColorSchemeService.customBase, ColorSchemeService.customSurfaceAlt, ColorSchemeService.customAccentContainer, ColorSchemeService.customAccentAltContainer, ColorSchemeService.customLavender, ColorSchemeService.customTextMuted, ColorSchemeService.customText);
                }
            }
        }
        Rectangle {
            border.color: ColorSchemeConfig.border
            border.width: 1
            color: ColorSchemeService.currentColors.fieldBg
            height: 24
            radius: 12
            width: 24
        }
    }
    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Text {
            Layout.preferredWidth: 80
            color: GlobalConfig.textDim
            font.family: GlobalConfig.fontFamily
            font.pixelSize: GlobalConfig.fontPixelSmaller
            text: "Base"
        }
        Rectangle {
            Layout.fillWidth: true
            border.color: baseField.activeFocus ? GlobalConfig.accent : GlobalConfig.textAlpha15
            border.width: 1
            color: GlobalConfig.textAlpha07
            height: 28
            radius: 4

            Behavior on border.color {
                ColorAnimation {
                    duration: GlobalConfig.animationFast
                }
            }

            TextInput {
                id: baseField

                anchors.fill: parent
                anchors.margins: 6
                color: GlobalConfig.text
                font.family: GlobalConfig.fontFamily
                font.pixelSize: GlobalConfig.fontPixelSmaller
                selectByMouse: true
                text: ColorSchemeService.customBase

                onEditingFinished: {
                    var c = text.trim();
                    if (!c.startsWith("#"))
                        c = "#" + c;
                    if (Qt.colorValid(c))
                        ColorSchemeService.setCustomColors(ColorSchemeService.customBg, ColorSchemeService.customAccent, ColorSchemeService.customAccentAlt, c, ColorSchemeService.customSurfaceAlt, ColorSchemeService.customAccentContainer, ColorSchemeService.customAccentAltContainer, ColorSchemeService.customLavender, ColorSchemeService.customTextMuted, ColorSchemeService.customText);
                }
            }
        }
        Rectangle {
            border.color: ColorSchemeConfig.border
            border.width: 1
            color: ColorSchemeService.currentColors.base
            height: 24
            radius: 12
            width: 24
        }
    }
    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Text {
            Layout.preferredWidth: 80
            color: GlobalConfig.textDim
            font.family: GlobalConfig.fontFamily
            font.pixelSize: GlobalConfig.fontPixelSmaller
            text: "Surface Alt"
        }
        Rectangle {
            Layout.fillWidth: true
            border.color: surfaceAltField.activeFocus ? GlobalConfig.accent : GlobalConfig.textAlpha15
            border.width: 1
            color: GlobalConfig.textAlpha07
            height: 28
            radius: 4

            Behavior on border.color {
                ColorAnimation {
                    duration: GlobalConfig.animationFast
                }
            }

            TextInput {
                id: surfaceAltField

                anchors.fill: parent
                anchors.margins: 6
                color: GlobalConfig.text
                font.family: GlobalConfig.fontFamily
                font.pixelSize: GlobalConfig.fontPixelSmaller
                selectByMouse: true
                text: ColorSchemeService.customSurfaceAlt

                onEditingFinished: {
                    var c = text.trim();
                    if (!c.startsWith("#"))
                        c = "#" + c;
                    if (Qt.colorValid(c))
                        ColorSchemeService.setCustomColors(ColorSchemeService.customBg, ColorSchemeService.customAccent, ColorSchemeService.customAccentAlt, ColorSchemeService.customBase, c, ColorSchemeService.customAccentContainer, ColorSchemeService.customAccentAltContainer, ColorSchemeService.customLavender, ColorSchemeService.customTextMuted, ColorSchemeService.customText);
                }
            }
        }
        Rectangle {
            border.color: ColorSchemeConfig.border
            border.width: 1
            color: ColorSchemeService.currentColors.surfaceAlt
            height: 24
            radius: 12
            width: 24
        }
    }

    // Primary

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Text {
            Layout.preferredWidth: 80
            color: GlobalConfig.textDim
            font.family: GlobalConfig.fontFamily
            font.pixelSize: GlobalConfig.fontPixelSmaller
            text: "Accent"
        }
        Rectangle {
            Layout.fillWidth: true
            border.color: accentField.activeFocus ? GlobalConfig.accent : GlobalConfig.textAlpha15
            border.width: 1
            color: GlobalConfig.textAlpha07
            height: 28
            radius: 4

            Behavior on border.color {
                ColorAnimation {
                    duration: GlobalConfig.animationFast
                }
            }

            TextInput {
                id: accentField

                anchors.fill: parent
                anchors.margins: 6
                color: GlobalConfig.text
                font.family: GlobalConfig.fontFamily
                font.pixelSize: GlobalConfig.fontPixelSmaller
                selectByMouse: true
                text: ColorSchemeService.customAccent

                onEditingFinished: {
                    var c = text.trim();
                    if (!c.startsWith("#"))
                        c = "#" + c;
                    if (Qt.colorValid(c))
                        ColorSchemeService.setCustomColors(ColorSchemeService.customBg, c, ColorSchemeService.customAccentAlt, ColorSchemeService.customBase, ColorSchemeService.customSurfaceAlt, ColorSchemeService.customAccentContainer, ColorSchemeService.customAccentAltContainer, ColorSchemeService.customLavender, ColorSchemeService.customTextMuted, ColorSchemeService.customText);
                }
            }
        }
        Rectangle {
            border.color: ColorSchemeConfig.border
            border.width: 1
            color: ColorSchemeService.currentColors.accent
            height: 24
            radius: 12
            width: 24
        }
    }
    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Text {
            Layout.preferredWidth: 80
            color: GlobalConfig.textDim
            font.family: GlobalConfig.fontFamily
            font.pixelSize: GlobalConfig.fontPixelSmaller
            text: "Accent Ctr"
        }
        Rectangle {
            Layout.fillWidth: true
            border.color: accentContainerField.activeFocus ? GlobalConfig.accent : GlobalConfig.textAlpha15
            border.width: 1
            color: GlobalConfig.textAlpha07
            height: 28
            radius: 4

            Behavior on border.color {
                ColorAnimation {
                    duration: GlobalConfig.animationFast
                }
            }

            TextInput {
                id: accentContainerField

                anchors.fill: parent
                anchors.margins: 6
                color: GlobalConfig.text
                font.family: GlobalConfig.fontFamily
                font.pixelSize: GlobalConfig.fontPixelSmaller
                selectByMouse: true
                text: ColorSchemeService.customAccentContainer

                onEditingFinished: {
                    var c = text.trim();
                    if (!c.startsWith("#"))
                        c = "#" + c;
                    if (Qt.colorValid(c))
                        ColorSchemeService.setCustomColors(ColorSchemeService.customBg, ColorSchemeService.customAccent, ColorSchemeService.customAccentAlt, ColorSchemeService.customBase, ColorSchemeService.customSurfaceAlt, c, ColorSchemeService.customAccentAltContainer, ColorSchemeService.customLavender, ColorSchemeService.customTextMuted, ColorSchemeService.customText);
                }
            }
        }
        Rectangle {
            border.color: ColorSchemeConfig.border
            border.width: 1
            color: ColorSchemeService.currentColors.accentContainer
            height: 24
            radius: 12
            width: 24
        }
    }

    // Secondary
    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Text {
            Layout.preferredWidth: 80
            color: GlobalConfig.textDim
            font.family: GlobalConfig.fontFamily
            font.pixelSize: GlobalConfig.fontPixelSmaller
            text: "Accent Alt"
        }
        Rectangle {
            Layout.fillWidth: true
            border.color: accentAltField.activeFocus ? GlobalConfig.accent : GlobalConfig.textAlpha15
            border.width: 1
            color: GlobalConfig.textAlpha07
            height: 28
            radius: 4

            Behavior on border.color {
                ColorAnimation {
                    duration: GlobalConfig.animationFast
                }
            }

            TextInput {
                id: accentAltField

                anchors.fill: parent
                anchors.margins: 6
                color: GlobalConfig.text
                font.family: GlobalConfig.fontFamily
                font.pixelSize: GlobalConfig.fontPixelSmaller
                selectByMouse: true
                text: ColorSchemeService.customAccentAlt

                onEditingFinished: {
                    var c = text.trim();
                    if (!c.startsWith("#"))
                        c = "#" + c;
                    if (Qt.colorValid(c))
                        ColorSchemeService.setCustomColors(ColorSchemeService.customBg, ColorSchemeService.customAccent, c, ColorSchemeService.customBase, ColorSchemeService.customSurfaceAlt, ColorSchemeService.customAccentContainer, ColorSchemeService.customAccentAltContainer, ColorSchemeService.customLavender, ColorSchemeService.customTextMuted, ColorSchemeService.customText);
                }
            }
        }
        Rectangle {
            border.color: ColorSchemeConfig.border
            border.width: 1
            color: ColorSchemeService.currentColors.accentAlt
            height: 24
            radius: 12
            width: 24
        }
    }
    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Text {
            Layout.preferredWidth: 80
            color: GlobalConfig.textDim
            font.family: GlobalConfig.fontFamily
            font.pixelSize: GlobalConfig.fontPixelSmaller
            text: "Alt Ctr"
        }
        Rectangle {
            Layout.fillWidth: true
            border.color: accentAltContainerField.activeFocus ? GlobalConfig.accent : GlobalConfig.textAlpha15
            border.width: 1
            color: GlobalConfig.textAlpha07
            height: 28
            radius: 4

            Behavior on border.color {
                ColorAnimation {
                    duration: GlobalConfig.animationFast
                }
            }

            TextInput {
                id: accentAltContainerField

                anchors.fill: parent
                anchors.margins: 6
                color: GlobalConfig.text
                font.family: GlobalConfig.fontFamily
                font.pixelSize: GlobalConfig.fontPixelSmaller
                selectByMouse: true
                text: ColorSchemeService.customAccentAltContainer

                onEditingFinished: {
                    var c = text.trim();
                    if (!c.startsWith("#"))
                        c = "#" + c;
                    if (Qt.colorValid(c))
                        ColorSchemeService.setCustomColors(ColorSchemeService.customBg, ColorSchemeService.customAccent, ColorSchemeService.customAccentAlt, ColorSchemeService.customBase, ColorSchemeService.customSurfaceAlt, ColorSchemeService.customAccentContainer, c, ColorSchemeService.customLavender, ColorSchemeService.customTextMuted, ColorSchemeService.customText);
                }
            }
        }
        Rectangle {
            border.color: ColorSchemeConfig.border
            border.width: 1
            color: ColorSchemeService.currentColors.accentAltContainer
            height: 24
            radius: 12
            width: 24
        }
    }

    // Lavender
    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Text {
            Layout.preferredWidth: 80
            color: GlobalConfig.textDim
            font.family: GlobalConfig.fontFamily
            font.pixelSize: GlobalConfig.fontPixelSmaller
            text: "Lavender"
        }
        Rectangle {
            Layout.fillWidth: true
            border.color: lavenderField.activeFocus ? GlobalConfig.accent : GlobalConfig.textAlpha15
            border.width: 1
            color: GlobalConfig.textAlpha07
            height: 28
            radius: 4

            Behavior on border.color {
                ColorAnimation {
                    duration: GlobalConfig.animationFast
                }
            }

            TextInput {
                id: lavenderField

                anchors.fill: parent
                anchors.margins: 6
                color: GlobalConfig.text
                font.family: GlobalConfig.fontFamily
                font.pixelSize: GlobalConfig.fontPixelSmaller
                selectByMouse: true
                text: ColorSchemeService.customLavender

                onEditingFinished: {
                    var c = text.trim();
                    if (!c.startsWith("#"))
                        c = "#" + c;
                    if (Qt.colorValid(c))
                        ColorSchemeService.setCustomColors(ColorSchemeService.customBg, ColorSchemeService.customAccent, ColorSchemeService.customAccentAlt, ColorSchemeService.customBase, ColorSchemeService.customSurfaceAlt, ColorSchemeService.customAccentContainer, ColorSchemeService.customAccentAltContainer, c, ColorSchemeService.customTextMuted, ColorSchemeService.customText);
                }
            }
        }
        Rectangle {
            border.color: ColorSchemeConfig.border
            border.width: 1
            color: ColorSchemeService.currentColors.lavender
            height: 24
            radius: 12
            width: 24
        }
    }
    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Text {
            Layout.preferredWidth: 80
            color: GlobalConfig.textDim
            font.family: GlobalConfig.fontFamily
            font.pixelSize: GlobalConfig.fontPixelSmaller
            text: "Text Muted"
        }
        Rectangle {
            Layout.fillWidth: true
            border.color: textMutedField.activeFocus ? GlobalConfig.accent : GlobalConfig.textAlpha15
            border.width: 1
            color: GlobalConfig.textAlpha07
            height: 28
            radius: 4

            Behavior on border.color {
                ColorAnimation {
                    duration: GlobalConfig.animationFast
                }
            }

            TextInput {
                id: textMutedField

                anchors.fill: parent
                anchors.margins: 6
                color: GlobalConfig.text
                font.family: GlobalConfig.fontFamily
                font.pixelSize: GlobalConfig.fontPixelSmaller
                selectByMouse: true
                text: ColorSchemeService.customTextMuted

                onEditingFinished: {
                    var c = text.trim();
                    if (!c.startsWith("#"))
                        c = "#" + c;
                    if (Qt.colorValid(c))
                        ColorSchemeService.setCustomColors(ColorSchemeService.customBg, ColorSchemeService.customAccent, ColorSchemeService.customAccentAlt, ColorSchemeService.customBase, ColorSchemeService.customSurfaceAlt, ColorSchemeService.customAccentContainer, ColorSchemeService.customAccentAltContainer, ColorSchemeService.customLavender, c, ColorSchemeService.customText);
                }
            }
        }
        Rectangle {
            border.color: ColorSchemeConfig.border
            border.width: 1
            color: ColorSchemeService.currentColors.textMuted
            height: 24
            radius: 12
            width: 24
        }
    }
    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Text {
            Layout.preferredWidth: 80
            color: GlobalConfig.textDim
            font.family: GlobalConfig.fontFamily
            font.pixelSize: GlobalConfig.fontPixelSmaller
            text: "Text"
        }
        Rectangle {
            Layout.fillWidth: true
            border.color: textField.activeFocus ? GlobalConfig.accent : GlobalConfig.textAlpha15
            border.width: 1
            color: GlobalConfig.textAlpha07
            height: 28
            radius: 4

            Behavior on border.color {
                ColorAnimation {
                    duration: GlobalConfig.animationFast
                }
            }

            TextInput {
                id: textField

                anchors.fill: parent
                anchors.margins: 6
                color: GlobalConfig.text
                font.family: GlobalConfig.fontFamily
                font.pixelSize: GlobalConfig.fontPixelSmaller
                selectByMouse: true
                text: ColorSchemeService.customText

                onEditingFinished: {
                    var c = text.trim();
                    if (!c.startsWith("#"))
                        c = "#" + c;
                    if (Qt.colorValid(c))
                        ColorSchemeService.setCustomColors(ColorSchemeService.customBg, ColorSchemeService.customAccent, ColorSchemeService.customAccentAlt, ColorSchemeService.customBase, ColorSchemeService.customSurfaceAlt, ColorSchemeService.customAccentContainer, ColorSchemeService.customAccentAltContainer, ColorSchemeService.customLavender, ColorSchemeService.customTextMuted, c);
                }
            }
        }
        Rectangle {
            border.color: ColorSchemeConfig.border
            border.width: 1
            color: ColorSchemeService.currentColors.text
            height: 24
            radius: 12
            width: 24
        }
    }
}
