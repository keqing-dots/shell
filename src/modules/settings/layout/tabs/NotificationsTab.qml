pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.service
import qs.modules.settings
import qs.modules.settings.layout.components
import qs.config

Flickable {
    id: root

    clip: true
    contentHeight: col.implicitHeight

    Column {
        id: col

        spacing: 12
        width: root.width

        SettingsGroup {
            title: "Position"
            width: col.width

            RowLayout {
                height: 40
                spacing: 10
                width: parent.width

                Text {
                    Layout.fillWidth: true
                    color: ColorConfig.textDim
                    font.family: FontConfig.fontFamily
                    font.pixelSize: FontConfig.fontSettingsBody
                    text: "Vertical"
                }
                DropdownMenu {
                    activeValue: SettingsService.adapter.notification.vertical
                    labelRole: "label"
                    model: [{"label": "Top", "value": "top"}, {"label": "Bottom", "value": "bottom"}]
                    valueRole: "value"

                    onItemSelected: value => SettingsService.setNotification({vertical: value})
                }
            }
            RowLayout {
                height: 40
                spacing: 10
                width: parent.width

                Text {
                    Layout.fillWidth: true
                    color: ColorConfig.textDim
                    font.family: FontConfig.fontFamily
                    font.pixelSize: FontConfig.fontSettingsBody
                    text: "Horizontal"
                }
                DropdownMenu {
                    activeValue: SettingsService.adapter.notification.horizontal
                    labelRole: "label"
                    model: [{"label": "Left", "value": "left"}, {"label": "Center", "value": "center"}, {"label": "Right", "value": "right"}]
                    valueRole: "value"

                    onItemSelected: value => SettingsService.setNotification({horizontal: value})
                }
            }
        }
    }
}
