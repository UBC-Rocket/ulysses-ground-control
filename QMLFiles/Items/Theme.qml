pragma Singleton
import QtQuick

QtObject {
    // ── Surfaces ──
    readonly property color background:      "#0B0F14"
    readonly property color surface:         "#121820"
    readonly property color surfaceElevated: "#1A2230"
    readonly property color surfaceInset:    "#0E1319"
    readonly property color sceneBackground: "#121820"

    // ── Borders ──
    readonly property color border:      "#1E2A3A"
    readonly property color borderLight: "#2A3A4E"
    readonly property color divider:     "#1A2536"

    // ── Text ──
    readonly property color textPrimary:   "#E8ECF1"
    readonly property color textSecondary: "#8A96A8"
    readonly property color textTertiary:  "#5C6A7E"

    // ── Accent ──
    readonly property color accent:       "#4FC3F7"
    readonly property color accentMuted:  "#2A7A9E"
    readonly property color accentSubtle: "#163040"

    // ── Status ──
    readonly property color success:   "#1e8e61"
    readonly property color successText: "#bfeeda"
    readonly property color successBg:   "#123a2e"
    readonly property color warn:      "#cda53a"
    readonly property color warnText:  "#ffe39a"
    readonly property color warnBg:    "#4b3d17"
    readonly property color danger:    "#b63b3b"
    readonly property color dangerText: "#f5c8c8"
    readonly property color dangerBg:   "#5a262a"

    // ── Typography ──
    readonly property string fontFamily:  "Inter"
    readonly property string monoFamily:  "JetBrains Mono"
    readonly property int fontH1:          22
    readonly property int fontH2:          16
    readonly property int fontBody:        14
    readonly property int fontCaption:     11
    readonly property int fontMetricValue: 20
    readonly property int fontMetricLabel: 11

    // ── Metrics ──
    readonly property int radiusPanel:   6
    readonly property int radiusControl: 4
    readonly property int radiusCard:    8
    readonly property int strokePanel:   1
    readonly property int strokeControl: 1
    readonly property int paddingSm:     6
    readonly property int paddingMd:    12
    readonly property int paddingLg:    18
    readonly property int paddingXl:    24
    readonly property int gridSpacing:   6

    // ── Buttons: Primary ──
    readonly property color btnPrimaryBg:      "#152844"
    readonly property color btnPrimaryHover:    "#1b335f"
    readonly property color btnPrimaryPress:    "#1f3a6d"
    readonly property color btnPrimaryBorder:   "#2c4a7a"
    readonly property color btnPrimaryText:     "#c8ddff"

    // ── Buttons: Secondary ──
    readonly property color btnSecondaryBg:     "#1a2332"
    readonly property color btnSecondaryHover:  "#1d3156"
    readonly property color btnSecondaryPress:  "#20375f"
    readonly property color btnSecondaryBorder: "#273246"
    readonly property color btnSecondaryText:   "#c8d5e7"

    // ── Transitions ──
    readonly property int transitionFast:   100
    readonly property int transitionNormal: 160
}
