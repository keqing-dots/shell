pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick

QtObject {
    // Panel
    readonly property int panelBottomMargin: 30
    readonly property int panelHeight: 50
    readonly property int panelRadius: 25
    readonly property int panelWidth: 280

    // Content
    readonly property int iconLeftMargin: 14
    readonly property int iconSize: 18
    readonly property int labelRightMargin: 14
    readonly property int labelWidth: 44

    // Track
    readonly property int trackHeight: 6
    readonly property int trackHorizMargin: 10
    readonly property int trackRadius: 3
}
