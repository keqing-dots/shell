pragma ComponentBehavior: Bound
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import Quickshell

import qs.modules.core

import qs.modules.bar
import qs.modules.launcher
import qs.modules.lock
import qs.modules.logout
import qs.modules.notification
import qs.modules.osd
import qs.modules.settings
import qs.modules.overview
import qs.modules.polkit
import qs.modules.visualizer
import qs.modules.wallpaper

ShellRoot {
    id: root

    // Eager-Loaded Modules
    Bar {}
    Notification {}
    OSD {}
    Polkit {}
    Visualizer {}
    Wallpaper {}

    // Lazy-Loaded Modules
    ModuleLoader {
        id: launcher

        sourceComp: Component {
            Launcher {}
        }
    }
    ModuleLoader {
        id: lock

        sourceComp: Component {
            Lock {}
        }
    }
    ModuleLoader {
        id: logout

        sourceComp: Component {
            Logout {}
        }
    }
    ModuleLoader {
        id: overview

        sourceComp: Component {
            Overview {}
        }
    }
    ModuleLoader {
        id: settings

        sourceComp: Component {
            Settings {}
        }
    }

    // IPC Handlers
    ModuleHandler {
        module: "launcher"

        onToggle: launcher.toggle()
    }
    ModuleHandler {
        module: "lock"

        onToggle: lock.toggle()
    }
    ModuleHandler {
        module: "logout"

        onToggle: logout.toggle()
    }
    ModuleHandler {
        module: "settings"

        onToggle: settings.toggle()
    }
    ModuleHandler {
        module: "overview"

        onToggle: overview.toggle()
    }
}
