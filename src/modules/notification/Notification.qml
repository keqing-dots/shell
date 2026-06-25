pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

import qs.lib.service
import qs.modules.notification
import qs.styles

Variants {
    model: Quickshell.screens

    delegate: Component {
        Scope {
            id: screenScope

            required property var modelData

            PanelWindow {
                id: root

                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "keqing-notifications"
                anchors.bottom: true
                anchors.right: true
                color: "transparent"
                implicitHeight: Math.max(1, stack.implicitHeight)
                implicitWidth: NotificationConfig.cardWidth
                margins.bottom: NotificationConfig.screenMargin
                margins.right: NotificationConfig.screenMargin
                screen: screenScope.modelData
                visible: DisplayService.showNotifications(screenScope.modelData) && NotificationService.popupModel.count > 0

                ColumnLayout {
                    id: stack

                    spacing: NotificationConfig.cardSpacing
                    width: NotificationConfig.cardWidth
                    x: 0
                    y: 0

                    Behavior on implicitHeight {
                        SpringAnimation {
                            damping: 0.4
                            epsilon: 0.01
                            spring: 2.0
                        }
                    }

                    Repeater {
                        model: NotificationService.popupModel

                        delegate: Item {
                            id: card

                            required property string appIcon
                            required property string appName
                            required property string body
                            property bool isDragging: false
                            property bool isHovered: false
                            required property int msTimeout
                            required property int notifId
                            property real opacityValue: 0.0
                            property real progress: 1.0
                            required property bool removing
                            property real slideOffset: 24
                            required property string summary
                            property bool swipeDismissing: false
                            property real swipeX: 0.0
                            property real timeLeft: msTimeout
                            required property var urgency
                            readonly property color urgencyColor: urgency === 2 ? "#e05555" : urgency === 0 ? ColorConfig.textMuted : ColorConfig.accent

                            Layout.fillWidth: true
                            Layout.preferredHeight: cardBg.implicitHeight
                            opacity: opacityValue

                            Behavior on opacityValue {
                                NumberAnimation {
                                    duration: NotificationConfig.animNormal
                                    easing.type: Easing.OutCubic
                                }
                            }
                            Behavior on slideOffset {
                                SpringAnimation {
                                    damping: 0.35
                                    epsilon: 0.01
                                    spring: 2.5
                                }
                            }
                            Behavior on swipeX {
                                enabled: !card.isDragging

                                NumberAnimation {
                                    duration: NotificationConfig.animNormal
                                    easing.type: Easing.OutCubic
                                }
                            }
                            transform: [
                                Translate {
                                    x: card.swipeX
                                    y: card.slideOffset
                                }
                            ]

                            Component.onCompleted: {
                                slideOffset = 0;
                                opacityValue = 1.0;
                            }
                            onRemovingChanged: {
                                if (!removing)
                                    return;
                                opacityValue = 0.0;
                                if (swipeDismissing) {
                                    swipeX = NotificationConfig.cardWidth + 20;
                                } else {
                                    swipeX = 0;
                                    slideOffset = 24;
                                }
                                exitTimer.start();
                            }

                            Timer {
                                id: exitTimer

                                interval: NotificationConfig.animNormal + 60

                                onTriggered: NotificationService.finishDismiss(card.notifId)
                            }
                            Timer {
                                interval: 100
                                repeat: true
                                running: card.msTimeout > 0 && !card.isHovered && !card.removing && card.timeLeft > 0

                                onTriggered: {
                                    card.timeLeft = Math.max(0, card.timeLeft - 100);
                                    card.progress = card.timeLeft / card.msTimeout;
                                    if (card.timeLeft <= 0)
                                        NotificationService.startDismiss(card.notifId);
                                }
                            }
                            Rectangle {
                                id: cardBg

                                border.color: NotificationConfig.cardBorder
                                border.width: NotificationConfig.cardBorderWidth
                                color: NotificationConfig.cardBg
                                implicitHeight: cardContent.implicitHeight + NotificationConfig.cardPadding * 2 + 8
                                radius: NotificationConfig.cardRadius
                                width: parent.width

                                Item {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    clip: true
                                    height: 2

                                    Rectangle {
                                        color: card.urgencyColor
                                        height: parent.height
                                        width: (parent.width - cardBg.radius * 2) * card.progress
                                        x: cardBg.radius

                                        Behavior on width {
                                            NumberAnimation {
                                                duration: 100
                                                easing.type: Easing.Linear
                                            }
                                        }
                                    }
                                }
                                Column {
                                    id: cardContent

                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 10
                                    width: parent.width - NotificationConfig.cardPadding - closeHitArea.width - 8
                                    x: NotificationConfig.cardPadding

                                    Row {
                                        spacing: 6
                                        width: parent.width

                                        Rectangle {
                                            anchors.verticalCenter: parent.verticalCenter
                                            color: card.urgencyColor
                                            height: 6
                                            radius: 3
                                            width: 6
                                        }
                                        Text {
                                            color: ColorConfig.text
                                            elide: Text.ElideRight
                                            font.family: FontConfig.fontFamily
                                            font.pixelSize: NotificationConfig.fontAppName
                                            font.weight: Font.Bold
                                            opacity: 0.65
                                            text: card.appName || "Notification"
                                            width: Math.min(implicitWidth, parent.width - 12)
                                        }
                                    }
                                    Text {
                                        color: ColorConfig.text
                                        elide: Text.ElideRight
                                        font.family: FontConfig.fontFamily
                                        font.pixelSize: NotificationConfig.fontSummary
                                        font.weight: Font.DemiBold
                                        maximumLineCount: 2
                                        text: card.summary
                                        visible: text.length > 0
                                        width: parent.width
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    }
                                    Text {
                                        color: ColorConfig.text
                                        elide: Text.ElideRight
                                        font.family: FontConfig.fontFamily
                                        font.pixelSize: NotificationConfig.fontBody
                                        maximumLineCount: 3
                                        opacity: 0.72
                                        text: card.body
                                        visible: text.length > 0
                                        width: parent.width
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    }
                                }
                                Item {
                                    id: closeHitArea

                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    height: 32
                                    width: 32

                                    Text {
                                        id: closeIcon

                                        anchors.centerIn: parent
                                        color: ColorConfig.text
                                        font.family: Icons.fontFamily
                                        font.pixelSize: FontConfig.fontNotificationClose
                                        opacity: closeHover.containsMouse ? 1.0 : 0.4
                                        text: Icons.close

                                        Behavior on opacity {
                                            NumberAnimation {
                                                duration: NotificationConfig.animFast
                                            }
                                        }
                                    }
                                    MouseArea {
                                        id: closeHover

                                        anchors.fill: parent
                                        hoverEnabled: true

                                        onClicked: NotificationService.startDismiss(card.notifId)
                                    }
                                }
                                HoverHandler {
                                    onHoveredChanged: card.isHovered = hovered
                                }
                                MouseArea {
                                    id: cardMouse

                                    property real pressX: 0

                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    anchors.fill: parent
                                    z: -1

                                    onCanceled: {
                                        card.isDragging = false;
                                        card.swipeX = 0;
                                    }
                                    onPositionChanged: mouse => {
                                        if (!card.isDragging || card.removing)
                                            return;
                                        var delta = mouse.x - pressX;
                                        if (delta > 0)
                                            card.swipeX = delta;
                                    }
                                    onPressed: mouse => {
                                        card.isDragging = true;
                                        pressX = mouse.x;
                                    }
                                    onReleased: mouse => {
                                        card.isDragging = false;
                                        if (mouse.button === Qt.RightButton) {
                                            NotificationService.startDismiss(card.notifId);
                                            return;
                                        }
                                        if (card.swipeX > 80) {
                                            card.swipeDismissing = true;
                                            NotificationService.startDismiss(card.notifId);
                                        } else if (card.swipeX > 0) {
                                            card.swipeX = 0;
                                        } else {
                                            NotificationService.invokeAction(card.notifId, "default");
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
