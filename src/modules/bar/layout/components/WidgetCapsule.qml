pragma ComponentBehavior: Bound

import QtQuick

import qs.modules.bar
import qs.modules.bar.service
import qs.styles

Item {
    id: root

    property bool _panelOpenLinger: false
    readonly property bool baseShowLabel: hovered || isPanelOpen || _panelOpenLinger
    property color borderColor: BarConfig.capsuleBorder
    property alias capsuleVisible: capsule.visible
    property var config: ({})
    readonly property bool hovered: hoverHandler.hovered
    property string iconGlyph: ""
    readonly property bool isPanelOpen: panelName !== "" && PanelService.openedPanel?.objectName === panelName + "-" + (screen?.name ?? "")
    property string labelText: ""
    property real labelW: showLabel ? Math.round(labelItem.implicitWidth) : 0
    property string panelName: ""
    property var screen: null
    property bool showLabel: false

    implicitHeight: BarConfig.capsuleHeight
    implicitWidth: BarConfig.capsuleHeight + (labelW > 0.5 ? labelW + Math.round((BarConfig.capsuleHeight - iconItem.width) / 2) : 0)

    Behavior on labelW {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    onIsPanelOpenChanged: {
        if (!isPanelOpen && panelName !== "") {
            _panelOpenLinger = true;
            panelLingerTimer.restart();
        } else {
            panelLingerTimer.stop();
            _panelOpenLinger = false;
        }
    }

    Timer {
        id: panelLingerTimer

        interval: 80

        onTriggered: root._panelOpenLinger = false
    }
    HoverHandler {
        id: hoverHandler
    }
    Rectangle {
        id: capsule

        anchors.fill: parent
        border.color: root.borderColor
        border.width: BarConfig.capsuleBorderWidth
        clip: true
        color: root.hovered ? BarConfig.capsuleBgHover : BarConfig.capsuleBg
        radius: BarConfig.capsuleRadius
    }
    Item {
        id: iconSection

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.top: parent.top
        width: BarConfig.capsuleHeight

        Text {
            id: iconItem

            color: GlobalConfig.text
            font.family: Icons.fontFamily
            font.pixelSize: BarConfig.iconSize
            text: root.iconGlyph
            x: Math.round((parent.width - width) / 2)
            y: Math.round((parent.height - height) / 2 + (height - contentHeight) / 2)
        }
    }
    Text {
        id: labelItem

        anchors.left: iconSection.right
        anchors.verticalCenter: parent.verticalCenter
        clip: true
        color: GlobalConfig.text
        font.family: GlobalConfig.fontFamily
        font.pixelSize: BarConfig.fontSize
        opacity: root.showLabel ? 1.0 : 0.0
        text: root.labelText
        width: root.labelW

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }
}
