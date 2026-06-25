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
                    color: GlobalConfig.text
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontPixelSmaller
                    font.weight: Font.DemiBold
                    opacity: 0.85
                    text: "Font Family"
                }
                DropdownMenu {
                    activeValue: GlobalConfig.fontFamily
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    model: {
                        const local = [GlobalConfig.yujiMaiLoader.name, Icons.fontFamily];
                        return Qt.fontFamilies().filter(f => !local.includes(f)).sort();
                    }

                    onItemSelected: value => SettingsService.setFontFamily(value)
                }
            }
        }
    }
}
