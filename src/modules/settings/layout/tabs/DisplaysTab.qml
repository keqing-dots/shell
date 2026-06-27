pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.components
import qs.service
import qs.modules.settings
import qs.config

Item {
    id: root

    property string selectedScreen: {
        var focusedName = HyprlandService.focusedMonitor?.name ?? "";
        if (focusedName && sortedScreens.some(s => s.name === focusedName))
            return focusedName;
        return sortedScreens.length > 0 ? sortedScreens[0].name : "";
    }
    readonly property var selectedScreenObj: {
        for (var i = 0; i < sortedScreens.length; i++) {
            if (sortedScreens[i].name === selectedScreen)
                return sortedScreens[i];
        }
        return null;
    }
    readonly property var sortedScreens: {
        var screens = [];
        for (var i = 0; i < Quickshell.screens.length; i++)
            screens.push(Quickshell.screens[i]);
        screens.sort((a, b) => a.name < b.name ? -1 : a.name > b.name ? 1 : 0);
        return screens;
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        Row {
            id: screenRow

            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: root.sortedScreens

                delegate: Rectangle {
                    required property var modelData

                    border.color: root.selectedScreen === modelData.name ? ColorConfig.accentAlt : "transparent"
                    border.width: 2
                    color: ColorConfig.lavenderAlpha20
                    height: 35
                    radius: 6
                    width: (screenRow.width - (root.sortedScreens.length - 1) * screenRow.spacing) / Math.max(1, root.sortedScreens.length)

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
        Column {
            Layout.fillWidth: true
            spacing: 0

            Repeater {
                model: [
                    {
                        label: "Bar",
                        key: "bar"
                    },
                    {
                        label: "OSD",
                        key: "osd"
                    },
                    {
                        label: "Notifications",
                        key: "notifications"
                    },
                    {
                        label: "Visualizer",
                        key: "visualizer"
                    },
                    {
                        label: "Lock",
                        key: "lock"
                    }
                ]

                delegate: RowLayout {
                    id: toggleRow

                    required property int index
                    required property var modelData

                    height: 36
                    width: parent.width

                    Text {
                        color: ColorConfig.text
                        font.family: FontConfig.fontFamily
                        font.pixelSize: FontConfig.fontSettingsBody
                        opacity: 0.75
                        text: toggleRow.modelData.label
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    Toggle {
                        active: {
                            var d = SettingsService.displays;
                            var sn = root.selectedScreen;
                            var sm = root.selectedScreenObj?.model ?? "";
                            var entry = d[sn] !== undefined ? d[sn] : d[sm] !== undefined ? d[sm] : {};
                            return entry[toggleRow.modelData.key] !== false;
                        }

                        onToggled: {
                            var d = SettingsService.displays;
                            var sn = root.selectedScreen;
                            if (!d[sn])
                                d[sn] = {};
                            d[sn][toggleRow.modelData.key] = !active;
                            SettingsService.setDisplays(d);
                        }
                    }
                }
            }
        }
        Item {
            Layout.fillHeight: true
        }
    }
}
