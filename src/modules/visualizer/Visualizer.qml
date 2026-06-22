pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Wayland

import KeqingShell.Visualizer

import qs.lib.service
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

                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "qs-visualizer"
                color: "transparent"
                exclusiveZone: 0
                screen: vizWindow.modelData
                visible: DisplayService.showVisualizer(vizWindow.modelData)

                anchors {
                    bottom: true
                    left: true
                    right: true
                    top: true
                }
                VisualiserBars {
                    id: bars

                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    animationDuration: 60
                    gradientColors: VisualizerConfig.barGradient
                    height: VisualizerConfig.barMaxHeight
                    opacity: VisualizerConfig.barOpacity
                    rounding: VisualizerConfig.barRadius
                    spacing: VisualizerConfig.barSpacing
                    values: spectrum.values
                    width: VisualizerConfig.barCount * (VisualizerConfig.barWidth + VisualizerConfig.barSpacing)

                    FrameAnimation {
                        running: !bars.settled

                        onTriggered: bars.advance(frameTime)
                    }
                }
            }
        }
    }
}
