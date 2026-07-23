pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Wayland

import KeqingShell.Visualizer

import qs.service
import qs.modules.visualizer

Scope {
    // Spectrum
    PwSpectrum {
        id: spectrum

        bars: VisualizerConfig.barCount
        targetNodeId: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.id : 0
    }
    FrameAnimation {
        running: true

        onTriggered: spectrum.processFrame()
    }

    // Windows
    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: vizWindow

                required property var modelData
                readonly property bool shouldShow: DisplayService.showVisualizer(vizWindow.modelData) && (!SettingsService.idleValueForScreen(vizWindow.modelData, "autoHideEnabled") || !IdleService.isIdle(vizWindow.modelData, SettingsService.idleValueForScreen(vizWindow.modelData, "autoHideTimeoutSeconds") * 1000))

                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "qs-visualizer"
                color: "transparent"
                exclusiveZone: 0
                screen: vizWindow.modelData
                visible: content.opacity > 0 || shouldShow

                anchors {
                    bottom: true
                    left: true
                    right: true
                    top: true
                }
                Item {
                    id: content

                    anchors.fill: parent
                    opacity: vizWindow.shouldShow ? VisualizerConfig.visibleOpacity : VisualizerConfig.hiddenOpacity

                    Behavior on opacity {
                        NumberAnimation {
                            duration: VisualizerConfig.contentFadeAnimMs
                            easing.type: Easing.OutCubic
                        }
                    }

                    VisualiserBars {
                        id: bars

                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        animationDuration: VisualizerConfig.barsAnimDurationMs
                        gradientColors: VisualizerConfig.barGradient
                        height: VisualizerConfig.barMaxHeight
                        opacity: VisualizerConfig.barOpacity
                        rounding: VisualizerConfig.barRadius
                        spacing: VisualizerConfig.barSpacing
                        values: spectrum.values
                        width: VisualizerConfig.barCount * VisualizerConfig.barWidth + (VisualizerConfig.barCount - 1) * VisualizerConfig.barSpacing

                        FrameAnimation {
                            running: !bars.settled

                            onTriggered: bars.advance(frameTime)
                        }
                    }
                }
            }
        }
    }
}
