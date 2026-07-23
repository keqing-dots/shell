pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland

import qs.modules.bar
import qs.modules.bar.layout.components
import qs.modules.bar.service
import qs.config

WidgetCapsule {
    id: root

    readonly property int displayActiveId: {
        var m = Hyprland.monitorFor(screen);
        return m && m.activeWorkspace ? m.activeWorkspace.id : -1;
    }
    readonly property var workspaces: {
        var m = Hyprland.monitorFor(screen);
        if (!m)
            return [];
        var mName = m.name;
        return WorkspaceService.allWorkspaces.filter(w => {
            var rule = WorkspaceService.wsRuleMonitor[w.id];
            return rule ? rule === mName : w.monitor === m;
        });
    }

    implicitWidth: layout.implicitWidth + BarConfig.widgetContentPaddingH
    panelName: "overview"

    Row {
        id: layout

        anchors.centerIn: parent
        spacing: BarConfig.workspaceLayoutSpacing

        Row {
            id: pills

            anchors.verticalCenter: parent.verticalCenter
            spacing: BarConfig.workspacePillSpacing

            Repeater {
                model: root.workspaces

                delegate: Rectangle {
                    id: pill

                    property bool flashOn: false
                    readonly property bool isActive: modelData.id === root.displayActiveId
                    readonly property bool isFlashing: WorkspaceService.flashingIds[modelData.id] === true
                    readonly property bool isOccupied: WorkspaceService.occupiedIds[modelData.id] === true
                    required property var modelData

                    anchors.verticalCenter: parent.verticalCenter
                    color: flashOn ? ColorConfig.lavenderAlpha35 : isActive ? ColorConfig.accentAlt : isOccupied ? ColorConfig.accent : ColorConfig.lavenderAlpha35
                    height: BarConfig.workspacePillHeight
                    radius: height / 2
                    width: isActive ? height * BarConfig.workspaceActiveWidthScale : height

                    Behavior on color {
                        ColorAnimation {
                            duration: BarConfig.workspacePillAnimMs
                        }
                    }
                    Behavior on width {
                        NumberAnimation {
                            duration: BarConfig.workspacePillAnimMs
                            easing.type: Easing.OutQuad
                        }
                    }

                    onIsFlashingChanged: if (isFlashing)
                        flashAnim.restart()

                    SequentialAnimation {
                        id: flashAnim

                        loops: 3

                        onFinished: WorkspaceService.flashingIds = ({})

                        PropertyAction {
                            property: "flashOn"
                            target: pill
                            value: true
                        }
                        PauseAnimation {
                            duration: BarConfig.workspaceFlashOnMs
                        }
                        PropertyAction {
                            property: "flashOn"
                            target: pill
                            value: false
                        }
                        PauseAnimation {
                            duration: BarConfig.workspaceFlashOffMs
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: Quickshell.execDetached(["hyprtile", "fw", pill.modelData.id.toString()])
                    }
                }
            }
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            color: ColorConfig.text
            font.family: IconConfig.fontFamily
            font.pixelSize: BarConfig.iconSize
            text: IconConfig.overview

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onClicked: Quickshell.execDetached(["keqing-shell", "overview"])
            }
        }
    }
}
