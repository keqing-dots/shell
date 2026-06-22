pragma ComponentBehavior: Bound

import QtQuick

import qs.modules.wallpaper
import qs.styles

Rectangle {
    id: dirBar

    property string currentDir: ""
    property bool scanning: false

    signal dirChangeRequested(string path)
    signal escapePressed

    function resetDir() {
        dirInput.text = dirBar.currentDir;
    }

    border.color: GlobalConfig.accent
    border.width: dirInput.activeFocus ? GlobalConfig.borderWidthThin : 0
    color: GlobalConfig.fieldBg
    height: WallpaperConfig.dirBarHeight
    radius: GlobalConfig.radiusSm + 3

    Component.onCompleted: dirInput.text = dirBar.currentDir
    onCurrentDirChanged: {
        if (!dirInput.activeFocus)
            dirInput.text = dirBar.currentDir;
    }

    Text {
        id: dirLabel

        anchors.left: parent.left
        anchors.leftMargin: WallpaperConfig.dirLabelLeftMargin
        anchors.verticalCenter: parent.verticalCenter
        color: GlobalConfig.accent
        font.bold: true
        font.family: GlobalConfig.fontFamily
        font.pixelSize: GlobalConfig.fontPixelSmaller
        text: "Dir"
    }
    TextInput {
        id: dirInput

        anchors.left: dirLabel.right
        anchors.leftMargin: WallpaperConfig.dirInputLeftMargin
        anchors.right: rescanBtn.left
        anchors.rightMargin: WallpaperConfig.dirEdgeMargin
        anchors.verticalCenter: parent.verticalCenter
        clip: true
        color: GlobalConfig.text
        font.family: GlobalConfig.fontFamily
        font.pixelSize: GlobalConfig.fontPixelSmall
        selectByMouse: true

        Keys.onEscapePressed: dirBar.escapePressed()
        Keys.onReturnPressed: dirBar.dirChangeRequested(dirInput.text.trim())
    }
    Rectangle {
        id: rescanBtn

        anchors.right: parent.right
        anchors.rightMargin: WallpaperConfig.dirEdgeMargin
        anchors.verticalCenter: parent.verticalCenter
        color: rescanArea.containsMouse ? GlobalConfig.accent : Qt.rgba(1, 1, 1, 0.08)
        height: WallpaperConfig.dirBtnHeight
        radius: GlobalConfig.radiusSm
        width: WallpaperConfig.dirBtnWidth

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }

        Text {
            anchors.centerIn: parent
            color: GlobalConfig.text
            font.family: GlobalConfig.fontFamily
            font.pixelSize: GlobalConfig.fontPixelSmaller
            text: dirBar.scanning ? "…" : "Rescan"
        }
        MouseArea {
            id: rescanArea

            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            enabled: !dirBar.scanning
            hoverEnabled: true

            onClicked: dirBar.dirChangeRequested(dirInput.text.trim())
        }
    }
}
