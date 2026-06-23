pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property Process applyColors: Process {
        command: ["apply-colors"]
    }
    readonly property string cacheDir: Quickshell.env("HOME") + "/.cache/keqing-shell/"
    property var colors: ({})
    readonly property string configDir: Quickshell.env("HOME") + "/.config/keqing-shell/"
    property var currentColors: ({
            accent: "#7B2FE8",
            accentAlt: "#C8942A",
            accentAltContainer: "#2B1D5C",
            accentContainer: "#3D1878",
            accentDim: "#5535B8",
            base: "#0A0614",
            fieldBg: "#0F1535",
            lavender: "#5E50A0",
            lavenderLight: "#C87EFF",
            overlay: "#1C1848",
            overlayAlt: "#252060",
            rose: "#7A4A58",
            surface: "#110B22",
            surfaceAlt: "#1A1238",
            text: "#F0ECF8",
            textMuted: "#A896C8"
        })
    property string mode: "default"
    property bool neonMode: false
    property Process proc: Process {
        property string targetScreen: ""

        stdout: StdioCollector {}

        onExited: code => root.onExited(code)
    }
    property FileView restoreView: FileView {
        path: root.configDir + "colors.json"
        printErrors: false
        watchChanges: false

        adapter: JsonAdapter {
            id: rd

            property var capture: ({})
            property var current: ({
                    accent: "#7B2FE8",
                    accentAlt: "#C8942A",
                    accentAltContainer: "#2B1D5C",
                    accentContainer: "#3D1878",
                    accentDim: "#5535B8",
                    base: "#0A0614",
                    fieldBg: "#0F1535",
                    lavender: "#5E50A0",
                    lavenderLight: "#C87EFF",
                    overlay: "#1C1848",
                    overlayAlt: "#252060",
                    rose: "#7A4A58",
                    surface: "#110B22",
                    surfaceAlt: "#1A1238",
                    text: "#F0ECF8",
                    textMuted: "#A896C8"
                })
            property string mode: "default"
        }

        onLoadFailed: {}
        onLoaded: {
            var cur = rd.current || {};
            root.currentColors = {
                accent: cur.accent ?? "#7B2FE8",
                accentAlt: cur.accentAlt ?? "#C8942A",
                accentAltContainer: cur.accentAltContainer ?? "#2B1D5C",
                accentContainer: cur.accentContainer ?? "#3D1878",
                accentDim: cur.accentDim ?? "#5535B8",
                base: cur.base ?? "#0A0614",
                fieldBg: cur.fieldBg ?? "#0F1535",
                lavender: cur.lavender ?? "#5E50A0",
                lavenderLight: cur.lavenderLight ?? "#C87EFF",
                overlay: cur.overlay ?? "#1C1848",
                overlayAlt: cur.overlayAlt ?? "#252060",
                rose: cur.rose ?? "#7A4A58",
                surface: cur.surface ?? "#110B22",
                surfaceAlt: cur.surfaceAlt ?? "#1A1238",
                text: cur.text ?? "#F0ECF8",
                textMuted: cur.textMuted ?? "#A896C8"
            };
            root.mode = rd.mode;
            if (rd.capture && typeof rd.capture === "object") {
                root.colors = rd.capture;
                var st = {};
                Object.keys(rd.capture).forEach(function (screen) {
                    st[screen] = "ready";
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
    property FileView writer: FileView {
        adapter: JsonAdapter {
            id: wr

            property var capture: ({})
            property var current: ({})
            property string mode: ""
        }
    }

    function applyDefault() {
        root.currentColors = {
            accent: "#7B2FE8",
            accentAlt: "#C8942A",
            accentAltContainer: "#2B1D5C",
            accentContainer: "#3D1878",
            accentDim: "#5535B8",
            base: "#0A0614",
            fieldBg: "#0F1535",
            lavender: "#5E50A0",
            lavenderLight: "#C87EFF",
            overlay: "#1C1848",
            overlayAlt: "#252060",
            rose: "#7A4A58",
            surface: "#110B22",
            surfaceAlt: "#1A1238",
            text: "#F0ECF8",
            textMuted: "#A896C8"
        };
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
        var s = Object.assign({}, root.status);
        s[screen] = "loading";
        root.status = s;
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
        var st = Object.assign({}, root.status);
        st[screenName] = "idle";
        root.status = st;
        var c = Object.assign({}, root.colors);
        delete c[screenName];
        root.colors = c;
    }
    function onExited(code) {
        var screen = proc.targetScreen;
        if (code === 0) {
            try {
                var data = JSON.parse(proc.stdout.text);
                var c = data.colors;
                var scheme = {
                    base: c.color0,
                    surface: c.color1,
                    surfaceAlt: c.color2,
                    accentAltContainer: c.color3,
                    accentContainer: c.color4,
                    lavender: c.color5,
                    rose: c.color6,
                    textMuted: c.color7,
                    fieldBg: c.color8,
                    overlay: c.color9,
                    overlayAlt: c.color10,
                    accentAlt: c.color11,
                    accentDim: c.color12,
                    accent: c.color13,
                    lavenderLight: c.color14,
                    text: c.color15
                };
                var updated = Object.assign({}, root.colors);
                updated[screen] = scheme;
                root.colors = updated;
                var st = Object.assign({}, root.status);
                st[screen] = "ready";
                root.status = st;
                if (screen === root.selectedScreen && root.mode === "capture")
                    applySelected();
            } catch (e) {
                setError(screen);
            }
        } else {
            setError(screen);
        }
    }
    function saveAll() {
        wr.current = root.currentColors;
        wr.capture = root.colors;
        wr.mode = root.mode;
        writer.path = root.configDir + "colors.json";
        writer.writeAdapter();
        applyColors.running = false;
        applyColors.running = true;
    }
    function setError(screen) {
        var st = Object.assign({}, root.status);
        st[screen] = "error";
        root.status = st;
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
