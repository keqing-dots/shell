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
                        function onSinkMutedChanged() {
                            osdWindow.show();
                        }
                        function onSinkVolumeChanged() {
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
                            border.color: ColorConfig.electro
                            border.width: GlobalConfig.borderWidthThin
                            color: ColorConfig.overlay
                            radius: height / 2

                            // Icon
                            Text {
                                id: volIcon

                                anchors.left: parent.left
                                anchors.leftMargin: 14
                                anchors.verticalCenter: parent.verticalCenter
                                color: VolumeService.sinkMuted ? "#e05555" : ColorConfig.accent
                                font.family: IconConfig.fontFamily
                                font.pixelSize: FontConfig.fontOsdIcon
                                text: {
                                    if (VolumeService.sinkMuted)
                                        return IconConfig.volumeMute;
                                    if (VolumeService.sinkVolume === 0)
                                        return IconConfig.volumeEmpty;
                                    if (VolumeService.sinkVolume < 0.5)
                                        return IconConfig.volumeLow;
                                    return IconConfig.volumeHigh;
                                }

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
                                color: ColorConfig.text
                                font.family: FontConfig.fontFamily
                                font.pixelSize: FontConfig.fontOsdLabel
                                horizontalAlignment: Text.AlignRight
                                text: VolumeService.sinkMuted ? "muted" : Math.round(VolumeService.sinkVolume * 100) + "%"
                                width: 44
                            }

                            // Progress bar
                            Rectangle {
                                anchors.left: volIcon.right
                                anchors.leftMargin: 10
                                anchors.right: pctLabel.left
                                anchors.rightMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                color: ColorConfig.textAlpha12
                                height: 6
                                radius: 3

                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    color: VolumeService.sinkMuted ? "#e05555" : ColorConfig.accent
                                    radius: parent.radius
                                    width: parent.width * Math.min(1.0, VolumeService.sinkMuted ? 0 : VolumeService.sinkVolume)

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
