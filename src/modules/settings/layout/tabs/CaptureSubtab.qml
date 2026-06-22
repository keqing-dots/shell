pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

import qs.lib.service
import qs.modules.settings
import qs.modules.settings
import qs.modules.settings.layout.components
import qs.styles

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

    spacing: 10

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Text {
            Layout.preferredWidth: 100
            color: GlobalConfig.textDim
            font.family: GlobalConfig.fontFamily
            font.pixelSize: GlobalConfig.fontPixelSmaller
            text: "Source Display"
        }
        DropdownMenu {
            Layout.fillWidth: true
            activeValue: ColorSchemeService.selectedScreen
            disabled: ColorSchemeService.screens.length === 0
            model: ColorSchemeService.screens

            onItemSelected: value => ColorSchemeService.selectedScreen = value
        }
    }
    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Text {
            Layout.preferredWidth: 100
            color: GlobalConfig.textDim
            font.family: GlobalConfig.fontFamily
            font.pixelSize: GlobalConfig.fontPixelSmaller
            text: "Scheme Type"
        }
        DropdownMenu {
            Layout.fillWidth: true
            activeValue: ColorSchemeService.schemeType
            labelRole: "label"
            model: ColorSchemeConfig.schemeTypes
            valueRole: "type"

            onItemSelected: value => ColorSchemeService.schemeType = value
        }
    }
    Rectangle {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredHeight: root.previewH
        Layout.preferredWidth: root.previewW
        clip: true
        color: GlobalConfig.fieldBg
        radius: ColorSchemeConfig.inputRadius
        visible: ColorSchemeService.selectedScreen !== ""

        Image {
            id: wpThumb

            anchors.fill: parent
            asynchronous: true
            clip: true
            fillMode: Image.PreserveAspectCrop
            opacity: status === Image.Ready ? 1.0 : 0.0
            smooth: true
            source: ColorSchemeService.selectedScreen ? "file://" + (ColorSchemeService.wallpapers[ColorSchemeService.selectedScreen] ?? "") : ""
            sourceSize: Qt.size(parent.width, parent.height)

            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                }
            }
        }
        Text {
            anchors.centerIn: parent
            color: GlobalConfig.textDim
            font.family: GlobalConfig.fontFamily
            font.pixelSize: 28
            text: ""
            visible: wpThumb.status !== Image.Ready
        }
    }
    RowLayout {
        Layout.fillWidth: true
        spacing: 10
        visible: ColorSchemeService.selectedScreen !== ""

        Text {
            Layout.fillWidth: true
            color: ColorSchemeService.selectedStatus === "error" ? "#cf6679" : GlobalConfig.textDim
            font.family: GlobalConfig.fontFamily
            font.pixelSize: GlobalConfig.fontPixelSmaller
            text: {
                switch (ColorSchemeService.selectedStatus) {
                case "loading":
                    return "Extracting colors…";
                case "error":
                    return "Extraction failed";
                case "ready":
                    return "Extracted colors";
                default:
                    return "";
                }
            }
        }
        Row {
            spacing: 8
            visible: ColorSchemeService.selectedStatus === "ready"

            Repeater {
                model: ColorSchemeService.selectedColors ? [
                    {
                        "color": ColorSchemeService.selectedColors.accent,
                        "name": "accent"
                    },
                    {
                        "color": ColorSchemeService.selectedColors.accentContainer,
                        "name": "accentContainer"
                    },
                    {
                        "color": ColorSchemeService.selectedColors.accentAlt,
                        "name": "accentAlt"
                    },
                    {
                        "color": ColorSchemeService.selectedColors.accentAltContainer,
                        "name": "accentAltContainer"
                    },
                    {
                        "color": ColorSchemeService.selectedColors.lavender,
                        "name": "lavender"
                    },
                    {
                        "color": ColorSchemeService.selectedColors.textMuted,
                        "name": "textMuted"
                    },
                    {
                        "color": ColorSchemeService.selectedColors.surfaceAlt,
                        "name": "surfaceAlt"
                    },
                    {
                        "color": ColorSchemeService.selectedColors.fieldBg,
                        "name": "fieldBg"
                    },
                    {
                        "color": ColorSchemeService.selectedColors.base,
                        "name": "base"
                    }
                ] : []

                delegate: Rectangle {
                    required property var modelData

                    border.color: ColorSchemeConfig.border
                    border.width: 1
                    color: modelData.color
                    height: 32
                    radius: 16
                    width: 32

                    MouseArea {
                        ToolTip.delay: 300
                        ToolTip.text: parent.modelData.name + "\n" + parent.modelData.color.toString().toUpperCase()
                        ToolTip.visible: containsMouse
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }
            }
        }
        Rectangle {
            border.color: ColorSchemeConfig.border
            border.width: 2
            color: "transparent"
            height: 28
            radius: 14
            visible: ColorSchemeService.selectedStatus === "loading"
            width: 28

            RotationAnimation on rotation {
                duration: 900
                from: 0
                loops: Animation.Infinite
                running: ColorSchemeService.selectedStatus === "loading"
                to: 360
            }

            Rectangle {
                color: GlobalConfig.accent
                height: 10
                radius: 5
                width: 10

                anchors {
                    margins: -1
                    right: parent.right
                    top: parent.top
                }
            }
        }
    }
    Text {
        Layout.alignment: Qt.AlignHCenter
        color: GlobalConfig.textDim
        font.family: GlobalConfig.fontFamily
        font.pixelSize: GlobalConfig.fontPixelSmaller
        text: "No active wallpapers configured"
        visible: ColorSchemeService.wallpapersLoaded && ColorSchemeService.screens.length === 0
    }
}
