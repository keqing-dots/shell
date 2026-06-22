pragma ComponentBehavior: Bound

import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import qs.lib.service
import qs.modules.logout
import qs.styles

Scope {
    id: root

    property alias controller: controller

    signal closeRequested

    // Controller
    Item {
        id: controller

        readonly property var chars: {
            var btns = SettingsService.powerButtons;
            if (btns && btns.length > 0)
                return btns.map(function (b) {
                    return b.char || "";
                });
            return LogoutConfig.actionsChars;
        }
        readonly property var command: {
            var btns = SettingsService.powerButtons;
            if (btns && btns.length > 0)
                return btns.map(function (b) {
                    return b.cmd || "";
                });
            return LogoutConfig.actionsCommands;
        }
        property bool isOpen: false

        signal executed(int index)

        function close(fast) {
            isOpen = false;
            if (fast === true) {
                animation.fastHide();
                root.closeRequested();
            } else {
                animation.start("out");
            }
        }
        function exec(index) {
            if (index === undefined || index === null)
                return;
            const i = Number(index);
            if (Number.isNaN(i) || i < 0 || i >= command.length)
                return;
            const cmd = command[i];
            if (!cmd || !cmd.trim())
                return;
            Quickshell.execDetached(["bash", "-c", cmd]);
            executed(i);
            close(true);
        }
        function open() {
            isOpen = true;
            animation.start("in");
        }
        function toggle() {
            if (isOpen)
                close(false);
            else
                open();
        }
    }

    // Window
    PanelWindow {
        id: window

        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.layer: WlrLayer.Overlay
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        visible: false

        onClosed: root.closeRequested()
        onVisibleChanged: {
            if (visible)
                keyHandler.forceActiveFocus();
        }

        anchors {
            bottom: true
            left: true
            right: true
            top: true
        }

        // Keyboard navigation
        Item {
            id: keyHandler

            property bool acceptInput: false

            Keys.enabled: window.visible
            Keys.priority: Keys.BeforeItem
            anchors.fill: parent
            focus: window.visible
            visible: window.visible

            Keys.onPressed: event => {
                if (!event)
                    return;
                event.accepted = true;
                if (!acceptInput)
                    return;
                let handled = true;
                switch (event.key) {
                case Qt.Key_Escape:
                    controller.close(false);
                    break;
                case Qt.Key_Left:
                    buttons.move(-1);
                    break;
                case Qt.Key_Right:
                    buttons.move(1);
                    break;
                case Qt.Key_Return:
                case Qt.Key_Enter:
                    buttons.exec(buttons.currentIndex);
                    break;
                default:
                    handled = false;
                }
                if (handled)
                    return;
                if (event.key >= Qt.Key_1 && event.key <= Qt.Key_8)
                    buttons.setIndex(event.key - Qt.Key_1);
                else
                    buttons.setIndex(0);
            }
        }

        //  Outside click dismiss
        MouseArea {
            acceptedButtons: Qt.LeftButton
            anchors.fill: parent
            enabled: window.visible
            hoverEnabled: true

            onClicked: {
                if (!buttons.containsMouse())
                    controller.close(false);
            }
        }

        // Buttons + logo
        Item {
            anchors.centerIn: parent

            Repeater {
                id: buttons

                property int currentIndex: 0
                property bool highlightEnabled: true
                property int size: LogoutConfig.buttonSize
                property real start: LogoutConfig.buttonsStartAngle
                property real step: LogoutConfig.buttonsStepAngle

                function containsMouse() {
                    for (var i = 0; i < children.length; ++i) {
                        var c = children[i];
                        if (c && c.click && c.click.containsMouse)
                            return true;
                    }
                    return false;
                }
                function exec(i) {
                    controller.exec(i);
                }
                function move(i) {
                    currentIndex = (currentIndex + i + model) % model;
                }
                function setIndex(i) {
                    currentIndex = i;
                }

                model: LogoutConfig.buttonsCount
                z: 1

                delegate: Button {
                    property bool isHighlighted: buttons.highlightEnabled && (highlighted || click.containsMouse)
                    property int radius: 0

                    function button(show) {
                        opacity = show ? 1 : 0;
                        radius = show ? LogoutConfig.buttonsExpandedRadius : 0;
                    }

                    height: buttons.size
                    highlighted: buttons.highlightEnabled && (index == buttons.currentIndex)
                    opacity: 0
                    scale: isHighlighted ? LogoutConfig.buttonHighlightScale : 1
                    width: buttons.size
                    x: radius * Math.cos(buttons.start + buttons.step * index) - buttons.size / 2
                    y: radius * Math.sin(buttons.start + buttons.step * index) - buttons.size / 2

                    background: Rectangle {
                        border.color: parent.isHighlighted ? GlobalConfig.accentAlt : GlobalConfig.accent
                        border.width: LogoutConfig.buttonBorderWidth
                        color: GlobalConfig.fieldBg
                        radius: buttons.size / LogoutConfig.buttonCornerRadiusDiv

                        Behavior on border.color {
                            ColorAnimation {
                                duration: LogoutConfig.buttonBorderAnimMs
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                    Behavior on opacity {
                        NumberAnimation {
                            duration: LogoutConfig.buttonOpacityAnimMs
                        }
                    }
                    Behavior on radius {
                        NumberAnimation {
                            duration: LogoutConfig.buttonRadiusAnimMs
                        }
                    }
                    Behavior on scale {
                        NumberAnimation {
                            duration: LogoutConfig.buttonScaleAnimMs
                            easing.type: Easing.OutCubic
                        }
                    }

                    MouseArea {
                        id: click

                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: mouse => {
                            if (mouse.button == Qt.LeftButton && keyHandler.acceptInput)
                                buttons.exec(index);
                        }
                    }
                    Text {
                        color: GlobalConfig.text
                        font.family: LogoutConfig.buttonCharFont
                        font.pixelSize: buttons.size / 2
                        text: controller.chars[index]
                        x: (parent.width - width) / 2
                        y: (parent.height - height) / 2
                    }
                }
            }
            Item {
                id: logo

                property real logoRadius: logoSize / 2
                property int logoSize: LogoutConfig.logoSize
                property url path: window.visible ? GlobalConfig.logoutLogo : ""
                property bool playing: true

                function reset() {
                    animImage.currentFrame = 0;
                    playing = true;
                }
                function stop() {
                    playing = false;
                }

                anchors.centerIn: parent
                height: logoSize
                scale: 0
                width: logoSize

                Rectangle {
                    anchors.fill: parent
                    border.color: GlobalConfig.accent
                    border.width: LogoutConfig.buttonBorderWidth
                    color: GlobalConfig.fieldBg
                    radius: logo.logoRadius
                }
                Item {
                    id: logoContent

                    anchors.fill: parent
                    anchors.margins: 4
                    visible: false

                    AnimatedImage {
                        id: animImage

                        anchors.fill: parent
                        cache: false
                        fillMode: Image.PreserveAspectCrop
                        playing: logo.playing
                        source: logo.path
                    }
                }
                Rectangle {
                    id: logoMask

                    anchors.fill: logoContent
                    antialiasing: true
                    radius: width / 2
                    visible: false
                }
                OpacityMask {
                    anchors.fill: logoContent
                    maskSource: logoMask
                    source: logoContent
                }
            }
        }

        // Animations
        Item {
            id: animation

            property string currentState: ""

            function fastHide() {
                stopIn();
                stopOut();
                window.visible = false;
                keyHandler.acceptInput = false;
                logo.scale = 0;
                resetButtons(false);
                currentState = "";
            }
            function resetButtons(toVisible) {
                for (let j = 0; j < buttons.count; ++j) {
                    buttons.itemAt(j).button(toVisible);
                }
            }
            function start(state) {
                if (state === currentState)
                    return;
                switch (state) {
                case "in":
                    stopOut();
                    startIn();
                    break;
                case "out":
                    stopIn();
                    startOut();
                    break;
                }
            }
            function startIn() {
                logo.scale = 0;
                resetButtons(false);
                buttons.highlightEnabled = false;
                buttons.setIndex(0);
                keyHandler.acceptInput = false;
                currentState = "in";
                allIn.start();
            }
            function startOut() {
                logo.scale = 1;
                buttons.highlightEnabled = false;
                resetButtons(true);
                keyHandler.acceptInput = false;
                currentState = "out";
                allOut.start();
            }
            function stopIn() {
                allIn.stop();
                buttonIn.stop();
                buttonIn.i = 0;
            }
            function stopOut() {
                allOut.stop();
                buttonOut.stop();
                buttonOut.i = buttons.count - 1;
            }

            Timer {
                id: buttonIn

                property int i: 0

                interval: LogoutConfig.buttonsStaggerMs
                repeat: true

                onTriggered: {
                    if (i < buttons.count) {
                        buttons.itemAt(i).button(true);
                        i++;
                    } else {
                        stop();
                        i = 0;
                    }
                }
            }
            Timer {
                id: buttonOut

                property int i: buttons.count - 1

                interval: LogoutConfig.buttonsStaggerMs
                repeat: true

                onTriggered: {
                    if (i >= 0) {
                        buttons.itemAt(i).button(false);
                        i--;
                    } else {
                        stop();
                        i = buttons.count - 1;
                    }
                }
            }
            SequentialAnimation {
                id: allIn

                running: false

                ScriptAction {
                    script: window.visible = true
                }
                ScriptAction {
                    script: logo.reset()
                }
                NumberAnimation {
                    duration: LogoutConfig.logoAnimMs
                    easing.type: Easing.OutBack
                    from: 0
                    properties: "scale"
                    target: logo
                    to: 1
                }
                ScriptAction {
                    script: buttonIn.start()
                }
                PauseAnimation {
                    duration: buttons.count * LogoutConfig.buttonsStaggerMs
                }
                ScriptAction {
                    script: {
                        buttons.highlightEnabled = true;
                        keyHandler.acceptInput = true;
                    }
                }
            }
            SequentialAnimation {
                id: allOut

                running: false

                ScriptAction {
                    script: keyHandler.acceptInput = false
                }
                ScriptAction {
                    script: buttonOut.start()
                }
                PauseAnimation {
                    duration: buttons.count * LogoutConfig.buttonsStaggerMs
                }
                NumberAnimation {
                    duration: LogoutConfig.logoAnimMs
                    easing.type: Easing.InBack
                    from: 1
                    properties: "scale"
                    target: logo
                    to: 0
                }
                ScriptAction {
                    script: {
                        window.visible = false;
                        animation.currentState = "";
                        logo.stop();
                        window.closed();
                    }
                }
            }
        }
    }
}
