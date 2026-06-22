pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell.Wayland

import qs.lib.service
import qs.modules.lock
import qs.styles

WlSessionLockSurface {
    id: root

    required property WlSessionLock sessionLock

    signal authenticate(string pass)
    signal closeRequested

    // Wallpaper
    Rectangle {
        anchors.fill: parent
        color: "black"

        Image {
            anchors.fill: parent
            asynchronous: true
            fillMode: {
                switch ((WallpaperService.currentFillModes ?? {})[root.screen?.name ?? ""] ?? "crop") {
                case "fit":
                    return Image.PreserveAspectFit;
                case "stretch":
                    return Image.Stretch;
                case "tile":
                    return Image.Tile;
                default:
                    return Image.PreserveAspectCrop;
                }
            }
            opacity: status === Image.Ready ? 1.0 : 0.0
            smooth: true
            source: {
                var p = (WallpaperService.currentWallpapers ?? {})[root.screen?.name ?? ""];
                return p ? "file://" + p : "";
            }
            sourceSize: String(source).toLowerCase().endsWith(".svg") ? Qt.size(0, height) : Qt.size(width, height)

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    // Debug unlock
    Button {
        anchors.bottom: parent.bottom
        opacity: 0
        z: 100

        onClicked: root.sessionLock.beginUnlock()
    }

    // UI layer — hidden on displays where lock is disabled
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        opacity: {
            var sn = root.screen?.name ?? "";
            var sm = root.screen?.model ?? "";
            var d = SettingsService.displays;
            var entry = d[sn] !== undefined ? d[sn] : d[sm] !== undefined ? d[sm] : {};
            return entry["lock"] !== false ? 1 : 0;
        }

        LockPanel {
            anchors.centerIn: parent
            failed: root.sessionLock.failed
            unlocking: root.sessionLock.unlocking

            onAuthenticate: pass => root.authenticate(pass)
            onFailedReset: root.sessionLock.failed = false
            onUnlockFinished: {
                root.sessionLock.locked = false;
                if (!root.sessionLock.animDoneEmitted) {
                    root.sessionLock.animDoneEmitted = true;
                    root.closeRequested();
                }
            }
        }
        Timer {
            interval: LockConfig.timerFailMs
            running: root.sessionLock.failed

            onTriggered: root.sessionLock.failed = false
        }
    }
}
