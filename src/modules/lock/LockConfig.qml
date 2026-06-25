pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

import qs.config

QtObject {
    // Animation
    readonly property int animFastMs: 100
    readonly property int animNormalMs: 150

    // Background
    readonly property int bgBorderWidth: 5
    readonly property color bgDark: ColorConfig.fieldBg
    readonly property int bgRadius: 10
    readonly property color borderAccent: ColorConfig.accent

    // Dots
    readonly property int dotSize: 20
    readonly property int dotSlideOffset: 15

    // Typography
    readonly property int fontDate: 40
    readonly property int fontNormal: 20
    readonly property int fontTime: 100

    // Input
    readonly property int inputHeight: 60
    readonly property int inputRadius: 30
    readonly property int inputWidth: 500

    // Layout
    readonly property int layoutSpacing: 20
    readonly property int marginLarge: 50

    // Panel
    readonly property color panelBg: ColorConfig.overlay
    readonly property int panelMargin: 20

    // Profile
    readonly property int profileBorderWidth: 4
    readonly property int profileSize: 200

    // Colors
    readonly property color textDark: "black"
    readonly property color textMain: ColorConfig.text
    readonly property int timerFailMs: 3000
}
