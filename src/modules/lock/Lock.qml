pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Pam
import Quickshell.Wayland

import qs.modules.lock
import qs.modules.lock.layout

Scope {
    id: root

    property alias controller: controller

    signal closeRequested

    Item {
        id: controller

        property string password: ""

        function authenticate(pass) {
            password = pass;
            pam.start();
        }
        function close() {
            sessionLock.beginUnlock();
        }
        function open() {
            sessionLock.locked = true;
        }

        PamContext {
            id: pam

            config: GlobalConfig.pamConfigFile
            configDirectory: GlobalConfig.pamConfigDir

            onCompleted: result => {
                if (result === PamResult.Success) {
                    sessionLock.beginUnlock();
                } else {
                    controller.password = "";
                    sessionLock.failed = true;
                }
            }
            onPamMessage: {
                if (this.responseRequired)
                    this.respond(controller.password);
            }
        }
    }
    WlSessionLock {
        id: sessionLock

        property bool animDoneEmitted: false
        property bool failed: false
        property bool unlocking: false

        function beginUnlock() {
            unlocking = true;
            animDoneEmitted = false;
        }

        LockSurface {
            sessionLock: sessionLock

            onAuthenticate: pass => controller.authenticate(pass)
            onCloseRequested: root.closeRequested()
        }
    }
}
