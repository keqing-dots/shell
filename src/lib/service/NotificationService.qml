pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell.Services.Notifications

QtObject {
    id: root

    property var _server: NotificationServer {
        actionsSupported: true
        imageSupported: true
        keepOnReload: false

        onNotification: notif => {
            for (var i = 0; i < root.popupModel.count; i++) {
                if (root.popupModel.get(i).notifId === notif.id) {
                    root.popupModel.set(i, root.makeEntry(notif));
                    root.notifObjs[notif.id] = notif;
                    return;
                }
            }
            root.popupModel.insert(0, root.makeEntry(notif));
            root.notifObjs[notif.id] = notif;
        }
    }
    property var notifObjs: ({})
    property ListModel popupModel: ListModel {}

    function finishDismiss(id) {
        for (var i = 0; i < popupModel.count; i++) {
            if (popupModel.get(i).notifId === id) {
                popupModel.remove(i);
                break;
            }
        }
        var n = notifObjs[id];
        if (n) {
            n.expire();
            delete notifObjs[id];
        }
    }
    function invokeAction(id, actionId) {
        var n = notifObjs[id];
        if (n)
            n.invokeAction(actionId);
        startDismiss(id);
    }
    function makeEntry(notif) {
        var ms = notif.expireTimeout;
        if (ms <= 0)
            ms = 5000;
        return {
            notifId: notif.id,
            appName: notif.appName || "",
            appIcon: notif.appIcon || "",
            summary: notif.summary || "",
            body: notif.body || "",
            urgency: notif.urgency,
            msTimeout: ms,
            removing: false
        };
    }
    function startDismiss(id) {
        for (var i = 0; i < popupModel.count; i++) {
            if (popupModel.get(i).notifId === id) {
                popupModel.setProperty(i, "removing", true);
                return;
            }
        }
    }
}
