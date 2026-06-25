pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick

import qs.styles

QtObject {
    // Animation
    readonly property int animMs: 350

    // Panel
    readonly property int borderWidth: 5
    readonly property color panelBg: ColorConfig.overlay
    readonly property int panelMargin: 30
    readonly property int panelRadius: 20
    readonly property int panelWidth: 480

    // Input
    readonly property int dotMargin: 8
    readonly property int dotSize: 16
    readonly property int dotSlideOffset: 12
    readonly property int inputHeight: 55
    readonly property int inputRadius: 27
    readonly property int inputWidth: 420

    // Spacing
    readonly property int spacing: 16
}
