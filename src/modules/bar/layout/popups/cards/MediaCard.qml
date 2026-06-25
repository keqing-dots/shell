pragma ComponentBehavior: Bound

import QtQuick

import qs.components
import qs.service
import qs.modules.bar
import qs.modules.bar.layout.components
import qs.config

ControlCenterCard {
    id: root

    readonly property int _thumbSize: 72

    cardKey: "media"
    contentHeight: ctrlRow.y + ctrlRow.height
    title: "Media"

    Item {
        id: topRow

        height: root._thumbSize

        anchors {
            left: parent.left
            right: parent.right
        }
        Rectangle {
            id: thumb

            clip: true
            color: BarConfig.capsuleBg
            height: root._thumbSize
            radius: 8
            width: root._thumbSize

            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            Image {
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                source: MediaService.trackArtUrl
                visible: MediaService.trackArtUrl !== ""
            }
            Text {
                anchors.centerIn: parent
                color: ColorConfig.textDim
                font.family: IconConfig.fontFamily
                font.pixelSize: FontConfig.fontCardIcon
                text: IconConfig.musicNote
                visible: MediaService.trackArtUrl === ""
            }
        }
        Column {
            id: titleCol

            spacing: 3

            anchors {
                left: thumb.right
                leftMargin: 12
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            MarqueeText {
                color: ColorConfig.text
                fontFamily: FontConfig.fontFamily
                fontSize: BarConfig.fontSize
                text: MediaService.currentPlayer ? (MediaService.trackTitle !== "" ? MediaService.trackTitle : "Unknown") : "Nothing playing"
                width: parent.width
            }
            MarqueeText {
                color: ColorConfig.textDim
                fontFamily: FontConfig.fontFamily
                fontSize: BarConfig.fontSize - 1
                text: MediaService.currentPlayer ? (MediaService.trackArtist !== "" ? MediaService.trackArtist : "Unknown Artist") : ""
                width: parent.width
            }
        }
    }
    Item {
        id: progressRow

        height: 20

        anchors {
            left: parent.left
            right: parent.right
            top: topRow.bottom
            topMargin: 10
        }
        Text {
            color: ColorConfig.textDim
            font.family: FontConfig.fontFamily
            font.pixelSize: BarConfig.fontSize - 1
            text: MediaService.positionString + " / " + MediaService.lengthString

            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }
        }
    }
    Item {
        id: ctrlRow

        height: 32

        anchors {
            left: parent.left
            right: parent.right
            top: progressRow.bottom
            topMargin: 8
        }
        Row {
            anchors.centerIn: parent
            spacing: 8

            Rectangle {
                color: prevMa.containsMouse ? BarConfig.capsuleBgHover : "transparent"
                height: 28
                radius: 14
                width: 28

                Text {
                    anchors.centerIn: parent
                    color: MediaService.canGoPrevious ? ColorConfig.text : ColorConfig.textDim
                    font.family: IconConfig.fontFamily
                    font.pixelSize: FontConfig.fontMediaControl
                    text: IconConfig.playerPrev
                }
                MouseArea {
                    id: prevMa

                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: MediaService.canGoPrevious
                    hoverEnabled: true

                    onClicked: MediaService.previous()
                }
            }
            Rectangle {
                color: playMa.containsMouse ? BarConfig.capsuleBgHover : BarConfig.capsuleBg
                height: 32
                radius: 16
                width: 32

                Text {
                    anchors.centerIn: parent
                    color: ColorConfig.text
                    font.family: IconConfig.fontFamily
                    font.pixelSize: FontConfig.fontMediaControl
                    text: MediaService.isPlaying ? IconConfig.playerPause : IconConfig.playerPlay
                }
                MouseArea {
                    id: playMa

                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked: MediaService.playPause()
                }
            }
            Rectangle {
                color: nextMa.containsMouse ? BarConfig.capsuleBgHover : "transparent"
                height: 28
                radius: 14
                width: 28

                Text {
                    anchors.centerIn: parent
                    color: MediaService.canGoNext ? ColorConfig.text : ColorConfig.textDim
                    font.family: IconConfig.fontFamily
                    font.pixelSize: FontConfig.fontMediaControl
                    text: IconConfig.playerNext
                }
                MouseArea {
                    id: nextMa

                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: MediaService.canGoNext
                    hoverEnabled: true

                    onClicked: MediaService.next()
                }
            }
        }
    }
}
