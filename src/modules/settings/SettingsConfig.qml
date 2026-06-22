pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick

QtObject {
    // Window
    readonly property int windowHeight: 520
    readonly property int windowWidth: 640

    // Sidebar
    readonly property int sidebarWidth: 140

    // Tab chip
    readonly property int chipHeight: 35
    readonly property int chipRadius: 6
    readonly property int chipSpacing: 6

    // Input
    readonly property int inputHeight: 28
    readonly property int inputRadius: 4
    readonly property int inputWidth: 72
    readonly property int rowHeight: 40
}
