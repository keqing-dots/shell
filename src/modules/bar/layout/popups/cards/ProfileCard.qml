pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io

import qs.components
import qs.modules.bar
import qs.config

Rectangle {
    id: root

    property string _uptime: ""

    border.color: ColorConfig.accent
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
            RoundImage {
                id: avatar

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                borderWidth: BarConfig.logoBorderWidth
                height: 100
                source: GlobalConfig.userPfp
                width: 100
            }

            // info
            Column {
                id: infoCol

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: avatar.bottom
                anchors.topMargin: 8
                spacing: 2

                Text {
                    color: ColorConfig.text
                    font.bold: true
                    font.family: FontConfig.fontFamily
                    font.pixelSize: BarConfig.fontSize + 1
                    horizontalAlignment: Text.AlignHCenter
                    text: GlobalConfig.user
                    width: 200
                }
                Text {
                    color: ColorConfig.textDim
                    elide: Text.ElideRight
                    font.family: FontConfig.fontFamily
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
                color: settingsHover.containsMouse ? ColorConfig.text : ColorConfig.textDim
                font.family: IconConfig.fontFamily
                font.pixelSize: FontConfig.fontProfileSettings
                text: IconConfig.settings

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
