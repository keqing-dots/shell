pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick

import qs.styles

QtObject {

    // Borders
    readonly property color border: GlobalConfig.textAlpha12
    readonly property color borderFocus: GlobalConfig.accent
    readonly property color borderHover: GlobalConfig.textAlpha35
    readonly property int buttonHeight: 32
    readonly property int buttonRadius: 8
    readonly property int buttonWidth: 84
    readonly property bool defaultNeonMode: false
    readonly property int dropdownInnerMargin: 4
    readonly property int dropdownInnerSpacing: 2

    readonly property int dropdownItemHeight: 28

    // Interactive states
    readonly property color hover: GlobalConfig.textAlpha13
    readonly property color hoverStrong: GlobalConfig.textAlpha20
    readonly property color innerBgAlt: GlobalConfig.textAlpha04

    // Geometry
    readonly property int inputRadius: GlobalConfig.radiusSm
    // Panel
    readonly property color panelBg: GlobalConfig.overlay
    readonly property int panelRadius: 10
}
