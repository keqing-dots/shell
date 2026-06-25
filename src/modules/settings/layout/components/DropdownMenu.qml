pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

import qs.components
import qs.modules.settings
import qs.config

Item {
    id: root

    readonly property string activeLabel: {
        var m = root.model;
        if (!m)
            return "—";
        for (var i = 0; i < m.length; i++) {
            var entry = m[i];
            if (typeof entry === "string") {
                if (entry === root.activeValue)
                    return entry;
            } else if ((entry[root.valueRole] ?? "") === root.activeValue) {
                return entry[root.labelRole] ?? "—";
            }
        }
        return "—";
    }
    property string activeValue: ""
    property Item anchor: null
    property bool captureKeyboard: root.triggerVisible
    property bool disabled: false
    property int highlightIndex: -1
    property string labelRole: "label"
    property var model: []
    property bool selfFont: false
    readonly property bool opened: menu.opened
    property bool triggerVisible: true
    property string valueRole: "value"

    signal itemSelected(string value)

    function close() {
        menu.close();
    }
    function open() {
        menu.open();
    }

    implicitHeight: root.triggerVisible ? 30 : 0
    implicitWidth: root.triggerVisible ? (triggerRow.implicitWidth + 20) : 0

    onVisibleChanged: {
        if (!visible)
            menu.close();
    }

    Rectangle {
        id: triggerRect

        readonly property bool open: menu.opened

        anchors.fill: parent
        border.color: open ? ColorConfig.accent : ColorConfig.textAlpha12
        border.width: 1
        color: open ? ColorConfig.accentAlpha12 : ColorConfig.textAlpha06
        opacity: root.disabled ? 0.4 : 1.0
        radius: GlobalConfig.radiusSm
        visible: root.triggerVisible

        Behavior on border.color {
            ColorAnimation {
                duration: 100
            }
        }
        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }

        Row {
            id: triggerRow

            anchors.centerIn: parent
            spacing: 6

            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: ColorConfig.text
                font.family: FontConfig.fontFamily
                font.pixelSize: FontConfig.fontSettingsBody
                text: root.activeLabel
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: ColorConfig.textDim
                font.family: IconConfig.fontFamily
                font.pixelSize: FontConfig.fontDropdownChevron
                text: triggerRect.open ? IconConfig.chevronUp : IconConfig.chevronDown
            }
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            enabled: !root.disabled

            onClicked: if (Date.now() - menu.closedAt > 100)
                menu.open()
        }
    }
    Popup {
        id: menu

        property real closedAt: 0

        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
        focus: root.captureKeyboard
        modal: false
        padding: 4
        parent: root.anchor ?? triggerRect
        width: Math.max((root.anchor ?? triggerRect).width, 120)
        x: (parent.width - width) / 2
        y: parent.height + 2

        background: Rectangle {
            border.color: ColorConfig.accent
            border.width: 1
            color: ColorConfig.overlay
            radius: GlobalConfig.radiusSm
        }
        contentItem: FocusScope {
            id: menuFocus

            implicitHeight: Math.min(menuCol.implicitHeight, 240)

            Keys.onDownPressed: event => {
                root.highlightIndex = Math.min(root.model.length - 1, root.highlightIndex + 1);
                event.accepted = true;
            }
            Keys.onEnterPressed: event => {
                if (root.highlightIndex >= 0 && root.highlightIndex < root.model.length) {
                    var entry = root.model[root.highlightIndex];
                    var val = typeof entry === "string" ? entry : (entry[root.valueRole] ?? "");
                    root.itemSelected(val);
                    menu.close();
                }
                event.accepted = true;
            }
            Keys.onEscapePressed: event => {
                menu.close();
                event.accepted = true;
            }
            Keys.onReturnPressed: event => {
                if (root.highlightIndex >= 0 && root.highlightIndex < root.model.length) {
                    var entry = root.model[root.highlightIndex];
                    var val = typeof entry === "string" ? entry : (entry[root.valueRole] ?? "");
                    root.itemSelected(val);
                    menu.close();
                }
                event.accepted = true;
            }
            Keys.onUpPressed: event => {
                root.highlightIndex = Math.max(0, root.highlightIndex - 1);
                event.accepted = true;
            }

            ScrollView {
                id: scrollView

                anchors.fill: parent
                clip: true

                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                Column {
                    id: menuCol

                    spacing: 2
                    width: scrollView.width

                    Repeater {
                        model: root.model

                        delegate: Rectangle {
                            id: optItem

                            required property int index
                            readonly property bool isActive: itemValue === root.activeValue
                            readonly property bool isHighlighted: index === root.highlightIndex
                            readonly property string itemLabel: typeof modelData === "string" ? modelData : (modelData[root.labelRole] ?? "")
                            readonly property string itemValue: typeof modelData === "string" ? modelData : (modelData[root.valueRole] ?? "")
                            required property var modelData

                            color: isHighlighted ? ColorConfig.accentAlpha15 : optArea.containsMouse ? ColorConfig.textAlpha07 : "transparent"
                            height: 26
                            radius: 3
                            width: parent.width

                            Behavior on color {
                                ColorAnimation {
                                    duration: 80
                                }
                            }

                            MarqueeText {
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                anchors.right: parent.right
                                anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                color: optItem.isActive || optItem.isHighlighted ? ColorConfig.accent : ColorConfig.text
                                fontBold: optItem.isActive
                                fontFamily: root.selfFont ? optItem.itemValue : FontConfig.fontFamily
                                fontSize: FontConfig.fontSettingsBody
                                running: optArea.containsMouse
                                text: optItem.itemLabel
                            }
                            MouseArea {
                                id: optArea

                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true

                                onClicked: {
                                    root.itemSelected(optItem.itemValue);
                                    menu.close();
                                }
                            }
                        }
                    }
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

        onAboutToHide: closedAt = Date.now()
        onClosed: {
            if (root.captureKeyboard)
                triggerRect.forceActiveFocus(Qt.PopupFocusReason);
        }
        onOpened: {
            if (!root.captureKeyboard)
                return;
            var m = root.model;
            root.highlightIndex = -1;
            for (var i = 0; i < m.length; i++) {
                var entry = m[i];
                var val = typeof entry === "string" ? entry : (entry[root.valueRole] ?? "");
                if (val === root.activeValue) {
                    root.highlightIndex = i;
                    break;
                }
            }
            menuFocus.forceActiveFocus();
        }
    }
}
