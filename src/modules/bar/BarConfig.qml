pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick

import qs.service
import qs.config

QtObject {
    // Bar
    readonly property real backgroundOpacity: SettingsService.adapter.bar.backgroundOpacity
    readonly property int barHeight: SettingsService.adapter.bar.height
    readonly property int barMarginH: SettingsService.adapter.bar.marginH
    readonly property int barMarginTop: SettingsService.adapter.bar.marginTop
    readonly property string barPosition: "top"

    // Capsule
    readonly property color capsuleBg: ColorConfig.overlay
    readonly property color capsuleBgHover: ColorConfig.overlay
    readonly property color capsuleBorder: ColorConfig.accent
    readonly property int capsuleBorderWidth: 2
    readonly property int capsuleHeight: barHeight
    readonly property int capsuleRadius: GlobalConfig.radiusMd

    // Typography
    readonly property int fontSize: FontConfig.fontBarLabel
    readonly property int iconSize: 18

    // Layout
    readonly property real marginHorizontal: 5
    readonly property real marginVertical: 5

    // Menu
    readonly property color menuBg: ColorConfig.overlay
    readonly property color menuBorder: ColorConfig.accent
    readonly property color menuHover: ColorConfig.textAlpha13
    readonly property color panelBg: ColorConfig.overlay
    readonly property color panelBorder: ColorConfig.accent

    // Panel
    readonly property int panelBorderWidth: 2
    readonly property int panelGap: 8
    readonly property int panelPadding: 20
    readonly property int panelRadius: GlobalConfig.radiusMd
    readonly property int screenMargin: SettingsService.adapter.bar.screenMargin
    readonly property real widgetSpacing: 10
    readonly property color workspaceActive: ColorConfig.accentAlt
    readonly property color workspaceInactive: ColorConfig.lavenderAlpha35
    readonly property color workspaceOccupied: ColorConfig.accent

    // Profile Card
    readonly property int logoBorderWidth: 5
}
