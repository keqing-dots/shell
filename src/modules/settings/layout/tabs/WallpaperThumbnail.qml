pragma ComponentBehavior: Bound

import QtQuick

import qs.modules.wallpaper
import qs.styles

Rectangle {
    id: thumb

    required property string path
    required property bool selected

    signal clicked(string path)

    border.color: selected ? ColorConfig.accentAlt : "transparent"
    border.width: 3
    clip: true
    color: WallpaperConfig.thumbnailBg
    radius: GlobalConfig.radiusSm + 3

    Behavior on border.color {
        ColorAnimation {
            duration: 100
        }
    }

    Image {
        anchors.fill: parent
        anchors.margins: 3
        asynchronous: true
        cache: false
        clip: true
        fillMode: Image.PreserveAspectCrop
        opacity: status === Image.Ready ? 1.0 : 0.0
        smooth: true
        source: "file://" + thumb.path
        sourceSize: Qt.size(width, height)

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }
    }
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        color: ColorConfig.overlay
        height: fileLabel.implicitHeight + 6

        Text {
            id: fileLabel

            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            color: "white"
            elide: Text.ElideRight
            font.family: FontConfig.fontFamily
            font.pixelSize: FontConfig.fontSettingsBody
            text: thumb.path.split('/').pop()
        }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: thumb.clicked(thumb.path)
    }
}
