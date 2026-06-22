pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.lib.service
import qs.modules.osd
import qs.styles

Scope {
    Variants {
        model: Quickshell.screens

        delegate: Component {
            Scope {
                id: screenScope

                required property var modelData

                PanelWindow {
                    id: osdWindow

                    property bool ready: false

                    function show() {
                        if (!ready)
                            return;
                        osdContent.show();
                    }

                    WlrLayershell.exclusionMode: ExclusionMode.Ignore
                    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                    WlrLayershell.layer: WlrLayer.Overlay
                    WlrLayershell.namespace: "keqing-osd"
                    anchors.bottom: true
                    color: "transparent"
                    implicitHeight: 50
                    implicitWidth: 280
                    margins.bottom: 30
                    screen: screenScope.modelData
                    visible: DisplayService.showOsd(screenScope.modelData)

                    mask: Region {}

                    Connections {
                        function onSourceMutedChanged() {
                            osdWindow.show();
                        }
                        function onSourceVolumeChanged() {
                            osdWindow.show();
                        }

                        target: VolumeService
                    }
                    Timer {
                        interval: 1000
                        running: true

                        onTriggered: osdWindow.ready = true
                    }

                    // Content
                    Item {
                        id: osdContent

                        function hide() {
                            opacity = 0;
                            scale = 0.92;
                        }
                        function show() {
                            hideTimer.restart();
                            opacity = 1;
                            scale = 1.0;
                        }

                        anchors.fill: parent
                        opacity: 0
                        scale: 0.92
                        visible: opacity > 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: GlobalConfig.animationNormal
                                easing.type: Easing.OutCubic
                            }
                        }
                        Behavior on scale {
                            NumberAnimation {
                                duration: GlobalConfig.animationNormal
                                easing.type: Easing.OutCubic
                            }
                        }

                        Timer {
                            id: hideTimer

                            interval: 2000

                            onTriggered: osdContent.hide()
                        }
                        Rectangle {
                            anchors.fill: parent
                            border.color: GlobalConfig.electro
                            border.width: GlobalConfig.borderWidthThin
                            color: GlobalConfig.overlay
                            radius: height / 2

                            // Icon
                            Text {
                                id: micIcon

                                anchors.left: parent.left
                                anchors.leftMargin: 14
                                anchors.verticalCenter: parent.verticalCenter
                                color: VolumeService.sourceMuted ? "#e05555" : GlobalConfig.accent
                                font.family: Icons.fontFamily
                                font.pixelSize: 18
                                text: VolumeService.sourceMuted ? Icons.micOff : Icons.micOn

                                Behavior on color {
                                    ColorAnimation {
                                        duration: GlobalConfig.animationFast
                                    }
                                }
                            }

                            // Percentage label
                            Text {
                                id: pctLabel

                                anchors.right: parent.right
                                anchors.rightMargin: 14
                                anchors.verticalCenter: parent.verticalCenter
                                color: GlobalConfig.text
                                font.family: GlobalConfig.fontFamily
                                font.pixelSize: GlobalConfig.fontPixelSmaller
                                horizontalAlignment: Text.AlignRight
                                text: VolumeService.sourceMuted ? "muted" : Math.round(VolumeService.sourceVolume * 100) + "%"
                                width: 44
                            }

                            // Progress bar
                            Rectangle {
                                anchors.left: micIcon.right
                                anchors.leftMargin: 10
                                anchors.right: pctLabel.left
                                anchors.rightMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                color: GlobalConfig.textAlpha12
                                height: 6
                                radius: 3

                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    color: VolumeService.sourceMuted ? "#e05555" : GlobalConfig.accent
                                    radius: parent.radius
                                    width: parent.width * Math.min(1.0, VolumeService.sourceMuted ? 0 : VolumeService.sourceVolume)

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: GlobalConfig.animationFast
                                        }
                                    }
                                    Behavior on width {
                                        NumberAnimation {
                                            duration: GlobalConfig.animationFast
                                            easing.type: Easing.OutCubic
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
