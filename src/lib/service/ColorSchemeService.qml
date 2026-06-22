pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    readonly property string cacheDir: Quickshell.env("HOME") + "/.cache/keqing-shell/"
    property var colors: ({})
    readonly property string configDir: Quickshell.env("HOME") + "/.config/keqing-shell/"
    property var currentColors: ({
            accent: "#7B2FE8",
            accentAlt: "#C8942A",
            fieldBg: "#0F1535",
            base: "#12091E",
            surfaceAlt: "#1A1848",
            accentContainer: "#3D1878",
            accentAltContainer: "#6B4A18",
            lavender: "#C87EFF",
            textMuted: "#A896C8",
            text: "#F0ECF8"
        })
    property string customAccent: "#7B2FE8"
    property string customAccentAlt: "#C8942A"
    property string customAccentAltContainer: "#6B4A18"
    property string customAccentContainer: "#3D1878"
    property string customBase: "#12091E"
    property string customBg: "#0F1535"
    property string customLavender: "#C87EFF"
    property string customSurfaceAlt: "#1A1848"
    property string customText: "#F0ECF8"
    property string customTextMuted: "#A896C8"
    property string mode: "default"
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
                    accentAltContainer: "#6B4A18",
                    accentContainer: "#3D1878",
                    base: "#12091E",
                    fieldBg: "#0F1535",
                    lavender: "#C87EFF",
                    surfaceAlt: "#1A1848",
                    text: "#F0ECF8",
                    textMuted: "#A896C8"
                })
            property var custom: ({
                    accent: "#7B2FE8",
                    accentAlt: "#C8942A",
                    accentAltContainer: "#6B4A18",
                    accentContainer: "#3D1878",
                    base: "#12091E",
                    bg: "#0F1535",
                    lavender: "#C87EFF",
                    surfaceAlt: "#1A1848",
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
                fieldBg: cur.fieldBg ?? "#0F1535",
                base: cur.base ?? "#12091E",
                surfaceAlt: cur.surfaceAlt ?? "#1A1848",
                accentContainer: cur.accentContainer ?? "#3D1878",
                accentAltContainer: cur.accentAltContainer ?? "#6B4A18",
                lavender: cur.lavender ?? "#C87EFF",
                textMuted: cur.textMuted ?? "#A896C8",
                text: cur.text ?? "#F0ECF8"
            };
            var cus = rd.custom || {};
            root.customBg = cus.bg ?? "#0F1535";
            root.customAccent = cus.accent ?? "#7B2FE8";
            root.customAccentAlt = cus.accentAlt ?? "#C8942A";
            root.customBase = cus.base ?? "#12091E";
            root.customSurfaceAlt = cus.surfaceAlt ?? "#1A1848";
            root.customAccentContainer = cus.accentContainer ?? "#3D1878";
            root.customAccentAltContainer = cus.accentAltContainer ?? "#6B4A18";
            root.customLavender = cus.lavender ?? "#C87EFF";
            root.customTextMuted = cus.textMuted ?? "#A896C8";
            root.customText = cus.text ?? "#F0ECF8";
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
    property string schemeType: "scheme-tonal-spot"
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
            property var custom: ({})
            property string mode: ""
        }
    }

    function applyDefault() {
        root.currentColors = {
            accent: "#7B2FE8",
            accentAlt: "#C8942A",
            fieldBg: "#0F1535",
            base: "#12091E",
            surfaceAlt: "#1A1848",
            accentContainer: "#3D1878",
            accentAltContainer: "#6B4A18",
            lavender: "#C87EFF",
            textMuted: "#A896C8",
            text: "#F0ECF8"
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
        proc.command = ["matugen", "image", root.wallpapers[screen], "--json", "hex", "--source-color-index", "1", "-t", root.schemeType, "-m", "dark", "-q"];
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
                    accent: c.primary.dark.color,
                    accentAlt: c.tertiary.dark.color,
                    fieldBg: c.surface_container.dark.color,
                    base: c.surface.dark.color,
                    surfaceAlt: c.surface_container_high.dark.color,
                    accentContainer: c.primary_container.dark.color,
                    accentAltContainer: c.tertiary_container.dark.color,
                    lavender: c.secondary.dark.color,
                    textMuted: c.on_surface_variant.dark.color,
                    text: c.on_surface.dark.color
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
        wr.custom = {
            accent: root.customAccent,
            accentAlt: root.customAccentAlt,
            accentAltContainer: root.customAccentAltContainer,
            accentContainer: root.customAccentContainer,
            base: root.customBase,
            bg: root.customBg,
            lavender: root.customLavender,
            surfaceAlt: root.customSurfaceAlt,
            text: root.customText,
            textMuted: root.customTextMuted
        };
        wr.capture = root.colors;
        wr.mode = root.mode;
        writer.path = root.configDir + "colors.json";
        writer.writeAdapter();
    }
    function setCustomColors(bg, accent, accentAlt, base, surfaceAlt, accentContainer, accentAltContainer, lavender, textMuted, text) {
        root.customBg = bg;
        root.customAccent = accent;
        root.customAccentAlt = accentAlt;
        root.customBase = base;
        root.customSurfaceAlt = surfaceAlt;
        root.customAccentContainer = accentContainer;
        root.customAccentAltContainer = accentAltContainer;
        root.customLavender = lavender;
        root.customTextMuted = textMuted;
        root.customText = text;
        root.currentColors = {
            accent: accent,
            accentAlt: accentAlt,
            fieldBg: bg,
            base: base,
            surfaceAlt: surfaceAlt,
            accentContainer: accentContainer,
            accentAltContainer: accentAltContainer,
            lavender: lavender,
            textMuted: textMuted,
            text: text
        };
        saveAll();
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
        } else if (root.mode === "custom") {
            root.currentColors = {
                accent: root.customAccent,
                accentAlt: root.customAccentAlt,
                fieldBg: root.customBg,
                base: root.customBase,
                surfaceAlt: root.customSurfaceAlt,
                accentContainer: root.customAccentContainer,
                accentAltContainer: root.customAccentAltContainer,
                lavender: root.customLavender,
                textMuted: root.customTextMuted,
                text: root.customText
            };
            saveAll();
        }
    }
    onSchemeTypeChanged: {
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
