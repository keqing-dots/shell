pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick

import qs.lib.service
import qs.styles

QtObject {
    // Bar
    readonly property real backgroundOpacity: SettingsService.adapter.bar.backgroundOpacity
    readonly property int barHeight: SettingsService.adapter.bar.height
    readonly property int barMarginH: SettingsService.adapter.bar.marginH
    readonly property int barMarginTop: SettingsService.adapter.bar.marginTop
    readonly property string barPosition: "top"

    // Capsule
    readonly property color capsuleBg: GlobalConfig.overlay
    readonly property color capsuleBgHover: GlobalConfig.overlay
    readonly property color capsuleBorder: GlobalConfig.accent
    readonly property int capsuleBorderWidth: 2
    readonly property int capsuleHeight: barHeight
    readonly property int capsuleRadius: GlobalConfig.radiusMd

    // Typography
    readonly property int fontSize: GlobalConfig.fontPixelSmall
    readonly property int iconSize: 18

    // Layout
    readonly property real marginHorizontal: 5
    readonly property real marginVertical: 5

    // Menu
    readonly property color menuBg: GlobalConfig.overlay
    readonly property color menuBorder: GlobalConfig.accent
    readonly property color menuHover: GlobalConfig.textAlpha13
    readonly property color panelBg: GlobalConfig.overlay
    readonly property color panelBorder: GlobalConfig.accent

    // Panel
    readonly property int panelBorderWidth: 2
    readonly property int panelGap: 8
    readonly property int panelPadding: 20
    readonly property int panelRadius: GlobalConfig.radiusMd
    readonly property int screenMargin: SettingsService.adapter.bar.screenMargin
    readonly property real widgetSpacing: 10
    readonly property color workspaceActive: GlobalConfig.accentAlt
    readonly property color workspaceInactive: GlobalConfig.lavenderAlpha35
    readonly property color workspaceOccupied: GlobalConfig.accent
}
