pragma ComponentBehavior: Bound

import Qt5Compat.GraphicalEffects
import QtQuick
import Quickshell.Io

import qs.modules.bar
import qs.styles

Rectangle {
    id: root

    property string _uptime: ""

    border.color: GlobalConfig.accent
    border.width: 1
    color: BarConfig.capsuleBg
    height: mainCol.implicitHeight + 24
    radius: 12
    width: parent.width

    Process {
        command: ["uptime", "-p"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: root._uptime = text.trim().replace(/^up /, "")
        }
    }
    Process {
        id: settingsProc

        command: ["keqing-shell", "settings"]
        running: false
    }
    Column {
        id: mainCol

        spacing: 10
        y: 12

        anchors {
            left: parent.left
            leftMargin: 14
            right: parent.right
            rightMargin: 14
        }
        Item {
            height: avatar.height + 8 + infoCol.implicitHeight
            width: parent.width

            // avatar
            Item {
                id: avatar

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                height: 80
                width: 80

                Item {
                    id: pfpSource

                    anchors.fill: parent
                    visible: false

                    AnimatedImage {
                        anchors.fill: parent
                        cache: false
                        fillMode: Image.PreserveAspectCrop
                        playing: true
                        source: GlobalConfig.userPfp

                        Component.onCompleted: currentFrame = 0
                    }
                }
                Rectangle {
                    id: pfpMask

                    anchors.fill: pfpSource
                    antialiasing: true
                    radius: width / 2
                    visible: false
                }
                OpacityMask {
                    anchors.fill: pfpSource
                    maskSource: pfpMask
                    source: pfpSource
                }
            }

            // info
            Column {
                id: infoCol

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: avatar.bottom
                anchors.topMargin: 8
                spacing: 2

                Text {
                    color: GlobalConfig.text
                    font.bold: true
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: BarConfig.fontSize + 1
                    horizontalAlignment: Text.AlignHCenter
                    text: GlobalConfig.user
                    width: 200
                }
                Text {
                    color: GlobalConfig.textDim
                    elide: Text.ElideRight
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: BarConfig.fontSize - 1
                    horizontalAlignment: Text.AlignHCenter
                    text: root._uptime
                    width: 200
                }
            }

            // settings
            Text {
                anchors.right: parent.right
                anchors.top: parent.top
                color: settingsHover.containsMouse ? GlobalConfig.text : GlobalConfig.textDim
                font.family: Icons.fontFamily
                font.pixelSize: 16
                text: Icons.settings

                Behavior on color {
                    ColorAnimation {
                        duration: GlobalConfig.animationFast
                    }
                }

                MouseArea {
                    id: settingsHover

                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked: settingsProc.running = true
                }
            }
        }
    }
}
