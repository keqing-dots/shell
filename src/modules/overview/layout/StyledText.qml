pragma ComponentBehavior: Bound

import QtQuick

import qs.modules.overview
import qs.styles

Text {
    id: root

    color: OverviewConfig.onBackground
    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter

    font {
        family: GlobalConfig.fontFamily
        hintingPreference: Font.PreferFullHinting
        pixelSize: GlobalConfig.fontPixelSmall
    }
}
