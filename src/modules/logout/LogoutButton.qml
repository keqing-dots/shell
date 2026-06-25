pragma ComponentBehavior: Bound

import QtQuick

import qs.modules.logout
import qs.styles

Rectangle {
    id: root

    required property int index

    property var chars: []
    property bool highlighted: root.highlightEnabled && (root.index == root.currentIndex)
    property bool highlightEnabled: false
    property int currentIndex: 0
    property bool keyInputActive: false

    readonly property bool isMouseHovered: click.containsMouse
    readonly property bool isHighlighted: root.highlightEnabled && (root.highlighted || root.isMouseHovered)
    property real expandRadius: 0

    function setExpanded(show) {
        opacity = show ? 1 : 0;
        expandRadius = show ? LogoutConfig.buttonsExpandedRadius : 0;
    }

    border.color: root.isHighlighted ? GlobalConfig.accentAlt : GlobalConfig.accent
    border.width: LogoutConfig.buttonBorderWidth
    color: GlobalConfig.fieldBg
    height: LogoutConfig.buttonSize
    opacity: 0
    radius: LogoutConfig.buttonSize / LogoutConfig.buttonCornerRadiusDiv
    scale: root.isHighlighted ? LogoutConfig.buttonHighlightScale : 1
    width: LogoutConfig.buttonSize
    x: root.expandRadius * Math.cos(LogoutConfig.buttonsStartAngle + LogoutConfig.buttonsStepAngle * root.index) - LogoutConfig.buttonSize / 2
    y: root.expandRadius * Math.sin(LogoutConfig.buttonsStartAngle + LogoutConfig.buttonsStepAngle * root.index) - LogoutConfig.buttonSize / 2

    signal execRequested(int idx)

    Behavior on border.color {
        ColorAnimation {
            duration: LogoutConfig.buttonBorderAnimMs
            easing.type: Easing.OutCubic
        }
    }
    Behavior on expandRadius {
        NumberAnimation {
            duration: LogoutConfig.buttonRadiusAnimMs
        }
    }
    Behavior on opacity {
        NumberAnimation {
            duration: LogoutConfig.buttonOpacityAnimMs
        }
    }
    Behavior on scale {
        NumberAnimation {
            duration: LogoutConfig.buttonScaleAnimMs
            easing.type: Easing.OutCubic
        }
    }

    MouseArea {
        id: click

        acceptedButtons: Qt.LeftButton | Qt.RightButton
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onClicked: mouse => {
            if (mouse.button == Qt.LeftButton && root.keyInputActive)
                root.execRequested(root.index);
        }
    }
    Text {
        color: GlobalConfig.text
        font.family: GlobalConfig.yujiMaiFamily
        font.pixelSize: LogoutConfig.buttonSize / 2
        text: root.chars[root.index] ?? ""
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
    }
}
