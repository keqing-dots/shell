pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    readonly property var defaults: ({
            accent: "#9B57F4",
            accentAlt: "#DBAA24",
            accentAltContainer: "#2A1957",
            accentContainer: "#3C1877",
            accentDim: "#693DC2",
            base: "#0A0614",
            fieldBg: "#170D30",
            lavender: "#806FBE",
            lavenderLight: "#CE8AFF",
            overlay: "#26164B",
            overlayAlt: "#2F1C5F",
            rose: "#C0547F",
            surface: "#120B23",
            surfaceAlt: "#1D113B",
            text: "#F0ECF9",
            textMuted: "#AB9DC8"
        })

    readonly property var colorNames: ["base", "surface", "surfaceAlt", "accentAltContainer", "accentContainer", "lavender", "rose", "textMuted", "fieldBg", "overlay", "overlayAlt", "accentAlt", "accentDim", "accent", "lavenderLight", "text"]

    property Process applyColors: Process {
        command: ["apply-colors"]
    }

    readonly property string cacheDir: Quickshell.env("HOME") + "/.cache/keqing-shell/"
    property var colors: ({})
    readonly property string configDir: Quickshell.env("HOME") + "/.config/keqing-shell/"
    property var currentColors: root.defaults
    property string mode: "default"
    property bool neonMode: false

    property Process proc: Process {
        property string targetScreen: ""

        stdout: StdioCollector {}

        onExited: code => root.onExited(code)
    }

    property FileView file: FileView {
        path: root.configDir + "colors.json"
        printErrors: false
        watchChanges: false

        adapter: JsonAdapter {
            id: json

            property var capture: ({})
            property var current: ({})
            property string mode: "default"
        }

        onLoadFailed: {}
        onLoaded: {
            root.currentColors = Object.assign({}, root.defaults, json.current || {});
            root.mode = json.mode;
            if (json.capture && typeof json.capture === "object") {
                root.colors = json.capture;
                var st = {};
                Object.keys(json.capture).forEach(s => {
                    st[s] = "ready";
                });
                root.status = st;
            }
        }
    }

    readonly property var screens: {
        var list = Object.keys(root.wallpapers).filter(s => s !== "HEADLESS" && root.wallpapers[s]);
        list.sort();
        return list;
    }
    readonly property var selectedColors: root.colors[root.selectedScreen] ?? null
    property string selectedScreen: ""
    readonly property string selectedStatus: root.status[root.selectedScreen] ?? "idle"
    property var status: ({})
    property var wallpapers: ({})
    property bool wallpapersLoaded: false

    function applyDefault() {
        root.currentColors = root.defaults;
        saveAll();
    }

    function applySelected() {
        var scheme = root.selectedColors;
        if (!scheme)
            return;
        root.currentColors = scheme;
        saveAll();
    }

    function extract() {
        if (root.mode !== "capture")
            return;
        var screen = root.selectedScreen;
        if (!screen || !root.wallpapers[screen])
            return;
        setStatus(screen, "loading");
        if (proc.running)
            proc.running = false;
        proc.targetScreen = screen;
        var cmd = ["hellwal", "-i", root.wallpapers[screen], "-j", "-d"];
        if (root.neonMode)
            cmd.push("-m");
        proc.command = cmd;
        proc.running = true;
    }

    function invalidate(screenName) {
        setStatus(screenName, "idle");
        var c = Object.assign({}, root.colors);
        delete c[screenName];
        root.colors = c;
    }

    function onExited(code) {
        var screen = proc.targetScreen;
        if (code === 0) {
            try {
                var c = JSON.parse(proc.stdout.text).colors;
                var scheme = {};
                root.colorNames.forEach((name, i) => {
                    scheme[name] = c["color" + i];
                });
                root.colors = Object.assign({}, root.colors, {
                    [screen]: scheme
                });
                setStatus(screen, "ready");
                if (screen === root.selectedScreen && root.mode === "capture")
                    applySelected();
            } catch (e) {
                setStatus(screen, "error");
            }
        } else {
            setStatus(screen, "error");
        }
    }

    function saveAll() {
        json.current = root.currentColors;
        json.capture = root.colors;
        json.mode = root.mode;
        file.writeAdapter();
        applyColors.running = false;
        applyColors.running = true;
    }

    function setStatus(screen, val) {
        root.status = Object.assign({}, root.status, {
            [screen]: val
        });
    }

    onModeChanged: {
        if (!root.wallpapersLoaded)
            return;
        if (root.mode === "default") {
            applyDefault();
        } else if (root.mode === "capture") {
            if (!root.selectedScreen && root.screens.length > 0)
                root.selectedScreen = root.screens[0];
            else if (root.selectedScreen && root.selectedStatus === "ready")
                applySelected();
            else if (root.selectedScreen)
                root.extract();
        }
    }

    onNeonModeChanged: {
        if (root.mode === "capture" && root.selectedScreen)
            root.extract();
    }

    onSelectedScreenChanged: {
        if (root.mode === "capture")
            root.extract();
    }

    onWallpapersLoadedChanged: {
        if (wallpapersLoaded && mode === "capture" && selectedScreen !== "" && selectedStatus === "idle")
            extract();
    }
}
