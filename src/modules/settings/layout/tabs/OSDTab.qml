pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.lib.service
import qs.modules.settings
import qs.modules.settings.layout.components
import qs.styles

Flickable {
    id: root

    readonly property var allOsds: ["Sink", "Source"]
    readonly property var labels: ({
            "Sink": "Output Volume",
            "Source": "Input Volume"
        })

    function disable(id) {
        var arr = Array.from(SettingsService.adapter.osd.active);
        var idx = arr.indexOf(id);
        if (idx !== -1) {
            arr.splice(idx, 1);
            SettingsService.setOsd(arr);
        }
    }
    function enable(id) {
        var arr = Array.from(SettingsService.adapter.osd.active);
        if (arr.indexOf(id) === -1) {
            arr.push(id);
            SettingsService.setOsd(arr);
        }
    }

    clip: true
    contentHeight: col.implicitHeight

    Column {
        id: col

        spacing: 12
        width: root.width

        SettingsGroup {
            title: "On-Screen Display"
            width: col.width

            Repeater {
                model: root.allOsds

                delegate: Item {
                    id: row

                    required property string modelData
                    readonly property bool on: SettingsService.adapter.osd.active.indexOf(row.modelData) !== -1

                    height: 40
                    width: parent.width

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        color: GlobalConfig.text
                        font.family: GlobalConfig.fontFamily
                        font.pixelSize: GlobalConfig.fontPixelSmaller
                        text: root.labels[row.modelData] ?? row.modelData
                    }
                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        color: row.on ? GlobalConfig.accent : GlobalConfig.textAlpha15
                        height: 20
                        radius: 10
                        width: 36

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            color: "white"
                            height: 14
                            radius: 7
                            width: 14
                            x: row.on ? parent.width - width - 3 : 3

                            Behavior on x {
                                NumberAnimation {
                                    duration: 150
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked: row.on ? root.disable(row.modelData) : root.enable(row.modelData)
                        }
                    }
                }
            }
        }
    }
}
