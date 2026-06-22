pragma ComponentBehavior: Bound

import QtQuick

import qs.lib.layout
import qs.modules.bar
import qs.styles

PanelRect {
    border.color: BarConfig.panelBorder
    border.width: BarConfig.panelBorderWidth
    color: BarConfig.panelBg
    radius: BarConfig.panelRadius
}
