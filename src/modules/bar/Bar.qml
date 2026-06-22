pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.lib.service
import qs.modules.bar
import qs.modules.bar.layout.components
import qs.modules.bar.layout.popups

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        delegate: Component {
            Scope {
                id: screenScope

                required property var modelData
                readonly property var screenWidgets: {
                    var all = SettingsService.allWidgets;
                    var sn = screenScope.modelData.name;
                    var sm = screenScope.modelData.model;
                    var entry = all[sn] || all[sm];
                    if (!entry || entry._enabled === false)
                        entry = all["default"] || SettingsService._defaultWidgets;
                    var def = SettingsService._defaultWidgets;
                    return {
                        left: entry.left || def.left,
                        center: entry.center || def.center,
                        right: entry.right || def.right
                    };
                }

                PanelWindow {
                    id: win

                    WlrLayershell.layer: WlrLayer.Top
                    color: "transparent"
                    implicitHeight: BarConfig.barHeight
                    screen: screenScope.modelData
                    visible: DisplayService.showBar(screenScope.modelData)

                    anchors {
                        left: true
                        right: true
                        top: true
                    }
                    margins {
                        left: BarConfig.barMarginH
                        right: BarConfig.barMarginH
                        top: BarConfig.barMarginTop
                    }
                    Rectangle {
                        anchors.fill: parent
                        color: Qt.rgba(0, 0, 0, BarConfig.backgroundOpacity)
                    }
                    BarRegion {
                        position: "left"
                        screen: screenScope.modelData
                        widgets: screenScope.screenWidgets.left
                    }
                    BarRegion {
                        position: "center"
                        screen: screenScope.modelData
                        widgets: screenScope.screenWidgets.center
                    }
                    BarRegion {
                        position: "right"
                        screen: screenScope.modelData
                        widgets: screenScope.screenWidgets.right
                    }
                }
                PopupOverlay {
                    screen: screenScope.modelData
                }
                PopupMenuWindow {
                    screen: screenScope.modelData
                }
            }
        }
    }
}
