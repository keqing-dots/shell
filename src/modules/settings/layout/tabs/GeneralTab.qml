pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.lib.service
import qs.modules.settings.layout.components
import qs.styles

Flickable {
    id: root

    clip: true
    contentHeight: col.implicitHeight

    Column {
        id: col

        spacing: 12
        width: root.width

        SettingsGroup {
            title: "Appearance"
            width: col.width

            Item {
                height: 40
                width: parent.width

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    color: ColorConfig.text
                    font.family: FontConfig.fontFamily
                    font.pixelSize: FontConfig.fontSettingsBody
                    font.weight: Font.DemiBold
                    opacity: 0.85
                    text: "Font Family"
                }
                DropdownMenu {
                    activeValue: FontConfig.fontFamily
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    model: {
                        const local = [FontConfig.yujiMaiLoader.name, Icons.fontFamily];
                        return Qt.fontFamilies().filter(f => !local.includes(f)).sort();
                    }
                    selfFont: true

                    onItemSelected: value => SettingsService.setFontFamily(value)
                }
            }
        }
    }
}
