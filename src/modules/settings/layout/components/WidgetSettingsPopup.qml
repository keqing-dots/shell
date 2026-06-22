pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.lib.service
import qs.modules.logout
import qs.modules.settings
import qs.styles

Popup {
    id: root

    property int currentIndex: -1
    property string currentWidgetId: ""
    property string editArrowSide: "right"
    property string editCommand: ""
    property string editDirection: "rtl"
    property string editFormat: ""
    property bool editHidePassive: false
    property string editIcon: ""
    property var editPowerButtons: []
    property bool editStartExpanded: false
    property string screenName: "default"
    property string section: ""

    function expandUnicode(s) {
        s = s.replace(/\\u\{([0-9a-fA-F]+)\}/gi, function (_, hex) {
            return String.fromCodePoint(parseInt(hex, 16));
        });
        s = s.replace(/\\u([0-9a-fA-F]{4})/gi, function (_, hex) {
            return String.fromCodePoint(parseInt(hex, 16));
        });
        return s;
    }
    function openForCard(index, config) {
        currentIndex = index;
        currentWidgetId = config.id || "";
        editIcon = config.icon || "";
        editCommand = (config.runCommand || []).join(" ");
        editFormat = config.format || "";
        editStartExpanded = config.startExpanded === true;
        editArrowSide = config.arrowSide || "right";
        editDirection = config.direction || (editArrowSide === "right" ? "rtl" : "ltr");
        editHidePassive = config.hidePassive === true;
        if (config.id === "Power") {
            var saved = SettingsService.powerButtons;
            var src = (saved && saved.length > 0) ? saved : LogoutConfig.actionsChars.map(function (c, i) {
                return {
                    char: c,
                    cmd: LogoutConfig.actionsCommands[i] || ""
                };
            });
            editPowerButtons = src.map(function (b) {
                return {
                    char: b.char || "",
                    cmd: b.cmd || ""
                };
            });
        }
        open();
    }
    function save() {
        var id = root.currentWidgetId;
        if (id === "Power") {
            var powerArr = [];
            for (var j = 0; j < powerRepeater.count; j++) {
                var item = powerRepeater.itemAt(j);
                if (item)
                    powerArr.push({
                        char: root.editPowerButtons[j]?.char || "",
                        cmd: item.cmdValue
                    });
            }
            SettingsService.setPowerButtons(powerArr);
            return;
        }
        var all = SettingsService.allWidgets;
        var screenEntry = all[root.screenName] || all["default"] || SettingsService._defaultWidgets;
        var a = screenEntry[root.section] ? screenEntry[root.section].slice() : [];
        var entry = {
            "id": id
        };
        if (id === "Custom") {
            if (root.editIcon)
                entry.icon = expandUnicode(root.editIcon);
            var parts = root.editCommand.trim().split(/\s+/).filter(function (s) {
                return s.length > 0;
            });
            if (parts.length > 0)
                entry.runCommand = parts;
        } else if (id === "Clock") {
            if (root.editFormat)
                entry.format = root.editFormat;
        } else if (id === "Tray") {
            entry.startExpanded = root.editStartExpanded;
            if (root.editArrowSide !== "right")
                entry.arrowSide = root.editArrowSide;
            var defaultDir = root.editArrowSide === "right" ? "rtl" : "ltr";
            if (root.editDirection !== defaultDir)
                entry.direction = root.editDirection;
            if (root.editHidePassive)
                entry.hidePassive = true;
        }
        a[root.currentIndex] = entry;
        SettingsService.setWidgets(root.screenName, root.section, a);
    }

    anchors.centerIn: Overlay.overlay
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    dim: false
    focus: true
    modal: true
    padding: 12
    width: root.currentWidgetId === "Power" ? 360 : 260

    background: Rectangle {
        border.color: GlobalConfig.textAlpha14
        border.width: 1
        color: GlobalConfig.overlay
        radius: 6
    }
    contentItem: Column {
        id: contentCol

        spacing: 10
        width: root.availableWidth

        Text {
            color: GlobalConfig.text
            font.family: GlobalConfig.fontFamily
            font.pixelSize: GlobalConfig.fontPixelSmaller
            font.weight: Font.DemiBold
            opacity: 0.55
            text: root.currentWidgetId + " settings"
        }
        Rectangle {
            color: GlobalConfig.textAlpha08
            height: 1
            width: contentCol.width
        }
        Column {
            spacing: 8
            visible: root.currentWidgetId === "Custom"
            width: contentCol.width

            Column {
                spacing: 4
                width: parent.width

                Text {
                    color: GlobalConfig.text
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontPixelSmaller
                    opacity: 0.5
                    text: "Icon"
                }
                Rectangle {
                    border.color: iconField.activeFocus ? GlobalConfig.accent : GlobalConfig.textAlpha15
                    border.width: 1
                    clip: true
                    color: GlobalConfig.textAlpha07
                    height: 26
                    radius: 4
                    width: parent.width

                    Behavior on border.color {
                        ColorAnimation {
                            duration: GlobalConfig.animationFast
                        }
                    }

                    TextInput {
                        id: iconField

                        anchors.fill: parent
                        anchors.margins: 6
                        color: GlobalConfig.text
                        font.family: GlobalConfig.fontFamily
                        font.pixelSize: GlobalConfig.fontPixelSmaller
                        text: root.editIcon

                        onTextChanged: root.editIcon = text
                    }
                }
            }
            Column {
                spacing: 4
                width: parent.width

                Text {
                    color: GlobalConfig.text
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontPixelSmaller
                    opacity: 0.5
                    text: "Command"
                }
                Rectangle {
                    border.color: cmdField.activeFocus ? GlobalConfig.accent : GlobalConfig.textAlpha15
                    border.width: 1
                    clip: true
                    color: GlobalConfig.textAlpha07
                    height: 26
                    radius: 4
                    width: parent.width

                    Behavior on border.color {
                        ColorAnimation {
                            duration: GlobalConfig.animationFast
                        }
                    }

                    TextInput {
                        id: cmdField

                        anchors.fill: parent
                        anchors.margins: 6
                        color: GlobalConfig.text
                        font.family: GlobalConfig.fontFamily
                        font.pixelSize: GlobalConfig.fontPixelSmaller
                        text: root.editCommand

                        onTextChanged: root.editCommand = text
                    }
                }
                Text {
                    color: GlobalConfig.text
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontPixelSmaller - 1
                    opacity: 0.3
                    text: "space-separated args"
                }
            }
        }
        Column {
            spacing: 4
            visible: root.currentWidgetId === "Clock"
            width: contentCol.width

            Text {
                color: GlobalConfig.text
                font.family: GlobalConfig.fontFamily
                font.pixelSize: GlobalConfig.fontPixelSmaller
                opacity: 0.5
                text: "Format"
            }
            Rectangle {
                border.color: fmtField.activeFocus ? GlobalConfig.accent : GlobalConfig.textAlpha15
                border.width: 1
                clip: true
                color: GlobalConfig.textAlpha07
                height: 26
                radius: 4
                width: parent.width

                Behavior on border.color {
                    ColorAnimation {
                        duration: GlobalConfig.animationFast
                    }
                }

                TextInput {
                    id: fmtField

                    anchors.fill: parent
                    anchors.margins: 6
                    color: GlobalConfig.text
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontPixelSmaller
                    text: root.editFormat

                    onTextChanged: root.editFormat = text
                }
            }
            Text {
                color: GlobalConfig.text
                font.family: GlobalConfig.fontFamily
                font.pixelSize: GlobalConfig.fontPixelSmaller - 1
                opacity: 0.3
                text: "e.g. ddd yyyy-MM-dd hh:mm:ss"
            }
        }
        Column {
            spacing: 8
            visible: root.currentWidgetId === "Tray"
            width: contentCol.width

            Row {
                spacing: 8
                width: parent.width

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    color: GlobalConfig.text
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontPixelSmaller
                    text: "Start expanded"
                    width: parent.width - 44
                }
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.editStartExpanded ? GlobalConfig.accent : GlobalConfig.textAlpha15
                    height: 20
                    radius: 10
                    width: 36

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        color: "white"
                        height: 14
                        radius: 7
                        width: 14
                        x: root.editStartExpanded ? parent.width - width - 3 : 3

                        Behavior on x {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: root.editStartExpanded = !root.editStartExpanded
                    }
                }
            }
            Column {
                spacing: 4
                width: parent.width

                Text {
                    color: GlobalConfig.text
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontPixelSmaller
                    opacity: 0.5
                    text: "Arrow side"
                }
                Row {
                    spacing: 4

                    Repeater {
                        model: ["left", "right"]

                        delegate: Rectangle {
                            id: arrowBtn

                            required property int index
                            required property string modelData

                            border.color: root.editArrowSide === arrowBtn.modelData ? GlobalConfig.accent : GlobalConfig.textAlpha15
                            border.width: 1
                            color: root.editArrowSide === arrowBtn.modelData ? GlobalConfig.accentAlpha18 : GlobalConfig.textAlpha07
                            height: 24
                            radius: 4
                            width: (contentCol.width - 4) / 2

                            Behavior on color {
                                ColorAnimation {
                                    duration: GlobalConfig.animationFast
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                color: root.editArrowSide === arrowBtn.modelData ? GlobalConfig.accent : GlobalConfig.text
                                font.family: GlobalConfig.fontFamily
                                font.pixelSize: GlobalConfig.fontPixelSmaller
                                opacity: root.editArrowSide === arrowBtn.modelData ? 1.0 : 0.6
                                text: arrowBtn.modelData.charAt(0).toUpperCase() + arrowBtn.modelData.slice(1)

                                Behavior on color {
                                    ColorAnimation {
                                        duration: GlobalConfig.animationFast
                                    }
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor

                                onClicked: root.editArrowSide = arrowBtn.modelData
                            }
                        }
                    }
                }
            }
            Column {
                spacing: 4
                width: parent.width

                Text {
                    color: GlobalConfig.text
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontPixelSmaller
                    opacity: 0.5
                    text: "Direction"
                }
                Row {
                    spacing: 4

                    Repeater {
                        model: ["ltr", "rtl"]

                        delegate: Rectangle {
                            id: dirBtn

                            required property int index
                            required property string modelData

                            border.color: root.editDirection === dirBtn.modelData ? GlobalConfig.accent : GlobalConfig.textAlpha15
                            border.width: 1
                            color: root.editDirection === dirBtn.modelData ? GlobalConfig.accentAlpha18 : GlobalConfig.textAlpha07
                            height: 24
                            radius: 4
                            width: (contentCol.width - 4) / 2

                            Behavior on color {
                                ColorAnimation {
                                    duration: GlobalConfig.animationFast
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                color: root.editDirection === dirBtn.modelData ? GlobalConfig.accent : GlobalConfig.text
                                font.family: GlobalConfig.fontFamily
                                font.pixelSize: GlobalConfig.fontPixelSmaller
                                opacity: root.editDirection === dirBtn.modelData ? 1.0 : 0.6
                                text: dirBtn.modelData.toUpperCase()

                                Behavior on color {
                                    ColorAnimation {
                                        duration: GlobalConfig.animationFast
                                    }
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor

                                onClicked: root.editDirection = dirBtn.modelData
                            }
                        }
                    }
                }
            }
            Row {
                spacing: 8
                width: parent.width

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    color: GlobalConfig.text
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontPixelSmaller
                    text: "Hide passive"
                    width: parent.width - 44
                }
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.editHidePassive ? GlobalConfig.accent : GlobalConfig.textAlpha15
                    height: 20
                    radius: 10
                    width: 36

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        color: "white"
                        height: 14
                        radius: 7
                        width: 14
                        x: root.editHidePassive ? parent.width - width - 3 : 3

                        Behavior on x {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: root.editHidePassive = !root.editHidePassive
                    }
                }
            }
        }
        Column {
            spacing: 6
            visible: root.currentWidgetId === "Power"
            width: contentCol.width

            Text {
                color: GlobalConfig.text
                font.family: GlobalConfig.fontFamily
                font.pixelSize: GlobalConfig.fontPixelSmaller
                opacity: 0.45
                text: "Command"
            }
            Repeater {
                id: powerRepeater

                model: root.editPowerButtons

                delegate: Item {
                    property string cmdValue: cmdField.text
                    required property int index
                    required property var modelData

                    height: 26
                    width: contentCol.width

                    RowLayout {
                        anchors.fill: parent
                        spacing: 8

                        Text {
                            Layout.preferredWidth: 24
                            color: GlobalConfig.text
                            font.family: GlobalConfig.fontFamily
                            font.pixelSize: GlobalConfig.fontPixelSmaller
                            horizontalAlignment: Text.AlignHCenter
                            opacity: 0.7
                            text: modelData.char
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            border.color: cmdField.activeFocus ? GlobalConfig.accent : GlobalConfig.textAlpha15
                            border.width: 1
                            clip: true
                            color: GlobalConfig.textAlpha07
                            height: 26
                            radius: 4

                            Behavior on border.color {
                                ColorAnimation {
                                    duration: GlobalConfig.animationFast
                                }
                            }

                            TextInput {
                                id: cmdField

                                anchors.fill: parent
                                anchors.margins: 6
                                color: GlobalConfig.text
                                font.family: GlobalConfig.fontFamily
                                font.pixelSize: GlobalConfig.fontPixelSmaller
                                text: modelData.cmd
                            }
                        }
                    }
                }
            }
        }
        Rectangle {
            color: saveArea.containsMouse ? GlobalConfig.accentAlpha25 : GlobalConfig.accentAlpha15
            height: 28
            radius: 4
            width: contentCol.width

            Behavior on color {
                ColorAnimation {
                    duration: GlobalConfig.animationFast
                }
            }

            Text {
                anchors.centerIn: parent
                color: GlobalConfig.accent
                font.family: GlobalConfig.fontFamily
                font.pixelSize: GlobalConfig.fontPixelSmaller
                text: "Save"
            }
            MouseArea {
                id: saveArea

                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true

                onClicked: root.save()
            }
        }
    }
    enter: Transition {
        NumberAnimation {
            duration: GlobalConfig.animationFast
            easing.type: Easing.OutCubic
            from: 0.0
            property: "opacity"
            to: 1.0
        }
    }
    exit: Transition {
        NumberAnimation {
            duration: GlobalConfig.animationFast
            easing.type: Easing.OutCubic
            from: 1.0
            property: "opacity"
            to: 0.0
        }
    }
}
