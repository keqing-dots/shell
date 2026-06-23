pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.lib.service
import qs.modules.settings.layout.components
import qs.modules.settings.layout.tabs

Item {
    ColumnLayout {
        anchors.fill: parent
        spacing: 14

        DropdownMenu {
            activeValue: ColorSchemeService.mode
            model: [
                {
                    label: "Default",
                    value: "default"
                },
                {
                    label: "Display Capture",
                    value: "capture"
                }
            ]

            onItemSelected: value => ColorSchemeService.mode = value
        }
        DefaultSubtab {
            Layout.fillWidth: true
            visible: ColorSchemeService.mode === "default"
        }
        CaptureSubtab {
            Layout.fillWidth: true
            visible: ColorSchemeService.mode === "capture"
        }
        Item {
            Layout.fillHeight: true
        }
    }
}
