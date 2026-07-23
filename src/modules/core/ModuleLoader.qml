pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root

    property string module: ""
    required property Component sourceComp

    function toggle() {
        if (loader.active) {
            if (loader.item && loader.item.controller) {
                loader.item.controller.close();
            }
        } else {
            loader.active = true;
        }
    }

    Loader {
        id: loader

        active: false
        asynchronous: false
        sourceComponent: root.sourceComp

        onActiveChanged: {
            if (!active)
                ModuleStates.setOpen(root.module, false);
        }
        onLoaded: {
            item.controller.open();
            ModuleStates.setOpen(root.module, true);
        }

        Connections {
            function onCloseRequested() {
                Qt.callLater(function () {
                    loader.active = false;
                });
            }

            ignoreUnknownSignals: true
            target: loader.item
        }
    }
}
