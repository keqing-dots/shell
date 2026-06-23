pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import qs.modules.wallpaper

QtObject {
    id: root

    readonly property string cacheDir: Quickshell.env("HOME") + "/.cache/keqing-shell/"
    property FileView cacheView: FileView {
        id: cacheView

        printErrors: false
        watchChanges: false

        adapter: JsonAdapter {
            id: cacheAdapter

            property var color: ({})
            property string dir: ""
            property var fillModes: ({})
            property var wallpapers: ({})
        }

        onLoadFailed: root.scan(root.currentDir)
        onLoaded: {
            root.currentWallpapers = cacheAdapter.wallpapers || {};
            root.currentFillModes = cacheAdapter.fillModes || {};
            var col = cacheAdapter.color || {};
            root.colorSourceScreen = col.sourceScreen || "";
            root.neonMode = col.neonMode ?? false;
            if (cacheAdapter.dir !== "")
                root.currentDir = cacheAdapter.dir;
            if (root.colorSourceScreen === "") {
                var screens = Object.keys(root.currentWallpapers).filter(s => s !== "HEADLESS").sort();
                if (screens.length > 0)
                    root.colorSourceScreen = screens[0];
            }
            ColorSchemeService.wallpapers = root.currentWallpapers;
            ColorSchemeService.neonMode = root.neonMode;
            ColorSchemeService.selectedScreen = root.colorSourceScreen || "default";
            ColorSchemeService.wallpapersLoaded = true;
            root.scan(root.currentDir);
        }
    }
    property string colorSourceScreen: ""
    readonly property string configDir: Quickshell.env("HOME") + "/.config/keqing-shell/"
    property Connections cssSync: Connections {
        function onNeonModeChanged() {
            if (root.neonMode !== ColorSchemeService.neonMode) {
                root.neonMode = ColorSchemeService.neonMode;
                saveTimer.restart();
            }
        }
        function onSelectedScreenChanged() {
            if (root.colorSourceScreen !== ColorSchemeService.selectedScreen) {
                root.colorSourceScreen = ColorSchemeService.selectedScreen;
                saveTimer.restart();
            }
        }

        target: ColorSchemeService
    }
    property string currentDir: Quickshell.env("WALLPAPER_DIR") || (Quickshell.env("HOME") + "/Pictures")
    property var currentFillModes: ({})
    property var currentWallpapers: ({})
    property var imageFiles: []
    property Process mkdirProc: Process {
        id: mkdirProc

        command: ["mkdir", "-p", root.cacheDir]

        onExited: cacheView.path = root.configDir + "wallpapers.json"
    }
    property Timer saveTimer: Timer {
        id: saveTimer

        interval: 500
        repeat: false

        onTriggered: {
            cacheAdapter.wallpapers = root.currentWallpapers;
            cacheAdapter.fillModes = root.currentFillModes;
            cacheAdapter.dir = root.currentDir;
            cacheAdapter.color = {
                sourceScreen: root.colorSourceScreen,
                neonMode: root.neonMode
            };
            cacheView.writeAdapter();
        }
    }
    property Process scanProc: Process {
        id: scanProc

        property string scanDir: ""

        command: ["find", "-L", scanDir, "-maxdepth", "2", "-type", "f", "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.png", "-o", "-iname", "*.webp", "-o", "-iname", "*.gif", ")"]

        stdout: StdioCollector {}

        onExited: {
            root.scanning = false;
            var lines = scanProc.stdout.text.split('\n').filter(l => l.trim() !== '');
            root.imageFiles = lines.filter(f => /\.(jpg|jpeg|png|webp|gif)$/i.test(f));
        }
    }
    property bool scanning: false
    property bool neonMode: false

    signal wallpaperChanged(string screenName, string path)

    function removeWallpaper(screenName) {
        var updated = Object.assign({}, currentWallpapers);
        delete updated[screenName];
        currentWallpapers = updated;
        ColorSchemeService.wallpapers = root.currentWallpapers;
        ColorSchemeService.invalidate(screenName);
        saveTimer.restart();
        wallpaperChanged(screenName, "");
    }
    function scan(dir) {
        if (!dir)
            return;
        root.scanning = true;
        root.imageFiles = [];
        if (scanProc.running)
            scanProc.running = false;
        scanProc.scanDir = dir;
        scanProc.running = true;
    }
    function setColorSource(screen) {
        root.colorSourceScreen = screen;
        ColorSchemeService.selectedScreen = screen;
        saveTimer.restart();
    }
    function setDir(path) {
        if (!path)
            return;
        var expanded = path;
        if (expanded === "~")
            expanded = Quickshell.env("HOME");
        else if (expanded.startsWith("~/"))
            expanded = Quickshell.env("HOME") + expanded.slice(1);
        if (expanded === currentDir) {
            scan(currentDir);
            return;
        }
        currentDir = expanded;
        saveTimer.restart();
        scan(currentDir);
    }
    function setFillMode(screenName, mode) {
        var updated = Object.assign({}, currentFillModes);
        updated[screenName] = mode;
        currentFillModes = updated;
        saveTimer.restart();
    }
    function setNeonMode(enabled) {
        root.neonMode = enabled;
        ColorSchemeService.neonMode = enabled;
        saveTimer.restart();
    }
    function setWallpaper(screenName, path) {
        var updated = Object.assign({}, currentWallpapers);
        updated[screenName] = path;
        currentWallpapers = updated;
        ColorSchemeService.wallpapers = root.currentWallpapers;
        ColorSchemeService.invalidate(screenName);
        saveTimer.restart();
        wallpaperChanged(screenName, path);
        if (screenName === ColorSchemeService.selectedScreen)
            ColorSchemeService.extract();
    }

    Component.onCompleted: mkdirProc.running = true
}
