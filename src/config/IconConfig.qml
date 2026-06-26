pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick

QtObject {
    id: root

    // Font
    readonly property string fontFamily: tablerIconsLoader.status === FontLoader.Ready ? tablerIconsLoader.name : ""
    readonly property var tablerIconsLoader: FontLoader {
        source: Qt.resolvedUrl("../assets/fonts/tabler-icons.ttf")
    }

    // Status
    readonly property string alertTriangle: "\uea06"

    // Launcher
    readonly property string apps: "\uebb6"

    // Navigation
    readonly property string arrowDown: "\uea16"
    readonly property string arrowLeft: "\uea19"
    readonly property string arrowNarrowDown: "\uea1a"
    readonly property string arrowNarrowLeft: "\uea1b"
    readonly property string arrowNarrowRight: "\uea1c"
    readonly property string arrowNarrowUp: "\uea1d"
    readonly property string arrowRight: "\uea1f"
    readonly property string arrowUp: "\uea25"

    // Battery
    readonly property string battery1: "\uea2f"
    readonly property string battery2: "\uea30"
    readonly property string battery3: "\uea31"
    readonly property string battery4: "\uea32"
    readonly property string batteryCharging: "\uea33"

    // Bluetooth
    readonly property string bluetoothConnected: "\uecea"
    readonly property string bluetoothDevice: "\uea37"
    readonly property string bluetoothOff: "\ueceb"
    readonly property string bluetoothOn: "\uea37"

    // Brands
    readonly property string brandGoogle: "\uec1f"
    readonly property string brandYoutube: "\uec90"

    // Actions
    readonly property string check: "\uea5e"
    readonly property string chevronDown: "\uea5f"
    readonly property string chevronLeft: "\uea60"
    readonly property string chevronRight: "\uea61"
    readonly property string chevronUp: "\uea62"
    readonly property string close: "\ueb55"
    readonly property string code: "\uea77"

    // System
    readonly property string controlCenter: "\uec42"
    readonly property string cpu: "\uef8e"
    readonly property string gpu: "\uef8d"
    readonly property string folder: "\ueaad"
    readonly property string folderOpen: "\ufaf7"
    readonly property string link: "\ueade"
    readonly property string lock: "\ueae2"
    readonly property string lockOpen: "\ueae1"
    readonly property string logout: "\uea7b"
    readonly property string moon: "\ueb5a"
    readonly property string pluggedIn: "\uef3b"
    readonly property string power: "\ueb0d"
    readonly property string refresh: "\ueb13"
    readonly property string sun: "\ueb20"
    readonly property string thermometer: "\ueb38"
    readonly property string router: "\ueb18"
    readonly property string settings: "\ueb20"
    readonly property string terminal: "\uebdc"

    // Media
    readonly property string musicNote: "\ueafc"
    readonly property string playerNext: "\ued4b"
    readonly property string playerPause: "\ued45"
    readonly property string playerPlay: "\ued46"
    readonly property string playerPrev: "\ued4c"

    // Volume
    readonly property string micOff: "\ued16"
    readonly property string micOn: "\ueaf0"
    readonly property string volumeEmpty: "\ud800\udd9d"
    readonly property string volumeHigh: "\ueb51"
    readonly property string volumeLow: "\ueb4f"
    readonly property string volumeMute: "\uf1c3"

    // Network
    readonly property string wifi: "\ueb52"
    readonly property string wifi0: "\ueba3"
    readonly property string wifi1: "\ueba4"
    readonly property string wifi2: "\ueba5"
    readonly property string wifiOff: "\uecfa"

    // Overview
    readonly property string overview: "\ueef6"
}
