pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

QtObject {
    id: root

    // Animation
    readonly property int animationFast: 150
    readonly property int animationNormal: 220

    // Sizing
    readonly property int borderWidthThick: 4
    readonly property int borderWidthThin: 2
    readonly property int radiusMd: 10
    readonly property int radiusSm: 5

    // Assets
    readonly property url defaultWallpaper: source("assets/default_wp.svg")
    readonly property url inputEcho: source("assets/pwdelegate/1.png")
    readonly property url logoutLogo: source("assets/gifs/logoutlogo.gif")
    readonly property url userPfp: source("assets/gifs/userpfp.gif")
    readonly property url pamConfigDir: source("assets/")
    readonly property string pamConfigFile: "pam.conf"

    // System
    readonly property string user: Quickshell.env("USER")

    function constellation(index) {
        return Qt.resolvedUrl("assets/lmbullets/" + index + ".png");
    }
    function source(url) {
        return Qt.resolvedUrl(url);
    }
}
