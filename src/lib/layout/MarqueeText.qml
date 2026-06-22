pragma ComponentBehavior: Bound

import QtQuick

import qs.styles

Item {
    id: root

    readonly property real _overflow: Math.max(0, label.implicitWidth - root.width)
    property color color: GlobalConfig.text
    property bool fontBold: false
    property string fontFamily: GlobalConfig.fontFamily
    property int fontSize: 12
    property int pauseDuration: 1200
    property int speed: 35
    property string text: ""

    function _restart() {
        label.x = 0;
        anim.stop();
        if (root._overflow > 0)
            anim.start();
    }

    clip: true
    height: label.implicitHeight

    onWidthChanged: root._restart()

    Text {
        id: label

        color: root.color
        font.bold: root.fontBold
        font.family: root.fontFamily
        font.pixelSize: root.fontSize
        text: root.text

        onImplicitWidthChanged: root._restart()
    }
    SequentialAnimation {
        id: anim

        loops: Animation.Infinite

        PauseAnimation {
            duration: root.pauseDuration
        }
        NumberAnimation {
            duration: root._overflow > 0 ? root._overflow / root.speed * 1000 : 0
            easing.type: Easing.Linear
            property: "x"
            target: label
            to: -root._overflow
        }
        PauseAnimation {
            duration: root.pauseDuration
        }
        NumberAnimation {
            duration: 0
            property: "x"
            target: label
            to: 0
        }
    }
}
