pragma ComponentBehavior: Bound
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import Quickshell

import qs.modules.core

import qs.modules.bar
import qs.modules.controlcenter
import qs.modules.dock
import qs.modules.idle
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
    Dock {}
    Idle {}
    Notification {}
    OSD {}
    Polkit {}
    Wallpaper {}

    // Lazy-Loaded Modules
    ModuleLoader {
        id: controlcenter

        module: "controlcenter"

        sourceComp: Component {
            ControlCenter {}
        }
    }
    ModuleLoader {
        id: launcher

        module: "launcher"

        sourceComp: Component {
            Launcher {}
        }
    }
    ModuleLoader {
        id: lock

        module: "lock"

        sourceComp: Component {
            Lock {}
        }
    }
    ModuleLoader {
        id: logout

        module: "logout"

        sourceComp: Component {
            Logout {}
        }
    }
    ModuleLoader {
        id: overview

        module: "overview"

        sourceComp: Component {
            Overview {}
        }
    }
    ModuleLoader {
        id: settings

        module: "settings"

        sourceComp: Component {
            Settings {}
        }
    }
    ModuleLoader {
        id: visualizer

        module: "visualizer"

        sourceComp: Component {
            Visualizer {}
        }
    }

    // IPC Handlers
    ModuleHandler {
        module: "controlcenter"

        onToggle: controlcenter.toggle()
    }
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
    ModuleHandler {
        module: "visualizer"

        onToggle: visualizer.toggle()
    }
}
