pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.lib.service
import qs.modules.wallpaper
import qs.styles

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: screenWindow

                property string activeEffect: "fade"
                property bool awaitingCommit: false
                property string lastCommittedPath: ""
                required property var modelData
                property bool transitionActive: false
                property real transitionProgress: 0.0

                function beginTransition() {
                    transitionActive = true;
                    var effects = ["fade", "wipe", "disc", "stripes", "pixelate", "zoom"];
                    activeEffect = effects[Math.floor(Math.random() * effects.length)];
                    transitionShader.direction = Math.floor(Math.random() * 4);
                    transitionShader.centerX = Math.random();
                    transitionShader.centerY = Math.random();
                    transitionShader.stripeCount = Math.floor(Math.random() * 13) + 8;
                    transitionShader.angle = Math.random() * Math.PI;
                    transitionShader.maxBlockSize = Math.floor(Math.random() * 49) + 32;
                    transitionAnim.restart();
                }
                function resolvedFillMode(screenName) {
                    switch ((WallpaperService.currentFillModes ?? {})[screenName] ?? "crop") {
                    case "fit":
                        return Image.PreserveAspectFit;
                    case "stretch":
                        return Image.Stretch;
                    case "tile":
                        return Image.Tile;
                    default:
                        return Image.PreserveAspectCrop;
                    }
                }
                function resolvedSourceSize(src, w, h) {
                    return String(src).toLowerCase().endsWith(".svg") ? Qt.size(0, h) : Qt.size(w, h);
                }

                WlrLayershell.layer: WlrLayer.Background
                color: "black"
                exclusionMode: ExclusionMode.Ignore
                screen: modelData

                anchors {
                    bottom: true
                    left: true
                    right: true
                    top: true
                }
                NumberAnimation {
                    id: transitionAnim

                    duration: 700
                    easing.type: Easing.InOutCubic
                    from: 0.0
                    property: "transitionProgress"
                    target: screenWindow
                    to: 1.0

                    onFinished: {
                        if (!imgIncoming.source || imgIncoming.status !== Image.Ready) {
                            screenWindow.transitionActive = false;
                            screenWindow.transitionProgress = 0.0;
                            return;
                        }
                        screenWindow.awaitingCommit = true;
                        imgCurrent.source = imgIncoming.source;
                    }
                }
                Image {
                    id: imgIncoming

                    anchors.fill: parent
                    asynchronous: true
                    cache: false
                    fillMode: (WallpaperService.currentWallpapers ?? {})[screenWindow.modelData.name] ? screenWindow.resolvedFillMode(screenWindow.modelData.name) : Image.PreserveAspectFit
                    layer.enabled: screenWindow.transitionActive
                    opacity: 0
                    smooth: true
                    source: {
                        var p = (WallpaperService.currentWallpapers ?? {})[screenWindow.modelData.name];
                        var target = p ? "file://" + p : String(GlobalConfig.defaultWallpaper);
                        return target !== screenWindow.lastCommittedPath ? target : "";
                    }
                    sourceSize: screenWindow.resolvedSourceSize(source, width, height)
                    z: 0

                    onStatusChanged: {
                        if (status !== Image.Ready)
                            return;
                        if (screenWindow.awaitingCommit)
                            return;
                        screenWindow.beginTransition();
                    }
                }
                Image {
                    id: imgCurrent

                    anchors.fill: parent
                    asynchronous: true
                    cache: false
                    fillMode: imgCurrent.source && imgCurrent.source !== GlobalConfig.defaultWallpaper ? screenWindow.resolvedFillMode(screenWindow.modelData.name) : Image.PreserveAspectFit
                    layer.enabled: screenWindow.transitionActive
                    smooth: true
                    sourceSize: screenWindow.resolvedSourceSize(source, width, height)
                    z: 1

                    onStatusChanged: {
                        if (status === Image.Ready && screenWindow.awaitingCommit) {
                            screenWindow.awaitingCommit = false;
                            screenWindow.transitionProgress = 0.0;
                            screenWindow.transitionActive = false;
                            screenWindow.lastCommittedPath = String(imgCurrent.source);
                        }
                    }
                }
                ShaderEffect {
                    id: transitionShader

                    property real angle: 0.785
                    readonly property real aspectRatio: width / height
                    property real centerX: 0.5
                    property real centerY: 0.5
                    property real direction: 0
                    property real maxBlockSize: 64
                    property real progress: screenWindow.transitionProgress
                    readonly property real screenHeight: height
                    readonly property real screenWidth: width
                    property variant source1: imgCurrent
                    property variant source2: imgIncoming
                    property real stripeCount: 12

                    anchors.fill: parent
                    fragmentShader: Qt.resolvedUrl("shaders/compiled/wp_" + screenWindow.activeEffect + ".frag.qsb")
                    visible: screenWindow.transitionProgress > 0
                    z: 2
                }
            }
        }
    }
}
