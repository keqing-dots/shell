pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland

import qs.modules.bar
import qs.modules.bar.layout.components
import qs.modules.bar.service

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

    implicitWidth: pills.implicitWidth + 16

    Row {
        id: pills

        anchors.centerIn: parent
        spacing: 5

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
                color: flashOn ? BarConfig.workspaceInactive : isActive ? BarConfig.workspaceActive : isOccupied ? BarConfig.workspaceOccupied : BarConfig.workspaceInactive
                height: 12
                radius: height / 2
                width: isActive ? height * 2 : height

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
                Behavior on width {
                    NumberAnimation {
                        duration: 150
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
                        duration: 250
                    }
                    PropertyAction {
                        property: "flashOn"
                        target: pill
                        value: false
                    }
                    PauseAnimation {
                        duration: 200
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
}
