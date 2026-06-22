pragma ComponentBehavior: Bound

import QtQuick

import qs.modules.bar
import qs.styles

Item {
    id: root

    property string cardKey: ""
    default property alias content: contentArea.data
    property real contentHeight: 0
    property bool gated: false
    property Component headerSuffix: null
    readonly property bool shown: !gated
    property string title: ""

    clip: true
    height: shown ? cardRect.height : 0
    visible: height > 0 || shown
    width: parent.width

    Behavior on height {
        NumberAnimation {
            duration: GlobalConfig.animationNormal
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        id: cardRect

        border.color: GlobalConfig.accent
        border.width: 1
        color: BarConfig.capsuleBg
        height: 10 + hdr.height + 8 + root.contentHeight + 12
        radius: 12
        width: parent.width

        Item {
            id: hdr

            height: 32
            y: 10

            anchors {
                left: parent.left
                leftMargin: 12
                right: parent.right
                rightMargin: 12
            }
            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                color: GlobalConfig.text
                font.bold: true
                font.family: GlobalConfig.fontFamily
                font.pixelSize: BarConfig.fontSize
                text: root.title
            }
            Loader {
                anchors.fill: parent
                sourceComponent: root.headerSuffix
            }
        }
        Item {
            id: contentArea

            height: root.contentHeight

            anchors {
                left: parent.left
                leftMargin: 12
                right: parent.right
                rightMargin: 12
                top: hdr.bottom
                topMargin: 8
            }
        }
    }
}
