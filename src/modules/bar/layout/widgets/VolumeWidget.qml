pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import qs.lib.service
import qs.modules.bar
import qs.modules.bar.layout.components
import qs.modules.bar.service
import qs.styles

WidgetCapsule {
    id: root

    property bool peekActive: false
    property bool peekReady: false

    iconGlyph: {
        if (VolumeService.sinkMuted)
            return Icons.volumeMute;
        if (VolumeService.sinkVolume === 0)
            return Icons.volumeEmpty;
        if (VolumeService.sinkVolume < 0.5)
            return Icons.volumeLow;
        return Icons.volumeHigh;
    }
    labelText: VolumeService.sinkMuted ? "muted" : Math.round(VolumeService.sinkVolume * 100) + "%"
    panelName: "volumePanel"
    showLabel: baseShowLabel || peekActive

    Connections {
        function onSinkMutedChanged() {
            peekTimer.restart();
        }
        function onSinkVolumeChanged() {
            peekTimer.restart();
        }

        enabled: root.peekReady
        target: VolumeService
    }
    Timer {
        id: peekTimer

        interval: 2000

        onRunningChanged: if (running)
            root.peekActive = true
        onTriggered: root.peekActive = false
    }
    Timer {
        interval: 1000
        running: true

        onTriggered: root.peekReady = true
    }
    MouseArea {
        acceptedButtons: Qt.LeftButton
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: PanelService.getPanel("volumePanel", root.screen)?.toggle(root)
        onWheel: function (wheel) {
            var up = wheel.angleDelta.y > 0;
            Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", up ? "5%+" : "5%-"]);
        }
    }
}
