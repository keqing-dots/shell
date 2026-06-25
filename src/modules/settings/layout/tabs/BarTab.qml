pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.lib.layout
import qs.lib.service
import qs.modules.settings
import qs.modules.settings.layout.components
import qs.styles

Flickable {
    id: root

    readonly property bool overrideEnabled: {
        if (selectedWidgetScreen === "default")
            return true;
        var entry = SettingsService.allWidgets[selectedWidgetScreen];
        return entry !== undefined && entry._enabled !== false;
    }
    property string selectedWidgetScreen: "default"
    readonly property var sortedScreens: {
        var screens = [];
        for (var i = 0; i < Quickshell.screens.length; i++)
            screens.push(Quickshell.screens[i]);
        screens.sort((a, b) => a.name < b.name ? -1 : a.name > b.name ? 1 : 0);
        return screens;
    }

    clip: true
    contentHeight: col.implicitHeight

    Column {
        id: col

        spacing: 12
        width: root.width

        SettingsGroup {
            title: "Geometry"
            width: col.width

            Repeater {
                model: [
                    {
                        label: "Bar Height",
                        min: 25,
                        max: 60,
                        step: 1,
                        defaultVal: 35,
                        getter: function () {
                            return SettingsService.adapter.bar.height;
                        },
                        setter: function (v) {
                            SettingsService.adapter.bar.height = v;
                        }
                    },
                    {
                        label: "Top Margin",
                        min: 0,
                        max: 60,
                        step: 1,
                        defaultVal: 10,
                        getter: function () {
                            return SettingsService.adapter.bar.marginTop;
                        },
                        setter: function (v) {
                            SettingsService.adapter.bar.marginTop = v;
                        }
                    },
                    {
                        label: "Horizontal Margin",
                        min: 0,
                        max: 80,
                        step: 1,
                        defaultVal: 20,
                        getter: function () {
                            return SettingsService.adapter.bar.marginH;
                        },
                        setter: function (v) {
                            SettingsService.adapter.bar.marginH = v;
                        }
                    },
                    {
                        label: "Screen Margin",
                        min: 0,
                        max: 80,
                        step: 1,
                        defaultVal: 20,
                        getter: function () {
                            return SettingsService.adapter.bar.screenMargin;
                        },
                        setter: function (v) {
                            SettingsService.adapter.bar.screenMargin = v;
                        }
                    },
                    {
                        label: "Background Opacity",
                        min: 0.0,
                        max: 1.0,
                        step: 0.05,
                        defaultVal: 0.0,
                        getter: function () {
                            return SettingsService.adapter.bar.backgroundOpacity;
                        },
                        setter: function (v) {
                            SettingsService.adapter.bar.backgroundOpacity = v;
                        }
                    }
                ]

                delegate: RowLayout {
                    id: numRow

                    required property int index
                    required property var modelData

                    height: 40
                    width: parent.width

                    Text {
                        Layout.fillWidth: true
                        color: ColorConfig.text
                        font.family: FontConfig.fontFamily
                        font.pixelSize: FontConfig.fontSettingsBody
                        font.weight: Font.DemiBold
                        opacity: 0.85
                        text: numRow.modelData.label
                    }
                    Rectangle {
                        border.color: numInput.activeFocus ? ColorConfig.accent : ColorConfig.textAlpha15
                        border.width: 1
                        color: ColorConfig.textAlpha07
                        implicitHeight: 28
                        implicitWidth: 72
                        radius: 4

                        Behavior on border.color {
                            ColorAnimation {
                                duration: GlobalConfig.animationFast
                            }
                        }

                        TextInput {
                            id: numInput

                            anchors.fill: parent
                            anchors.margins: 6
                            color: ColorConfig.text
                            font.family: FontConfig.fontFamily
                            font.pixelSize: FontConfig.fontSettingsBody
                            horizontalAlignment: TextInput.AlignHCenter
                            selectByMouse: true
                            text: {
                                var v = numRow.modelData.getter();
                                return numRow.modelData.step < 1 ? v.toFixed(2) : Math.round(v).toString();
                            }

                            onEditingFinished: {
                                var v = parseFloat(text);
                                if (isNaN(v)) {
                                    var cur = numRow.modelData.getter();
                                    numInput.text = numRow.modelData.step < 1 ? cur.toFixed(2) : Math.round(cur).toString();
                                    return;
                                }
                                v = Math.max(numRow.modelData.min, Math.min(numRow.modelData.max, v));
                                if (numRow.modelData.step >= 1)
                                    v = Math.round(v);
                                numRow.modelData.setter(v);
                                numInput.text = numRow.modelData.step < 1 ? v.toFixed(2) : v.toString();
                                SettingsService.save();
                            }
                        }
                    }
                    Text {
                        Layout.leftMargin: 4
                        color: ColorConfig.text
                        font.family: Icons.fontFamily
                        font.pixelSize: FontConfig.fontSettingsWindowIcon
                        opacity: resetMa.containsMouse ? 0.9 : 0.3
                        text: Icons.refresh

                        Behavior on opacity {
                            NumberAnimation {
                                duration: GlobalConfig.animationFast
                            }
                        }

                        MouseArea {
                            id: resetMa

                            anchors.fill: parent
                            anchors.margins: -6
                            hoverEnabled: true

                            onClicked: {
                                var dv = numRow.modelData.defaultVal;
                                numRow.modelData.setter(dv);
                                numInput.text = numRow.modelData.step < 1 ? dv.toFixed(2) : dv.toString();
                                SettingsService.save();
                            }
                        }
                    }
                }
            }
        }
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            border.color: ColorConfig.textAlpha12
            border.width: 1
            color: resetAllMa.containsMouse ? ColorConfig.accentAlpha15 : ColorConfig.textAlpha05
            height: 30
            radius: GlobalConfig.radiusSm
            width: resetAllText.implicitWidth + 24

            Behavior on color {
                ColorAnimation {
                    duration: GlobalConfig.animationFast
                }
            }

            Text {
                id: resetAllText

                anchors.centerIn: parent
                color: resetAllMa.containsMouse ? ColorConfig.accent : ColorConfig.text
                font.family: FontConfig.fontFamily
                font.pixelSize: FontConfig.fontSettingsBody
                opacity: resetAllMa.containsMouse ? 1.0 : 0.55
                text: "↺  Reset all to defaults"

                Behavior on color {
                    ColorAnimation {
                        duration: GlobalConfig.animationFast
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: GlobalConfig.animationFast
                    }
                }
            }
            MouseArea {
                id: resetAllMa

                anchors.fill: parent
                hoverEnabled: true

                onClicked: {
                    SettingsService.adapter.bar.height = 35;
                    SettingsService.adapter.bar.marginTop = 10;
                    SettingsService.adapter.bar.marginH = 20;
                    SettingsService.adapter.bar.screenMargin = 20;
                    SettingsService.adapter.bar.backgroundOpacity = 0;
                    SettingsService.save();
                }
            }
        }
        SettingsGroup {
            contentSpacing: 20
            title: "Widgets"
            width: col.width

            Row {
                id: widgetScreenRow

                spacing: 6
                width: parent.width

                Rectangle {
                    border.color: root.selectedWidgetScreen === "default" ? ColorConfig.accentAlt : "transparent"
                    border.width: 2
                    color: ColorConfig.lavenderAlpha20
                    height: 35
                    radius: 6
                    width: (widgetScreenRow.width - root.sortedScreens.length * widgetScreenRow.spacing) / Math.max(1, root.sortedScreens.length + 1)

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
                        text: "Default"
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: root.selectedWidgetScreen = "default"
                    }
                }
                Repeater {
                    model: root.sortedScreens

                    delegate: Rectangle {
                        required property var modelData

                        border.color: root.selectedWidgetScreen === modelData.name ? ColorConfig.accentAlt : "transparent"
                        border.width: 2
                        color: ColorConfig.lavenderAlpha20
                        height: 35
                        radius: 6
                        width: (widgetScreenRow.width - root.sortedScreens.length * widgetScreenRow.spacing) / Math.max(1, root.sortedScreens.length + 1)

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

                            onClicked: root.selectedWidgetScreen = parent.modelData.name
                        }
                    }
                }
            }
            RowLayout {
                visible: root.selectedWidgetScreen !== "default"
                width: parent.width

                Text {
                    Layout.fillWidth: true
                    color: ColorConfig.text
                    font.family: FontConfig.fontFamily
                    font.pixelSize: FontConfig.fontSettingsBody
                    opacity: 0.85
                    text: "Override default layout"
                }
                Toggle {
                    active: root.overrideEnabled

                    onToggled: SettingsService.setWidgetOverrideEnabled(root.selectedWidgetScreen, !root.overrideEnabled)
                }
            }
            WidgetRow {
                screenName: root.selectedWidgetScreen
                section: "left"
                visible: root.overrideEnabled
                width: parent.width
            }
            WidgetRow {
                screenName: root.selectedWidgetScreen
                section: "center"
                visible: root.overrideEnabled
                width: parent.width
            }
            WidgetRow {
                screenName: root.selectedWidgetScreen
                section: "right"
                visible: root.overrideEnabled
                width: parent.width
            }
        }
        Item {
            height: 8
        }
    }
}
