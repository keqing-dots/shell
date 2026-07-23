pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io

Item {
    id: root

    property string module

    signal toggle

    IpcHandler {
        function toggle() {
            root.toggle();
        }

        target: root.module
    }
}
