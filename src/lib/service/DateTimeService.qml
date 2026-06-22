pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

QtObject {
    property var _clock: SystemClock {
        precision: SystemClock.Seconds
    }
    readonly property var date: _clock.date
}
