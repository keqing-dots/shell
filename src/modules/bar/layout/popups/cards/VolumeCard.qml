pragma ComponentBehavior: Bound

import QtQuick

import qs.lib.layout
import qs.lib.service
import qs.modules.bar
import qs.modules.bar.layout.components
import qs.styles

ControlCenterCard {
    cardKey: "volume"
    contentHeight: column.implicitHeight
    title: "Volume"

    Column {
        id: column

        spacing: 8

        anchors {
            left: parent.left
            right: parent.right
        }
        VolumeRow {
            device: VolumeService.sink ? (VolumeService.sink.description || VolumeService.sink.name || "") : ""
            icon: VolumeService.sinkMuted ? Icons.volumeMute : VolumeService.sinkVolume === 0 ? Icons.volumeEmpty : VolumeService.sinkVolume < 0.5 ? Icons.volumeLow : Icons.volumeHigh
            label: "Output"
            muted: VolumeService.sinkMuted
            volume: VolumeService.sinkVolume
            width: parent.width

            onMuteToggled: VolumeService.setSinkMuted(!VolumeService.sinkMuted)
            onScrubbed: v => VolumeService.setSinkVolume(v)
        }
        VolumeRow {
            device: VolumeService.source ? (VolumeService.source.description || VolumeService.source.name || "") : ""
            icon: VolumeService.sourceMuted ? Icons.micOff : Icons.micOn
            label: "Input"
            muted: VolumeService.sourceMuted
            volume: VolumeService.sourceVolume
            width: parent.width

            onMuteToggled: VolumeService.setSourceMuted(!VolumeService.sourceMuted)
            onScrubbed: v => VolumeService.setSourceVolume(v)
        }
    }

    component VolumeRow: Column {
        id: row

        property string device: ""
        property string icon: ""
        property string label: ""
        property bool muted: false
        property real volume: 0

        signal muteToggled
        signal scrubbed(real value)

        spacing: 4

        Row {
            spacing: 4
            width: parent.width

            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: ColorConfig.text
                font.bold: true
                font.family: FontConfig.fontFamily
                font.pixelSize: BarConfig.fontSize
                text: row.label
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: ColorConfig.textDim
                elide: Text.ElideRight
                font.family: FontConfig.fontFamily
                font.pixelSize: BarConfig.fontSize
                text: row.device ? " — " + row.device : ""
                width: Math.min(implicitWidth, 148)
            }
        }
        Item {
            height: 24
            width: parent.width

            SliderBar {
                dimmed: row.muted
                height: 20
                maxValue: 100
                value: row.muted ? 0 : row.volume * 100

                onScrubbed: v => row.scrubbed(v / 100)

                anchors {
                    left: parent.left
                    right: pct.left
                    rightMargin: 8
                    verticalCenter: parent.verticalCenter
                }
            }
            Text {
                id: pct

                color: ColorConfig.textDim
                font.family: FontConfig.fontFamily
                font.pixelSize: BarConfig.fontSize
                horizontalAlignment: Text.AlignRight
                text: row.muted ? "muted" : Math.round(row.volume * 100) + "%"
                width: 40

                anchors {
                    right: muteBtn.left
                    rightMargin: 6
                    verticalCenter: parent.verticalCenter
                }
            }
            Rectangle {
                id: muteBtn

                color: muteMa.containsMouse ? BarConfig.capsuleBgHover : BarConfig.capsuleBg
                height: 22
                radius: 11
                width: 22

                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                Text {
                    anchors.centerIn: parent
                    color: ColorConfig.text
                    font.family: Icons.fontFamily
                    font.pixelSize: FontConfig.fontPanelActionIcon
                    text: row.icon
                }
                MouseArea {
                    id: muteMa

                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked: row.muteToggled()
                }
            }
        }
    }
}
