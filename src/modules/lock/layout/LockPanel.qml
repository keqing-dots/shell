pragma ComponentBehavior: Bound

import QtQuick

import qs.lib.layout
import qs.lib.service
import qs.modules.lock
import qs.styles

Rectangle {
    id: root

    required property bool failed
    readonly property int fullHeight: mainCol.implicitHeight + 2 * LockConfig.panelMargin

    // Full content size — evaluated at animation start (scale: 0 doesn't affect implicit size)
    readonly property int fullWidth: mainCol.implicitWidth + 2 * LockConfig.panelMargin

    // Compact square sized to wrap the lock icon
    readonly property int iconBoxSize: lockIcon.font.pixelSize + LockConfig.panelMargin * 4
    required property bool unlocking

    signal authenticate(string pass)
    signal failedReset
    signal unlockFinished

    border.color: GlobalConfig.accent
    border.width: LockConfig.bgBorderWidth
    clip: true
    color: LockConfig.panelBg
    implicitHeight: iconBoxSize
    implicitWidth: iconBoxSize
    radius: 20
    scale: 0

    Component.onCompleted: initAnim.start()
    onUnlockingChanged: if (root.unlocking)
        unlockAnim.start()

    Text {
        id: lockIcon

        anchors.centerIn: parent
        color: GlobalConfig.accent
        font.family: Icons.fontFamily
        font.pixelSize: 200
        opacity: 1
        text: Icons.lock
    }
    Column {
        id: mainCol

        anchors.centerIn: parent
        clip: true
        opacity: 0
        scale: 0

        // Clock
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"
            implicitHeight: dateTimeCol.implicitHeight
            implicitWidth: dateTimeCol.implicitWidth

            Column {
                id: dateTimeCol

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: GlobalConfig.text
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: LockConfig.fontTime
                    text: Qt.formatDateTime(DateTimeService.date, "hh:mm")
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: GlobalConfig.text
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: LockConfig.fontDate
                    text: Qt.formatDateTime(DateTimeService.date, "dddd, MMM dd yyyy")
                }
            }
        }
        Space {
            height: 30
        }

        // Avatar
        RoundImage {
            anchors.horizontalCenter: parent.horizontalCenter
            bgColor: GlobalConfig.fieldBg
            borderColor: GlobalConfig.accent
            borderWidth: LockConfig.profileBorderWidth
            implicitHeight: LockConfig.profileSize
            implicitWidth: LockConfig.profileSize
            source: GlobalConfig.userPfp
        }
        Space {
            height: 10
        }

        // Username
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: GlobalConfig.text
            font.family: GlobalConfig.fontFamily
            font.pixelSize: LockConfig.fontNormal
            text: GlobalConfig.user
        }
        Space {
            height: 20
        }

        // Password input
        PasswordInput {
            id: passwordField

            anchors.horizontalCenter: parent.horizontalCenter
            animFastMs: LockConfig.animFastMs
            animNormalMs: LockConfig.animNormalMs
            border.color: GlobalConfig.accent
            border.width: LockConfig.bgBorderWidth
            color: GlobalConfig.fieldBg
            dotContainerMargin: LockConfig.bgRadius
            dotSize: LockConfig.dotSize
            dotSlideOffset: LockConfig.dotSlideOffset
            failText: "Skill Issue"
            failed: root.failed
            focus: true
            fontSize: LockConfig.fontNormal
            height: LockConfig.inputHeight
            keepFocus: true
            radius: LockConfig.inputRadius
            width: LockConfig.inputWidth

            onAccepted: {
                root.authenticate(text);
                clear();
            }
            onTextChanged: root.failedReset()
        }
        Space {
            height: 20
        }

        // Motivational text
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: GlobalConfig.accentAlt
            font.family: GlobalConfig.fontFamily
            font.pixelSize: LockConfig.fontNormal
            text: "Come on. Enough procrastinating. Let's go."
        }
    }

    // Phase 1: panel + lock icon spin in together (full 360°, scale 0→1)
    // Phase 2: card expands, lock icon fades out, content scales/fades in
    SequentialAnimation {
        id: initAnim

        ParallelAnimation {
            NumberAnimation {
                duration: 500
                easing.overshoot: 0.6
                easing.type: Easing.OutBack
                from: 0
                property: "scale"
                target: root
                to: 1
            }
            NumberAnimation {
                duration: 500
                easing.type: Easing.InOutCubic
                from: 0
                property: "rotation"
                target: root
                to: 360
            }
        }
        ParallelAnimation {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
                property: "implicitWidth"
                target: root
                to: root.fullWidth
            }
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
                property: "implicitHeight"
                target: root
                to: root.fullHeight
            }
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
                property: "opacity"
                target: lockIcon
                to: 0
            }
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutCubic
                property: "opacity"
                target: mainCol
                to: 1
            }
            NumberAnimation {
                duration: 400
                easing.overshoot: 0.5
                easing.type: Easing.OutBack
                property: "scale"
                target: mainCol
                to: 1
            }
        }
    }

    // Reverse of initAnim: fade out content → restore icon, then spin + shrink panel
    SequentialAnimation {
        id: unlockAnim

        onFinished: root.unlockFinished()

        ParallelAnimation {
            NumberAnimation {
                duration: 350
                easing.type: Easing.InCubic
                property: "implicitWidth"
                target: root
                to: root.iconBoxSize
            }
            NumberAnimation {
                duration: 350
                easing.type: Easing.InCubic
                property: "implicitHeight"
                target: root
                to: root.iconBoxSize
            }
            NumberAnimation {
                duration: 250
                easing.type: Easing.InCubic
                property: "opacity"
                target: lockIcon
                to: 1
            }
            NumberAnimation {
                duration: 200
                easing.type: Easing.InCubic
                property: "opacity"
                target: mainCol
                to: 0
            }
            NumberAnimation {
                duration: 300
                easing.overshoot: 0.5
                easing.type: Easing.InBack
                property: "scale"
                target: mainCol
                to: 0
            }
        }
        ParallelAnimation {
            NumberAnimation {
                duration: 500
                easing.overshoot: 0.6
                easing.type: Easing.InBack
                property: "scale"
                target: root
                to: 0
            }
            NumberAnimation {
                duration: 500
                easing.type: Easing.InOutCubic
                from: 0
                property: "rotation"
                target: root
                to: -360
            }
        }
    }
}
