pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick

import qs.config

QtObject {
    // Animation
    readonly property int animFast: 150
    readonly property int animNormal: 220

    // Typography
    readonly property int fontAppName: 13
    readonly property int fontBody: 15
    readonly property int fontSummary: 17

    // Card
    readonly property color cardBg: ColorConfig.overlay
    readonly property color cardBorder: ColorConfig.accent
    readonly property int cardBorderWidth: 2
    readonly property int cardPadding: 16
    readonly property int cardRadius: 10
    readonly property int cardSpacing: 8
    readonly property int cardWidth: 400

    // Screen
    readonly property int screenMargin: 10
}
