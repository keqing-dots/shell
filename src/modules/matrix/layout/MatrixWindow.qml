pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import KeqingShell.Matrix

import qs.config
import qs.modules.matrix

FloatingWindow {
    id: window

    required property bool isOpen

    color: MatrixConfig.windowBackground
    implicitHeight: MatrixConfig.defaultWindowHeight
    implicitWidth: MatrixConfig.defaultWindowWidth
    visible: content.opacity > 0 || window.isOpen

    Item {
        id: content

        anchors.fill: parent
        opacity: window.isOpen ? MatrixConfig.visibleOpacity : MatrixConfig.hiddenOpacity

        Behavior on opacity {
            NumberAnimation {
                duration: MatrixConfig.contentFadeAnimMs
                easing.type: Easing.OutCubic

                onRunningChanged: {
                    if (!running && !window.isOpen && content.opacity === 0)
                        window.closed();
                }
            }
        }

        MatrixGrid {
            anchors.fill: parent
            boldChance: MatrixConfig.boldChance
            cellHeight: MatrixConfig.cellHeight
            cellWidth: MatrixConfig.cellWidth
            eraseDelayMaxFrac: MatrixConfig.eraseDelayMaxFrac
            eraseDelayMinFrac: MatrixConfig.eraseDelayMinFrac
            fadeStepsFrac: MatrixConfig.fadeStepsFrac
            fallIntervalMs: MatrixConfig.fallIntervalMs
            font.family: FontConfig.fontFamily
            font.pixelSize: MatrixConfig.fontPixelSize
            glyphFlickerChance: MatrixConfig.glyphFlickerChance
            glyphs: MatrixConfig.glyphPool
            headColor: ColorConfig.text
            respawnMaxFrac: MatrixConfig.respawnMaxFrac
            respawnMinFrac: MatrixConfig.respawnMinFrac
            running: window.isOpen
            sparkChance: MatrixConfig.sparkChance
            speedVarianceTicks: MatrixConfig.speedVarianceTicks
            sweepDurationMs: MatrixConfig.sweepDurationMs
            tailColor: ColorConfig.accent
        }
    }
}
