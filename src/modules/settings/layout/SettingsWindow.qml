pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import qs.lib.service
import qs.modules.settings
import qs.modules.settings.layout.tabs
import qs.styles

PanelWindow {
    id: root

    property bool panelOpen: false

    signal panelClosed

    function close() {
        root.panelOpen = false;
        closeTimer.start();
    }
    function open() {
        root.visible = true;
        root.panelOpen = true;
        contentScope.forceActiveFocus();
    }

    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: root.panelOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "keqing-settings"
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    anchors.top: true
    color: "transparent"
    visible: false

    Connections {
        function onScreensChanged() {
            closeTimer.stop();
            root.panelOpen = false;
            root.visible = false;
            root.panelClosed();
        }

        target: Quickshell
    }
    Timer {
        id: closeTimer

        interval: GlobalConfig.animationFast
        repeat: false

        onTriggered: {
            root.visible = false;
            root.panelClosed();
        }
    }
    FocusScope {
        id: contentScope

        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: event => {
            root.close();
            event.accepted = true;
        }

        MouseArea {
            anchors.fill: parent

            onClicked: root.close()
        }
        Rectangle {
            id: card

            anchors.centerIn: parent
            border.color: GlobalConfig.accent
            border.width: GlobalConfig.borderWidthThin
            color: GlobalConfig.overlay
            implicitHeight: 680
            implicitWidth: 920
            opacity: root.panelOpen ? 1.0 : 0.0
            radius: GlobalConfig.radiusMd
            scale: root.panelOpen ? 1.0 : 0.97

            Behavior on opacity {
                NumberAnimation {
                    duration: GlobalConfig.animationFast
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: GlobalConfig.animationFast
                    easing.type: Easing.OutCubic
                }
            }

            MouseArea {
                anchors.fill: parent
            }
            Rectangle {
                anchors.fill: parent
                color: GlobalConfig.baseAlpha45
                opacity: SettingsService.widgetPopupOpen ? 1.0 : 0.0
                radius: GlobalConfig.radiusMd
                z: 1

                Behavior on opacity {
                    NumberAnimation {
                        duration: GlobalConfig.animationFast
                        easing.type: Easing.OutCubic
                    }
                }
            }
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 0

                Item {
                    Layout.fillWidth: true
                    height: 28

                    Text {
                        anchors.centerIn: parent
                        color: GlobalConfig.text
                        font.family: GlobalConfig.fontFamily
                        font.pixelSize: GlobalConfig.fontPixelSmall + 2
                        font.weight: Font.Bold
                        text: " Settings"
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        color: GlobalConfig.text
                        font.family: Icons.fontFamily
                        font.pixelSize: GlobalConfig.fontPixelSmall
                        opacity: closeHover.containsMouse ? 1.0 : 0.45
                        text: Icons.close

                        Behavior on opacity {
                            NumberAnimation {
                                duration: GlobalConfig.animationFast
                            }
                        }

                        MouseArea {
                            id: closeHover

                            anchors.fill: parent
                            anchors.margins: -8
                            hoverEnabled: true

                            onClicked: root.close()
                        }
                    }
                }
                Item {
                    Layout.preferredHeight: 16
                }
                Rectangle {
                    Layout.fillWidth: true
                    color: GlobalConfig.textAlpha08
                    height: 1
                }
                RowLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    spacing: 0

                    Column {
                        id: tabBar

                        property int currentTab: 0

                        Layout.fillHeight: true
                        Layout.preferredWidth: 160
                        spacing: 2
                        topPadding: 12

                        Repeater {
                            model: ["Bar", "Color Scheme", "Control Center", "Displays", "OSD", "Wallpaper"]

                            delegate: Item {
                                id: tabItem

                                required property int index
                                required property string modelData

                                height: 32
                                width: tabBar.width

                                Rectangle {
                                    anchors.fill: parent
                                    anchors.leftMargin: 2
                                    anchors.rightMargin: 2
                                    color: tabBar.currentTab === tabItem.index ? GlobalConfig.accentAlpha18 : tabHover.containsMouse ? GlobalConfig.textAlpha06 : "transparent"
                                    radius: GlobalConfig.radiusSm

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: GlobalConfig.animationFast
                                        }
                                    }
                                }
                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 12
                                    anchors.right: parent.right
                                    anchors.rightMargin: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: tabBar.currentTab === tabItem.index ? GlobalConfig.accent : GlobalConfig.text
                                    elide: Text.ElideRight
                                    font.family: GlobalConfig.fontFamily
                                    font.pixelSize: GlobalConfig.fontPixelSmaller
                                    font.weight: tabBar.currentTab === tabItem.index ? Font.DemiBold : Font.Normal
                                    opacity: tabBar.currentTab === tabItem.index ? 1.0 : 0.6
                                    text: tabItem.modelData

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
                                    id: tabHover

                                    anchors.fill: parent
                                    hoverEnabled: true

                                    onClicked: tabBar.currentTab = tabItem.index
                                }
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.topMargin: 12
                        color: GlobalConfig.textAlpha08
                        width: 1
                    }
                    StackLayout {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.leftMargin: 16
                        Layout.topMargin: 12
                        currentIndex: tabBar.currentTab

                        BarTab {}
                        ColorSchemeTab {}
                        ControlCenterTab {}
                        DisplaysTab {}
                        OSDTab {}
                        WallpaperTab {}
                    }
                }
            }
        }
    }
}
