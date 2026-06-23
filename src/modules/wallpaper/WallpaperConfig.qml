pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick

import qs.styles

QtObject {
    readonly property int chevronSize: 7

    // Column / layout
    readonly property int columnSpacing: 10

    // ControlRow
    readonly property int controlRowHeight: 35
    readonly property bool defaultNeonMode: false

    // DirBar
    readonly property int dirBarHeight: 40
    readonly property int dirBtnHeight: 28
    readonly property int dirBtnWidth: 72
    readonly property int dirEdgeMargin: 8
    readonly property int dirInputLeftMargin: 10
    readonly property int dirLabelLeftMargin: 14
    readonly property int dropdownBtnPadding: 20
    readonly property int dropdownBtnSpacing: 6
    readonly property int dropdownInnerMargin: 4
    readonly property int dropdownInnerSpacing: 2

    // Dropdowns
    readonly property int dropdownItemHeight: 28
    readonly property var fillModes: [
        {
            label: "Crop",
            mode: "crop"
        },
        {
            label: "Fit",
            mode: "fit"
        }
    ]
    readonly property color gridBorderColor: GlobalConfig.textAlpha12
    readonly property int gridBorderWidth: 5
    readonly property int gridSpacing: 10
    readonly property int imageRows: 4
    // Grid — source of truth for panel size; change these to resize the whole panel
    readonly property int imagesPerRow: 7
    readonly property color panelBg: GlobalConfig.overlay
    readonly property color panelBorderColor: GlobalConfig.textAlpha15
    readonly property int panelPadding: 16

    // Panel
    readonly property int panelRadius: 16
    readonly property color tabInactive: GlobalConfig.lavenderAlpha20
    readonly property color thumbnailBg: GlobalConfig.lavenderSubtle
    readonly property int thumbnailSize: 150
}
