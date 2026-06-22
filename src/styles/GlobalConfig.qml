pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

import qs.lib.service

QtObject {
    id: root

    // Colors — live-bound to ColorSchemeService; updated by every extraction,
    // manual ThemeTab pick, and startup restore from colors.json.

    // Primary — deep violet overcoat
    property color accent: ColorSchemeService.currentColors.accent
    readonly property color accentAlpha12: Qt.rgba(accent.r, accent.g, accent.b, 0.12)
    readonly property color accentAlpha15: Qt.rgba(accent.r, accent.g, accent.b, 0.15)
    readonly property color accentAlpha18: Qt.rgba(accent.r, accent.g, accent.b, 0.18)
    readonly property color accentAlpha20: Qt.rgba(accent.r, accent.g, accent.b, 0.20)
    readonly property color accentAlpha25: Qt.rgba(accent.r, accent.g, accent.b, 0.25)

    // Secondary — gold ornaments
    property color accentAlt: ColorSchemeService.currentColors.accentAlt
    property color accentAltContainer: ColorSchemeService.currentColors.accentAltContainer
    property color accentContainer: ColorSchemeService.currentColors.accentContainer

    // Animation
    readonly property int animationFast: 150
    readonly property int animationNormal: 220
    property color base: ColorSchemeService.currentColors.base
    readonly property color baseAlpha45: Qt.rgba(base.r, base.g, base.b, 0.45)

    // Sizing
    readonly property int borderWidthThick: 4
    readonly property int borderWidthThin: 2
    readonly property var comicShannsLoader: FontLoader {
        source: Qt.resolvedUrl("assets/fonts/ComicShannsMonoNerdFont-Regular.otf")
    }

    // Assets
    readonly property url defaultWallpaper: source("assets/default_wp.svg")

    // Fixed — Electro Vision lore color, not wallpaper-derived
    readonly property color electro: "#9D3EF2"

    // Surfaces — dark blue skirt → near-black gloves
    property color fieldBg: ColorSchemeService.currentColors.fieldBg

    // Typography
    readonly property string fontFamily: comicShannsLoader.name
    readonly property int fontPixelSmall: 15
    readonly property int fontPixelSmaller: 15
    readonly property url inputEcho: source("assets/pwdelegate/1.png")

    // Lavender — pale inner top
    property color lavender: ColorSchemeService.currentColors.lavender
    readonly property color lavenderAlpha20: Qt.rgba(lavender.r, lavender.g, lavender.b, 0.20)
    readonly property color lavenderAlpha35: Qt.rgba(lavender.r, lavender.g, lavender.b, 0.35)

    // Derived — reactive to palette, not individually extracted
    readonly property color lavenderSubtle: Qt.rgba(lavender.r, lavender.g, lavender.b, 0.15)
    readonly property url logoutLogo: source("assets/gifs/logoutlogo.gif")
    readonly property color overlay: Qt.rgba(base.r, base.g, base.b, 0.92)
    readonly property int radiusMd: 10
    readonly property int radiusSm: 5
    property color surfaceAlt: ColorSchemeService.currentColors.surfaceAlt

    // Text — on_surface, adapts with wallpaper
    property color text: ColorSchemeService.currentColors.text

    // Alpha tints — precomputed for use throughout the shell
    readonly property color textAlpha03: Qt.rgba(text.r, text.g, text.b, 0.03)
    readonly property color textAlpha04: Qt.rgba(text.r, text.g, text.b, 0.04)
    readonly property color textAlpha05: Qt.rgba(text.r, text.g, text.b, 0.05)
    readonly property color textAlpha06: Qt.rgba(text.r, text.g, text.b, 0.06)
    readonly property color textAlpha07: Qt.rgba(text.r, text.g, text.b, 0.07)
    readonly property color textAlpha08: Qt.rgba(text.r, text.g, text.b, 0.08)
    readonly property color textAlpha10: Qt.rgba(text.r, text.g, text.b, 0.10)
    readonly property color textAlpha12: Qt.rgba(text.r, text.g, text.b, 0.12)
    readonly property color textAlpha13: Qt.rgba(text.r, text.g, text.b, 0.13)
    readonly property color textAlpha14: Qt.rgba(text.r, text.g, text.b, 0.14)
    readonly property color textAlpha15: Qt.rgba(text.r, text.g, text.b, 0.15)
    readonly property color textAlpha18: Qt.rgba(text.r, text.g, text.b, 0.18)
    readonly property color textAlpha20: Qt.rgba(text.r, text.g, text.b, 0.20)
    readonly property color textAlpha35: Qt.rgba(text.r, text.g, text.b, 0.35)
    readonly property color textDim: Qt.rgba(textMuted.r, textMuted.g, textMuted.b, 0.6)

    // Text
    property color textMuted: ColorSchemeService.currentColors.textMuted
    readonly property string user: Quickshell.env("USER")
    readonly property url userPfp: source("assets/gifs/userpfp.gif")

    function constellation(index) {
        return Qt.resolvedUrl("assets/lmbullets/" + index + ".png");
    }
    function source(url) {
        return Qt.resolvedUrl(url);
    }

    // Primary
    Behavior on accent {
        ColorAnimation {
            duration: 500
            easing.type: Easing.OutCubic
        }
    }

    // Secondary
    Behavior on accentAlt {
        ColorAnimation {
            duration: 500
            easing.type: Easing.OutCubic
        }
    }
    Behavior on accentAltContainer {
        ColorAnimation {
            duration: 500
            easing.type: Easing.OutCubic
        }
    }
    Behavior on accentContainer {
        ColorAnimation {
            duration: 500
            easing.type: Easing.OutCubic
        }
    }
    Behavior on base {
        ColorAnimation {
            duration: 500
            easing.type: Easing.OutCubic
        }
    }

    // Surfaces
    Behavior on fieldBg {
        ColorAnimation {
            duration: 500
            easing.type: Easing.OutCubic
        }
    }

    // Lavender
    Behavior on lavender {
        ColorAnimation {
            duration: 500
            easing.type: Easing.OutCubic
        }
    }
    Behavior on surfaceAlt {
        ColorAnimation {
            duration: 500
            easing.type: Easing.OutCubic
        }
    }

    // Text
    Behavior on text {
        ColorAnimation {
            duration: 500
            easing.type: Easing.OutCubic
        }
    }
    Behavior on textMuted {
        ColorAnimation {
            duration: 500
            easing.type: Easing.OutCubic
        }
    }
}
