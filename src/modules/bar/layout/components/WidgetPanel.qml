pragma ComponentBehavior: Bound

import QtQuick

import qs.components
import qs.modules.bar
import qs.config

PanelRect {
    border.color: BarConfig.panelBorder
    border.width: BarConfig.panelBorderWidth
    color: BarConfig.panelBg
    radius: BarConfig.panelRadius
}
