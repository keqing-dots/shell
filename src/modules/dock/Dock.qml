pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.service
import qs.modules.dock

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: win

                readonly property bool autohide: DockConfig.autohideEnabled
                readonly property bool effectiveShouldShow: !win.autohide || win.shouldShow
                readonly property int fullHeight: DockConfig.marginBottom + content.implicitHeight
                required property var modelData
                readonly property bool shouldShow: hoverHandler.hovered

                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "qs-dock"
                color: "transparent"
                exclusiveZone: 0
                implicitHeight: win.effectiveShouldShow || content.opacity > 0 ? win.fullHeight : 1
                screen: win.modelData
                visible: DisplayService.showDock(win.modelData) && content.windows.length > 0

                anchors {
                    bottom: true
                    left: true
                    right: true
                }
                HoverHandler {
                    id: hoverHandler
                }
                DockWidget {
                    id: content

                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: DockConfig.marginBottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    opacity: win.effectiveShouldShow ? DockConfig.visibleOpacity : DockConfig.hiddenOpacity
                    screen: win.modelData

                    Behavior on opacity {
                        NumberAnimation {
                            duration: DockConfig.showAnimMs
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }
}
