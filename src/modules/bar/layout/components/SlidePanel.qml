pragma ComponentBehavior: Bound

import QtQuick

import qs.modules.bar
import qs.modules.bar.service
import qs.config

Item {
    id: root

    readonly property int _panelH: root.height - _panelY - BarConfig.barMarginH
    readonly property int _panelW: 360
    readonly property int _panelX: side === "right" ? root.width - _panelW - BarConfig.barMarginH : BarConfig.barMarginH
    readonly property int _panelY: BarConfig.barMarginTop + BarConfig.barHeight + BarConfig.panelGap
    property bool isClosing: false
    property bool isPanelOpen: false
    property bool isPanelVisible: false
    property Component panelContent: null
    property var screen: null
    property string side: "right"

    signal closed
    signal opened

    function _finalizeClose() {
        closeWatchdog.stop();
        isPanelVisible = false;
        isPanelOpen = false;
        isClosing = false;
        PanelService.closedPanel(root);
        closed();
    }
    function close() {
        if (!isPanelOpen || isClosing)
            return;
        isClosing = true;
        closeWatchdog.restart();
    }
    function onEscapePressed() {
        close();
    }
    function open(buttonItem) {
        isClosing = false;
        isPanelOpen = true;
        PanelService.willOpenPanel(root);
    }
    function toggle(buttonItem) {
        if (isPanelOpen && !isClosing)
            close();
        else
            open(buttonItem);
    }

    anchors.fill: parent

    Component.onCompleted: PanelService.registerPanel(root)
    Component.onDestruction: PanelService.unregisterPanel(root)

    Timer {
        id: closeWatchdog

        interval: GlobalConfig.animationNormal * 3

        onTriggered: if (root.isClosing)
            root._finalizeClose()
    }
    Item {
        id: container

        clip: true
        height: Math.min(root._panelH, contentLoader.item ? contentLoader.item.implicitHeight : root._panelH)
        visible: root.isPanelOpen
        width: root.isPanelVisible && !root.isClosing ? root._panelW : 0
        x: root.side === "right" ? root._panelX + root._panelW - width : root._panelX
        y: root._panelY

        Behavior on width {
            NumberAnimation {
                duration: GlobalConfig.animationNormal
                easing.type: Easing.OutCubic

                onRunningChanged: {
                    if (!running && root.isClosing && container.width === 0)
                        Qt.callLater(root._finalizeClose);
                }
            }
        }

        Loader {
            id: contentLoader

            active: root.isPanelOpen
            anchors.fill: parent
            sourceComponent: root.panelContent

            onLoaded: {
                Qt.callLater(function () {
                    root.isPanelVisible = true;
                    root.opened();
                });
            }
        }
    }
}
