pragma ComponentBehavior: Bound

import Qt5Compat.GraphicalEffects
import QtQuick

import qs.styles

Item {
    id: root

    property color bgColor: "transparent"
    property color borderColor: GlobalConfig.accent
    property real borderWidth: 0
    property real imageMargin: 0
    property bool playing: true
    property url source: ""

    function reset() {
        animImage.currentFrame = 0;
        playing = true;
    }
    function stop() {
        playing = false;
    }

    Rectangle {
        anchors.fill: parent
        border.color: root.borderColor
        border.width: root.borderWidth
        color: root.bgColor
        radius: width / 2
    }
    Item {
        id: imgContent

        anchors.fill: parent
        anchors.margins: root.imageMargin
        visible: false

        AnimatedImage {
            id: animImage

            anchors.fill: parent
            cache: false
            fillMode: Image.PreserveAspectCrop
            playing: root.playing
            source: root.source

            Component.onCompleted: currentFrame = 0
        }
    }
    Rectangle {
        id: imgMask

        anchors.fill: imgContent
        antialiasing: true
        radius: width / 2
        visible: false
    }
    OpacityMask {
        anchors.fill: imgContent
        maskSource: imgMask
        source: imgContent
    }
}
