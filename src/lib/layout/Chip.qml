pragma ComponentBehavior: Bound

import QtQuick

import qs.styles

Rectangle {
    property color baseColor: GlobalConfig.textAlpha07
    property bool hovered: false

    color: hovered ? GlobalConfig.textAlpha12 : baseColor
    radius: 8

    Behavior on color {
        ColorAnimation {
            duration: 100
        }
    }
}
