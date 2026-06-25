pragma ComponentBehavior: Bound

import QtQuick

import qs.modules.overview
import qs.config

Text {
    id: root

    color: OverviewConfig.onBackground
    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter

    font {
        family: FontConfig.fontFamily
        hintingPreference: Font.PreferFullHinting
        pixelSize: FontConfig.fontOverviewText
    }
}
