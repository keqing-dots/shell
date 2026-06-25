pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Polkit
import Quickshell.Wayland

import qs.lib.layout
import qs.modules.polkit
import qs.styles

Scope {
    id: root

    property var capturedFlow: null
    property string storedPassword: ""
    property bool submitted: false

    function cancelAndClose() {
        if (!root.capturedFlow)
            return;
        root.capturedFlow.cancelAuthenticationRequest();
        root.capturedFlow = null;
        root.storedPassword = "";
        root.submitted = false;
        passwordField.clear();
        panelAnim.stop();
        panelHideAnim.restart();
    }

    // Agent
    PolkitAgent {
        id: agent

        onAuthenticationRequestStarted: {
            root.capturedFlow = agent.flow;
            root.storedPassword = "";
            root.submitted = false;
            panelHideAnim.stop();
            window.visible = true;
            panelAnim.restart();
            passwordField.clear();
            passwordField.failed = false;
            passwordField.forceActiveFocus();
        }
    }

    // Flow
    Connections {
        function onAuthenticationFailed() {
            const flow = root.capturedFlow;
            root.capturedFlow = null;
            root.storedPassword = "";
            root.submitted = false;
            if (flow)
                flow.cancelAuthenticationRequest();
        }
        function onAuthenticationRequestCancelled() {
            root.capturedFlow = null;
            root.storedPassword = "";
            root.submitted = false;
            passwordField.clear();
            panelAnim.stop();
            if (!panelHideAnim.running)
                panelHideAnim.restart();
        }
        function onAuthenticationSucceeded() {
            root.capturedFlow = null;
            root.storedPassword = "";
            root.submitted = false;
            panelAnim.stop();
            if (!panelHideAnim.running)
                panelHideAnim.restart();
        }

        ignoreUnknownSignals: true
        target: root.capturedFlow
    }

    // Window
    PanelWindow {
        id: window

        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.layer: WlrLayer.Overlay
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        visible: false

        anchors {
            bottom: true
            left: true
            right: true
            top: true
        }

        // Panel
        Rectangle {
            id: panel

            anchors.centerIn: parent
            border.color: ColorConfig.accent
            border.width: PolkitConfig.borderWidth
            color: PolkitConfig.panelBg
            implicitHeight: content.implicitHeight + 2 * PolkitConfig.panelMargin
            implicitWidth: PolkitConfig.panelWidth
            radius: PolkitConfig.panelRadius
            scale: 0

            NumberAnimation {
                id: panelAnim

                duration: PolkitConfig.animMs
                easing.type: Easing.OutBack
                from: 0
                property: "scale"
                target: panel
                to: 1
            }
            NumberAnimation {
                id: panelHideAnim

                duration: PolkitConfig.animMs
                easing.type: Easing.InBack
                from: 1
                property: "scale"
                target: panel
                to: 0

                onFinished: window.visible = false
            }

            // Close
            Text {
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.top: parent.top
                anchors.topMargin: 12
                color: ColorConfig.textDim
                font.family: IconConfig.fontFamily
                font.pixelSize: FontConfig.fontPolkitClose
                text: IconConfig.close

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: root.cancelAndClose()
                }
            }
            Column {
                id: content

                anchors.centerIn: parent
                spacing: PolkitConfig.spacing
                width: PolkitConfig.inputWidth

                // Label
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: ColorConfig.textDim
                    font.family: FontConfig.fontFamily
                    font.pixelSize: FontConfig.fontPolkitLabel
                    text: "Authentication Required"
                }

                // Input
                PasswordInput {
                    id: passwordField

                    anchors.horizontalCenter: parent.horizontalCenter
                    border.color: ColorConfig.accent
                    border.width: PolkitConfig.borderWidth
                    color: ColorConfig.fieldBg
                    dotContainerMargin: PolkitConfig.dotMargin
                    dotSize: PolkitConfig.dotSize
                    dotSlideOffset: PolkitConfig.dotSlideOffset
                    height: PolkitConfig.inputHeight
                    keepFocus: window.visible
                    radius: PolkitConfig.inputRadius
                    width: PolkitConfig.inputWidth

                    Keys.onEscapePressed: root.cancelAndClose()
                    onAccepted: {
                        if (root.capturedFlow) {
                            root.storedPassword = text;
                            root.submitted = true;
                            root.capturedFlow.submit(text);
                        }
                        clear();
                        panelAnim.stop();
                        panelHideAnim.restart();
                    }
                }
            }
        }
    }
}
