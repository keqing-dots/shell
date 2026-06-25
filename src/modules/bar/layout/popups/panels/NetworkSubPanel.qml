pragma ComponentBehavior: Bound

import QtQuick

import qs.components
import qs.service
import qs.modules.bar
import qs.modules.bar.layout.components
import qs.modules.bar.service
import qs.config

WidgetPanel {
    id: subRoot

    property string mode: ""
    property string ssid: ""

    clip: true
    implicitHeight: inner.implicitHeight + 2 * BarConfig.panelPadding
    implicitWidth: 320

    onModeChanged: {
        if (mode === "password")
            Qt.callLater(function () {
                pwdIn.clear();
                pwdIn.forceActiveFocus();
            });
    }

    MouseArea {
        anchors.fill: parent
    }
    Rectangle {
        id: closeBtn

        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.top: parent.top
        anchors.topMargin: 6
        color: closeBtnMa.containsMouse ? BarConfig.capsuleBgHover : BarConfig.capsuleBg
        height: 28
        radius: 6
        width: 28
        z: 1

        Text {
            anchors.centerIn: parent
            color: ColorConfig.text
            font.family: IconConfig.fontFamily
            font.pixelSize: FontConfig.fontSubPanelClose
            text: IconConfig.close
        }
        MouseArea {
            id: closeBtnMa

            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            onClicked: PanelService.closeSubPanel()
        }
    }
    Column {
        id: inner

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: BarConfig.panelPadding
        spacing: 6
        width: parent.width - 2 * BarConfig.panelPadding

        // Password
        Column {
            spacing: 6
            visible: subRoot.mode === "password"
            width: parent.width

            Text {
                color: ColorConfig.text
                elide: Text.ElideRight
                font.family: FontConfig.fontFamily
                font.pixelSize: BarConfig.fontSize - 1
                horizontalAlignment: Text.AlignHCenter
                text: "Password for \"" + subRoot.ssid + "\""
                width: parent.width
            }
            PasswordInput {
                id: pwdIn

                border.color: pwdIn.fieldActiveFocus ? ColorConfig.accent : ColorConfig.textAlpha15
                border.width: 1
                color: ColorConfig.textAlpha08
                fontSize: BarConfig.fontSize
                height: 28
                placeholder: "Password…"
                radius: 6
                selectByMouse: true
                width: parent.width

                onAccepted: {
                    if (text.length >= 8) {
                        NetworkService.connect(subRoot.ssid, text);
                        pwdIn.clear();
                        PanelService.closeSubPanel();
                    }
                }
            }
            Item {
                height: 28
                width: parent.width

                Rectangle {
                    id: pwdOk

                    anchors.horizontalCenter: parent.horizontalCenter
                    color: pwdOkMa.containsMouse ? Qt.lighter(ColorConfig.accent, 1.2) : ColorConfig.accent
                    height: 28
                    opacity: pwdIn.text.length >= 8 ? 1.0 : 0.4
                    radius: 6
                    width: pwdOkLabel.implicitWidth + 16

                    Text {
                        id: pwdOkLabel

                        anchors.centerIn: parent
                        color: "white"
                        font.family: FontConfig.fontFamily
                        font.pixelSize: BarConfig.fontSize - 1
                        text: "Connect"
                    }
                    MouseArea {
                        id: pwdOkMa

                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onClicked: {
                            if (pwdIn.text.length >= 8) {
                                NetworkService.connect(subRoot.ssid, pwdIn.text);
                                pwdIn.clear();
                                PanelService.closeSubPanel();
                            }
                        }
                    }
                }
            }
        }

        // Forget
        Column {
            spacing: 6
            visible: subRoot.mode === "forget"
            width: parent.width

            Text {
                color: "#F44747"
                elide: Text.ElideRight
                font.family: FontConfig.fontFamily
                font.pixelSize: BarConfig.fontSize - 1
                horizontalAlignment: Text.AlignHCenter
                text: "Forget \"" + subRoot.ssid + "\"?"
                width: parent.width
            }
            Item {
                height: 28
                width: parent.width

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6

                    Rectangle {
                        id: fOk

                        color: fOkMa.containsMouse ? Qt.rgba(1, 0.27, 0.27, 0.45) : Qt.rgba(1, 0.27, 0.27, 0.25)
                        height: 28
                        radius: 6
                        width: fOkLabel.implicitWidth + 16

                        Text {
                            id: fOkLabel

                            anchors.centerIn: parent
                            color: "#F44747"
                            font.family: FontConfig.fontFamily
                            font.pixelSize: BarConfig.fontSize - 1
                            text: "Forget"
                        }
                        MouseArea {
                            id: fOkMa

                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true

                            onClicked: {
                                NetworkService.forget(subRoot.ssid);
                                PanelService.closeSubPanel();
                            }
                        }
                    }
                    Rectangle {
                        id: fCancel

                        color: fCancelMa.containsMouse ? BarConfig.capsuleBgHover : BarConfig.capsuleBg
                        height: 28
                        radius: 6
                        width: fCancelLabel.implicitWidth + 16

                        Text {
                            id: fCancelLabel

                            anchors.centerIn: parent
                            color: ColorConfig.text
                            font.family: FontConfig.fontFamily
                            font.pixelSize: BarConfig.fontSize - 1
                            text: "Cancel"
                        }
                        MouseArea {
                            id: fCancelMa

                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true

                            onClicked: PanelService.closeSubPanel()
                        }
                    }
                }
            }
        }
    }
}
