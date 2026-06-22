pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root

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

        onLoaded: item.controller.open()

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
