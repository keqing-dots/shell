pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

import qs.modules.overview
import qs.modules.overview.service

PanelWindow {
    id: root

    readonly property string _screenName: root.screen?.name ?? ""
    property bool contentReady: false
    readonly property int monitorId: Hyprland.monitorFor(root.screen)?.id ?? -1

    signal requestClose

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:overview"
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    implicitHeight: columnLayout.implicitHeight
    implicitWidth: columnLayout.implicitWidth
    visible: GlobalStates.overviewOpen || closeTimer.running

    Connections {
        function onOverviewOpenChanged() {
            if (GlobalStates.overviewOpen) {
                contentReadyTimer.start();
                keyboardHandler.forceActiveFocus();
            } else {
                root.contentReady = false;
                closeTimer.start();
            }
        }

        target: GlobalStates
    }
    Timer {
        id: closeTimer

        interval: OverviewConfig.animFastMs
        repeat: false
    }
    Timer {
        id: contentReadyTimer

        interval: 32
        repeat: false

        onTriggered: root.contentReady = true
    }
    anchors {
        bottom: true
        left: !OverviewConfig.enable
        right: !OverviewConfig.enable
        top: true
    }
    Item {
        id: focusGrab

        property int delay: OverviewConfig.focusGrabDelayMs
        property bool monitorIsFocused: {
            const focused = Hyprland.focusedMonitor;
            if (!focused)
                return false;
            const byId = focused.id === Hyprland.monitorFor(root.screen)?.id;
            const byName = root._screenName && (focused.name === root._screenName);
            return byName || byId;
        }
        property bool overviewOpen: GlobalStates.overviewOpen

        onMonitorIsFocusedChanged: {
            if (overviewOpen && monitorIsFocused && !grab.active)
                delayedGrabTimer.restart();
        }
        onOverviewOpenChanged: {
            if (overviewOpen)
                delayedGrabTimer.restart();
            else
                grab.active = false;
        }

        HyprlandFocusGrab {
            id: grab

            property bool canBeActive: focusGrab.monitorIsFocused

            active: false
            windows: [root]

            onCleared: () => {
                if (!active)
                    root.requestClose();
            }
        }
        Timer {
            id: delayedGrabTimer

            interval: focusGrab.delay
            repeat: false

            onTriggered: {
                if (!grab.canBeActive)
                    return;
                grab.active = focusGrab.overviewOpen;
            }
        }
    }
    MouseArea {
        id: closeArea

        acceptedButtons: Qt.LeftButton
        anchors.fill: parent
        enabled: GlobalStates.overviewOpen
        visible: GlobalStates.overviewOpen

        onClicked: mouse => {
            const inX = mouse.x >= columnLayout.x && mouse.x < (columnLayout.x + columnLayout.width);
            const inY = mouse.y >= columnLayout.y && mouse.y < (columnLayout.y + columnLayout.height);
            if (inX && inY) {
                mouse.accepted = false;
            } else {
                root.requestClose();
                mouse.accepted = true;
            }
        }
    }
    KeyboardNavigation {
        id: keyboardHandler

        active: GlobalStates.overviewOpen
        anchors.fill: parent

        onRequestClearWorkspace: modifiers => HyprlandManager.clearWorkspace(modifiers)
        onRequestClose: root.requestClose()
        onRequestSwitchWorkspace: (position, modifiers) => HyprlandManager.switchToWorkspace(position, modifiers)
    }
    ColumnLayout {
        id: columnLayout

        property real xSlide: GlobalStates.overviewOpen ? 0 : -40

        anchors.centerIn: parent
        opacity: GlobalStates.overviewOpen ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: OverviewConfig.animFastMs
                easing.type: Easing.OutCubic
            }
        }
        transform: Translate {
            x: columnLayout.xSlide
        }
        Behavior on xSlide {
            NumberAnimation {
                duration: OverviewConfig.animFastMs
                easing.type: Easing.OutCubic
            }
        }

        Loader {
            id: overviewLoader

            active: OverviewConfig.enable && root.contentReady

            sourceComponent: Widget {
                monitorId: root.monitorId
                visible: true

                onRequestClose: root.requestClose()
            }
        }
    }
}
