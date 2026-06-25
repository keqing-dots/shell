pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell.Services.Pipewire

import qs.service
import qs.modules.bar.layout.components
import qs.modules.bar.layout.popups.cards

Item {
    id: root

    implicitHeight: scroll.implicitHeight
    implicitWidth: 360

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }
    ScrollView {
        id: scroll

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff
        anchors.fill: parent

        Column {
            id: col

            spacing: 10
            width: root.width

            ProfileCard {}
            Repeater {
                model: SettingsService.controlCenter.cards

                delegate: CardLoader {
                    required property var modelData

                    cardId: modelData
                    width: col.width
                }
            }
        }
    }
}
