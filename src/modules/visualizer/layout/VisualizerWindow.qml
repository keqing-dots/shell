pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

import KeqingShell.Visualizer

import qs.modules.visualizer

FloatingWindow {
    id: window

    required property bool isOpen

    color: VisualizerConfig.windowBackground
    height: VisualizerConfig.barMaxHeight
    visible: content.opacity > 0 || window.isOpen
    width: VisualizerConfig.barCount * VisualizerConfig.barWidth + (VisualizerConfig.barCount - 1) * VisualizerConfig.barSpacing

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
    Item {
        id: content

        anchors.fill: parent
        opacity: window.isOpen ? VisualizerConfig.visibleOpacity : VisualizerConfig.hiddenOpacity

        Behavior on opacity {
            NumberAnimation {
                duration: VisualizerConfig.contentFadeAnimMs
                easing.type: Easing.OutCubic

                onRunningChanged: {
                    if (!running && !window.isOpen && content.opacity === 0)
                        window.closed();
                }
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
