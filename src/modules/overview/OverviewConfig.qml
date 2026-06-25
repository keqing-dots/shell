pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick

import qs.styles

QtObject {
    id: root

    // Animation
    property int animEnterMs: 400
    property Component animEnterNumber: Component {
        NumberAnimation {
            duration: root.animEnterMs
            easing.type: Easing.OutCubic
        }
    }
    property int animFastMs: 200
    property Component animFastNumber: Component {
        NumberAnimation {
            duration: root.animFastMs
            easing.type: Easing.OutCubic
        }
    }

    // Layout
    property int backgroundBorderWidth: 1

    // Colors
    property color backgroundColor: ColorConfig.fieldBg
    property real backgroundOpacity: 1
    property int backgroundPadding: 10
    readonly property color colLayer0: backgroundColor
    readonly property color colLayer0Border: ColorConfig.accent
    readonly property color colLayer1: ColorConfig.fieldBg
    readonly property color colLayer1Hover: ColorConfig.fieldBg
    readonly property color colLayer2: "transparent"
    readonly property color colLayer2Active: ColorConfig.accentAlpha20
    readonly property color colLayer2Hover: ColorConfig.textAlpha08
    readonly property color colOnLayer1: ColorConfig.text
    readonly property color colOnTooltip: ColorConfig.text
    readonly property color colShadow: ColorConfig.overlay
    readonly property color colTooltip: ColorConfig.fieldBg
    property int columns: 5
    property real elevationMargin: 10
    readonly property color emptyWorkspaceBorderColor: applyAlpha(ColorConfig.text, 0.18)

    // Misc
    property bool enable: true

    // Timing
    property int focusGrabDelayMs: 150
    property int focusedIndicatorBorderWidth: 2

    // Window
    property real iconToWindowRatio: 0.25
    property real iconToWindowRatioCompact: 0.45
    readonly property color onBackground: ColorConfig.text
    property real otherMonitorOpacity: 0.4
    readonly property color outline: ColorConfig.accent
    property int raceDelayMs: 150
    property int rows: 2
    property real scale: 0.15
    property int screenRounding: 23

    // Shadow
    property real shadowBlurFactor: 0.9
    property real shadowOffsetX: 0.0
    property real shadowOffsetY: 1.0
    property int shadowRadius: 20
    property real shadowSpread: 1
    property int superReleaseGuardMs: 500

    // Tooltip
    property int toolTipHorizontalPadding: 10
    property int toolTipVerticalPadding: 5
    property int tooltipRounding: 8
    property int windowDraggingZ: 99999
    property int windowPreviewBorderWidth: 1
    property int windowRounding: 18

    // Workspace
    property int workspaceBorderWidth: 2
    property int workspaceNumberBaseSize: 250
    property real workspaceNumberTextFade: 0.8
    property real workspaceSpacing: 5

    function applyAlpha(color, alpha) {
        const c = Qt.color(color);
        return Qt.rgba(c.r, c.g, c.b, alpha);
    }
}
