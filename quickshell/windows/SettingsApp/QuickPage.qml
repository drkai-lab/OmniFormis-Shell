import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import QtCore
import "../.."
import "../../theme/variables.js" as Vars

Flickable {
    id: quickPageRoot

    Layout.fillWidth: true
    Layout.fillHeight: true

    contentWidth: width
    contentHeight: mainCol.implicitHeight + 64
    clip: true
    interactive: true

    flickDeceleration: Vars.flickDeceleration
    maximumFlickVelocity: Vars.maximumFlickVelocity

    signal openWallpaperSwitcher()

    M3Shapes { id: m3Shapes }

    FontLoader {
        id: filledIconFont
        source: "../../theme/assets/MaterialSymbolsRounded-Filled.ttf"
    }

    Settings {
        id: wallpaperSettings
        category: "WallpaperSwitcher"
        property string matugenScheme: "scheme-tonal-spot"
        property string wallpaperDir: ""
        property string currentWallpaper: ""
        property bool automaticSync: true
    }

    Settings {
        id: themeModeSettings
        category: "ColorScheme"
        property string currentMode: "dark"
    }

    Settings {
        id: presetStorage
        category: "ConfigurationPresets"
        property string savedPresetsJson: "[]"
    }

    // Process for running matugen and color scheme scripts
    Process {
        id: execProc
        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text.trim().length > 0)
                    console.log("[QUICK PAGE STDOUT]\n" + this.text);
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.trim().length > 0)
                    console.error("[QUICK PAGE STDERR]\n" + this.text);
            }
        }
        onExited: (code, status) => {
            if (code === 0) {
                Quickshell.execDetached({
                    command: ['bash', '-c', 'nohup bash ~/Dotfiles/scripts/reload.sh >/dev/null 2>&1 &']
                });
            } else {
                console.error("[USER ACTION] Matugen exited with code: " + code);
            }
        }
    }

    function syncMatugenAndTheme() {
        var wp = wallpaperSettings.currentWallpaper || "";
        var cleanWp = wp.replace(/^file:\/\//, "");
        var scheme = wallpaperSettings.matugenScheme || "scheme-tonal-spot";
        var matugenArg = (scheme === "scheme-auto" || scheme === "auto") ? "scheme-tonal-spot" : scheme;
        var mode = themeModeSettings.currentMode || "dark";

        var cmd = "";
        if (cleanWp !== "" && wallpaperSettings.automaticSync !== false) {
            console.log("[USER ACTION] Running Matugen and system theme mode sync: " + cleanWp + " (" + matugenArg + ", " + mode + ")");
            cmd += "matugen image '" + cleanWp + "' -m '" + mode + "' -t '" + matugenArg + "' --source-color-index 0; ";
        }
        console.log("[USER ACTION] Running set-theme mode switch: " + mode);
        cmd += "bash ~/.config/color-schemes/set-theme.sh 'material-you' '" + mode + "'; ";

        execProc.command = ["bash", "-c", cmd];
        execProc.running = true;
    }

    // Presets Model management
    ListModel {
        id: presetsModel
    }

    function refreshPresetsModel() {
        presetsModel.clear();
        try {
            var list = JSON.parse(presetStorage.savedPresetsJson || "[]");
            for (var i = 0; i < list.length; i++) {
                var item = list[i];
                presetsModel.append({
                    "presetId": item.id || Date.now().toString(),
                    "name": item.name || ("Preset " + (i + 1)),
                    "timestamp": item.timestamp || "",
                    "wallpaper": item.wallpaper || "",
                    "matugenScheme": item.matugenScheme || "scheme-tonal-spot",
                    "colorMode": item.colorMode || "dark",
                    "maskShape": item.maskShape || "6SidedCookie",
                    "variablesJson": JSON.stringify(item.variables || {})
                });
            }
        } catch (e) {
            console.error("Error parsing savedPresetsJson:", e);
        }
    }

    function createNewPreset() {
        try {
            var existingList = JSON.parse(presetStorage.savedPresetsJson || "[]");
            var varSnapshot = {
                animationDuration: Vars.animationDuration,
                translucent: Vars.translucent,
                blurAmount: Vars.blurAmount,
                overviewGridRows: Vars.overviewGridRows,
                overviewGridColumns: Vars.overviewGridColumns,
                overviewScale: Vars.overviewScale,
                radiusAmount: Vars.radiusAmount,
                radiusSmall: Vars.radiusSmall,
                radiusMedium: Vars.radiusMedium,
                radiusLarge: Vars.radiusLarge,
                radiusExtraLarge: Vars.radiusExtraLarge,
                spacingSmall: Vars.spacingSmall,
                spacingMedium: Vars.spacingMedium,
                spacingLarge: Vars.spacingLarge,
                paddingSmall: Vars.paddingSmall,
                paddingMedium: Vars.paddingMedium,
                paddingLarge: Vars.paddingLarge,
                wallpaperMaskEnabled: Vars.wallpaperMaskEnabled,
                wallpaperMaskScale: Vars.wallpaperMaskScale,
                wallpaperMaskShape: Vars.wallpaperMaskShape,
                wallpaperMaskColor: Vars.wallpaperMaskColor,
                wallpaperMaskOffsetX: Vars.wallpaperMaskOffsetX,
                wallpaperMaskOffsetY: Vars.wallpaperMaskOffsetY,
                clockShape: Vars.clockShape,
                clockShowTicks: Vars.clockShowTicks,
                clockShowCenterDot: Vars.clockShowCenterDot,
                panelStyle: Vars.panelStyle,
                mediaPlayerShape: Vars.mediaPlayerShape,
                mediaPlayerArtScale: Vars.mediaPlayerArtScale,
                gameMode: Vars.gameMode,
                desktopClockEnabled: Vars.desktopClockEnabled,
                desktopCalenderEnabled: Vars.desktopCalenderEnabled,
                desktopMediaPlayerEnabled: Vars.desktopMediaPlayerEnabled
            };

            var count = existingList.length + 1;
            var timeString = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
            var newObj = {
                id: Date.now().toString() + "-" + Math.random().toString(36).substring(2, 7),
                name: "Config Preset " + count,
                timestamp: "Saved at " + timeString,
                wallpaper: wallpaperSettings.currentWallpaper,
                matugenScheme: wallpaperSettings.matugenScheme || "scheme-tonal-spot",
                colorMode: themeModeSettings.currentMode || "dark",
                maskShape: Vars.wallpaperMaskShape || "6SidedCookie",
                variables: varSnapshot
            };

            existingList.push(newObj);
            presetStorage.savedPresetsJson = JSON.stringify(existingList);
            refreshPresetsModel();
        } catch (e) {
            console.error("Failed to create preset:", e);
        }
    }

    function applyPreset(index) {
        if (index < 0 || index >= presetsModel.count) return;
        var item = presetsModel.get(index);
        var varsObj = JSON.parse(item.variablesJson || "{}");

        var shellCmds = "";
        for (var key in varsObj) {
            var val = varsObj[key];
            // Apply live in JS
            try {
                eval("Vars." + key + " = " + JSON.stringify(val) + ";");
            } catch (e) {}
            // Build command to save persistently via omniformis
            shellCmds += "$HOME/.local/bin/omniformis qs set '" + key + "' '" + val + "'; ";
        }

        if (item.wallpaper !== "") {
            wallpaperSettings.currentWallpaper = item.wallpaper;
        }
        if (item.matugenScheme !== "") {
            wallpaperSettings.matugenScheme = item.matugenScheme;
        }
        if (item.colorMode !== "") {
            themeModeSettings.currentMode = item.colorMode;
        }

        var wp = wallpaperSettings.currentWallpaper || "";
        var cleanWp = wp.replace(/^file:\/\//, "");
        var scheme = wallpaperSettings.matugenScheme || "scheme-tonal-spot";
        var matugenArg = (scheme === "scheme-auto" || scheme === "auto") ? "scheme-tonal-spot" : scheme;
        var mode = themeModeSettings.currentMode || "dark";

        if (cleanWp !== "") {
            shellCmds += "matugen image '" + cleanWp + "' -m '" + mode + "' -t '" + matugenArg + "' --source-color-index 0; ";
        }
        shellCmds += "bash ~/.config/color-schemes/set-theme.sh 'material-you' '" + mode + "'; ";
        shellCmds += "nohup bash ~/Dotfiles/scripts/reload.sh >/dev/null 2>&1 &";

        execProc.command = ["bash", "-c", shellCmds];
        execProc.running = true;
    }

    function deletePreset(index) {
        if (index < 0 || index >= presetsModel.count) return;
        var targetId = presetsModel.get(index).presetId;
        try {
            var list = JSON.parse(presetStorage.savedPresetsJson || "[]");
            list = list.filter(function(p) { return p.id !== targetId; });
            presetStorage.savedPresetsJson = JSON.stringify(list);
            refreshPresetsModel();
        } catch (e) {
            console.error("Error deleting preset:", e);
        }
    }

    Component.onCompleted: {
        refreshPresetsModel();
    }

    ColumnLayout {
        id: mainCol
        width: parent.width
        spacing: 24

        // ═════════════════════════════════════════════════════════════
        // SECTION 1: WALLPAPER & COLORS (Android 14 Material 3 Styling)
        // ═════════════════════════════════════════════════════════════
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16

            // M3 Styled Section Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // M3 Cookie Background Shape containing Monitor/Screen Icon (Without inverted background box!)
                Item {
                    width: 38
                    height: 38

                    Image {
                        anchors.fill: parent
                        sourceSize: Qt.size(width, height)
                        source: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><path d='" + m3Shapes.getPath("12SidedCookie") + "' fill='" + (Theme.surface_container_highest || "#3b383e") + "'/></svg>"
                        smooth: true
                        antialiasing: true
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "\ue323" // display / screen icon
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 20
                        color: Theme.on_surface_variant
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: "Wallpaper & Colors"
                    font.family: Vars.fontFamily
                    font.pixelSize: 18
                    font.weight: 600
                    color: Theme.on_surface
                    elide: Text.ElideRight
                }
            }

            // Split Dashboard Layout (Left Wallpaper Monitor Box + Right Mode & Schemes Grid)
            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                // Left Box: Dark Widescreen Wallpaper Monitor Container & Squircle FAB
                Item {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 540
                    Layout.minimumWidth: 420
                    Layout.preferredHeight: 310

                    // Widescreen rectangular card with 28px rounded corner clipping and zero edge gap
                    Rectangle {
                        id: wpCard
                        anchors.fill: parent
                        radius: 28
                        color: Qt.rgba(0.08, 0.09, 0.10, 1.0)
                        border.color: Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.12)
                        border.width: 1
                        clip: true

                        // Wallpaper scaled slightly larger with negative margins and masked to card bounds
                        Image {
                            id: wpPrevImg
                            anchors.fill: parent
                            anchors.margins: -4 // scale past edges before masking to guarantee zero gap
                            fillMode: Image.PreserveAspectCrop
                            source: wallpaperSettings.currentWallpaper !== "" ? (wallpaperSettings.currentWallpaper.startsWith("file://") ? wallpaperSettings.currentWallpaper : "file://" + wallpaperSettings.currentWallpaper) : ""
                            smooth: true
                            antialiasing: true
                            mipmap: true

                            layer.enabled: true
                            layer.smooth: true
                            layer.effect: MultiEffect {
                                maskEnabled: true
                                maskSource: topWpMask
                                maskThresholdMin: 0.5
                                maskSpreadAtMin: 1.0
                            }
                        }

                        Item {
                            id: topWpMask
                            anchors.fill: parent
                            visible: false
                            layer.enabled: true
                            layer.smooth: true
                            Rectangle {
                                anchors.fill: parent
                                radius: 28
                            }
                        }

                        // Elegant fallback icon when wallpaper image is loading or empty
                        Text {
                            anchors.centerIn: parent
                            visible: wpPrevImg.status !== Image.Ready
                            text: "\ue386" // wallpaper photo icon
                            font.family: "Material Symbols Outlined"
                            font.pixelSize: 42
                            color: Theme.on_surface_variant
                            opacity: 0.4
                        }
                    }

                    // M3 Squircle FAB Button to Open Wallpaper Switcher
                    Rectangle {
                        id: fabButton
                        width: 54
                        height: 54
                        radius: 18 // M3 Squircle curvature
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 22

                        // Muted sage/accent tone matching Android 14 M3 FAB
                        color: fabHover.pressed ? Qt.darker(Theme.secondary_container, 1.15) : (fabHover.containsMouse ? Qt.tint(Theme.secondary_container, Qt.rgba(Theme.on_secondary_container.r, Theme.on_secondary_container.g, Theme.on_secondary_container.b, 0.12)) : Qt.rgba(Theme.secondary_container.r, Theme.secondary_container.g, Theme.secondary_container.b, 0.85))
                        
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowBlur: 1.2
                            shadowColor: Qt.rgba(0, 0, 0, 0.35)
                            shadowVerticalOffset: 4
                        }

                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                        Text {
                            anchors.centerIn: parent
                            text: "edit" // pen / edit icon
                            font.family: "Material Symbols Outlined"
                            font.pixelSize: 24
                            color: Theme.on_secondary_container
                            scale: fabHover.pressed ? 0.92 : 1.0
                            Behavior on scale { NumberAnimation { duration: 150 } }
                        }

                        MouseArea {
                            id: fabHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                quickPageRoot.openWallpaperSwitcher();
                            }
                        }
                    }
                }

                // Right Box: Light & Dark Modes + Matugen Color Schemes Grid
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 460
                    Layout.minimumWidth: 340
                    Layout.fillHeight: true
                    spacing: 12

                    // Top Row: Light & Dark Mode Toggle Buttons
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        // Light Mode Button
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 82
                            property bool isSelected: themeModeSettings.currentMode === "light"
                            topLeftRadius: 26
                            bottomLeftRadius: 26
                            topRightRadius: isSelected ? 26 : 6
                            bottomRightRadius: isSelected ? 26 : 6

                            Behavior on topLeftRadius { NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } }
                            Behavior on bottomLeftRadius { NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } }
                            Behavior on topRightRadius { NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } }
                            Behavior on bottomRightRadius { NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } }
                            color: isSelected ? Theme.secondary_container : (lightHover.containsMouse ? Theme.surface_container_highest : Theme.surface_container_high)
                            border.width: 0

                            Behavior on color { ColorAnimation { duration: 180 } }

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "\ue518" // light_mode sun
                                    font.family: parent.parent.isSelected ? filledIconFont.name : "Material Symbols Outlined"
                                    font.pixelSize: 24
                                    color: parent.parent.isSelected ? Theme.on_secondary_container : Theme.on_surface_variant
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "Light"
                                    font.family: Vars.fontFamily
                                    font.pixelSize: 13
                                    font.weight: parent.parent.isSelected ? 700 : 500
                                    color: parent.parent.isSelected ? Theme.on_secondary_container : Theme.on_surface_variant
                                }
                            }

                            MouseArea {
                                id: lightHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (themeModeSettings.currentMode !== "light") {
                                        themeModeSettings.currentMode = "light";
                                        syncMatugenAndTheme();
                                    }
                                }
                            }
                        }

                        // Dark Mode Button
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 82
                            property bool isSelected: themeModeSettings.currentMode === "dark"
                            topLeftRadius: isSelected ? 26 : 6
                            bottomLeftRadius: isSelected ? 26 : 6
                            topRightRadius: 26
                            bottomRightRadius: 26

                            Behavior on topLeftRadius { NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } }
                            Behavior on bottomLeftRadius { NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } }
                            Behavior on topRightRadius { NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } }
                            Behavior on bottomRightRadius { NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } }
                            color: isSelected ? Theme.secondary_container : (darkHover.containsMouse ? Theme.surface_container_highest : Theme.surface_container_high)
                            border.width: 0

                            Behavior on color { ColorAnimation { duration: 180 } }

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "\ue51c" // dark_mode crescent moon
                                    font.family: parent.parent.isSelected ? filledIconFont.name : "Material Symbols Outlined"
                                    font.pixelSize: 24
                                    color: parent.parent.isSelected ? Theme.on_secondary_container : Theme.on_surface_variant
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "Dark"
                                    font.family: Vars.fontFamily
                                    font.pixelSize: 13
                                    font.weight: parent.parent.isSelected ? 700 : 500
                                    color: parent.parent.isSelected ? Theme.on_secondary_container : Theme.on_surface_variant
                                }
                            }

                            MouseArea {
                                id: darkHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (themeModeSettings.currentMode !== "dark") {
                                        themeModeSettings.currentMode = "dark";
                                        syncMatugenAndTheme();
                                    }
                                }
                            }
                        }
                    }

                    // Bottom Area: Matugen Color Scheme Styles Grid (Icon Top-Left, Text Bottom-Right)
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 3
                        rowSpacing: 4
                        columnSpacing: 4

                        Repeater {
                            model: [
                                { name: "Auto", scheme: "scheme-auto", icon: "auto_awesome" },
                                { name: "Content", scheme: "scheme-content", icon: "photo_library" },
                                { name: "Expressive", scheme: "scheme-expressive", icon: "palette" },
                                { name: "Fidelity", scheme: "scheme-fidelity", icon: "tune" },
                                { name: "Fruit Salad", scheme: "scheme-fruit-salad", icon: "local_florist" },
                                { name: "Monochrome", scheme: "scheme-monochrome", icon: "contrast" },
                                { name: "Neutral", scheme: "scheme-neutral", icon: "tonality" },
                                { name: "Rainbow", scheme: "scheme-rainbow", icon: "gradient" },
                                { name: "Tonal Spot", scheme: "scheme-tonal-spot", icon: "adjust" }
                            ]
                            delegate: Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 64

                                property bool isSelected: wallpaperSettings.matugenScheme === modelData.scheme
                                property bool hasLeft: index % 3 !== 0
                                property bool hasRight: index % 3 !== 2
                                property bool hasTop: index >= 3
                                property bool hasBottom: index < 6

                                topLeftRadius: isSelected ? 24 : ((!hasLeft && !hasTop) ? 24 : 6)
                                topRightRadius: isSelected ? 24 : ((!hasRight && !hasTop) ? 24 : 6)
                                bottomLeftRadius: isSelected ? 24 : ((!hasLeft && !hasBottom) ? 24 : 6)
                                bottomRightRadius: isSelected ? 24 : ((!hasRight && !hasBottom) ? 24 : 6)

                                Behavior on topLeftRadius { NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } }
                                Behavior on topRightRadius { NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } }
                                Behavior on bottomLeftRadius { NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } }
                                Behavior on bottomRightRadius { NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } }

                                color: isSelected ? (Vars.translucent ? Qt.rgba(Theme.secondary_container.r, Theme.secondary_container.g, Theme.secondary_container.b, 0.95) : Theme.secondary_container) : (schemeHover.containsMouse ? Theme.surface_container_highest : Theme.surface_container_high)
                                border.width: 0

                                Behavior on color { ColorAnimation { duration: 160 } }

                                // Icon Top-Left
                                Text {
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.margins: 10
                                    text: modelData.icon
                                    font.family: parent.isSelected ? filledIconFont.name : "Material Symbols Outlined"
                                    font.pixelSize: 17
                                    color: parent.isSelected ? Theme.on_secondary_container : Theme.on_surface_variant
                                }

                                // Text Bottom-Right
                                Text {
                                    anchors.bottom: parent.bottom
                                    anchors.right: parent.right
                                    anchors.margins: 10
                                    text: modelData.name
                                    font.family: Vars.fontFamily
                                    font.pixelSize: 11
                                    font.weight: parent.isSelected ? 700 : 500
                                    color: parent.isSelected ? Theme.on_secondary_container : Theme.on_surface
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                }

                                MouseArea {
                                    id: schemeHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        wallpaperSettings.matugenScheme = modelData.scheme;
                                        syncMatugenAndTheme();
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Quick Toggles Row (Transparency & Automatic)
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4
                spacing: 28

                // Transparency Toggle Item
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Text {
                        text: "\ue38b" // layers / transparency icon
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 22
                        color: Theme.on_surface_variant
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Translucent"
                        font.family: Vars.fontFamily
                        font.pixelSize: 15
                        font.weight: 500
                        color: Theme.on_surface

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Vars.translucent = !Vars.translucent;
                                Quickshell.execDetached({
                                    command: ["bash", "-c", "$HOME/.local/bin/omniformis qs set 'translucent' '" + Vars.translucent + "'; nohup bash ~/Dotfiles/scripts/reload.sh >/dev/null 2>&1 &"]
                                });
                            }
                        }
                    }

                    // M3 Toggle Pill Switch
                    Rectangle {
                        width: 50
                        height: 30
                        radius: 15
                        color: Vars.translucent ? Theme.primary_container : Qt.rgba(Theme.surface_container_highest.r, Theme.surface_container_highest.g, Theme.surface_container_highest.b, 0.8)
                        border.color: Vars.translucent ? "transparent" : Theme.outline_variant
                        border.width: Vars.translucent ? 0 : 1

                        Behavior on color { ColorAnimation { duration: 150 } }

                        // Thumb Circle
                        Rectangle {
                            width: Vars.translucent ? 22 : 18
                            height: width
                            radius: width / 2
                            y: (parent.height - height) / 2
                            x: Vars.translucent ? parent.width - width - 4 : 5
                            color: Vars.translucent ? Theme.on_primary_container : Theme.on_surface_variant

                            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                            Behavior on width { NumberAnimation { duration: 150 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Vars.translucent = !Vars.translucent;
                                Quickshell.execDetached({
                                    command: ["bash", "-c", "$HOME/.local/bin/omniformis qs set 'translucent' '" + Vars.translucent + "'; nohup bash ~/Dotfiles/scripts/reload.sh >/dev/null 2>&1 &"]
                                });
                            }
                        }
                    }
                }

                // Automatic Sync Toggle Item
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Text {
                        text: "\ue387" // color synchronization icon
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 22
                        color: Theme.on_surface_variant
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Automatic"
                        font.family: Vars.fontFamily
                        font.pixelSize: 15
                        font.weight: 500
                        color: Theme.on_surface
                    }

                    // M3 Toggle Pill Switch
                    Rectangle {
                        width: 50
                        height: 30
                        radius: 15
                        color: wallpaperSettings.automaticSync !== false ? Theme.primary_container : Qt.rgba(Theme.surface_container_highest.r, Theme.surface_container_highest.g, Theme.surface_container_highest.b, 0.8)
                        border.color: wallpaperSettings.automaticSync !== false ? "transparent" : Theme.outline_variant
                        border.width: wallpaperSettings.automaticSync !== false ? 0 : 1

                        Behavior on color { ColorAnimation { duration: 150 } }

                        // Thumb Circle
                        Rectangle {
                            width: wallpaperSettings.automaticSync !== false ? 22 : 18
                            height: width
                            radius: width / 2
                            y: (parent.height - height) / 2
                            x: wallpaperSettings.automaticSync !== false ? parent.width - width - 4 : 5
                            color: wallpaperSettings.automaticSync !== false ? Theme.on_primary_container : Theme.on_surface_variant

                            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                            Behavior on width { NumberAnimation { duration: 150 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                wallpaperSettings.automaticSync = !wallpaperSettings.automaticSync;
                            }
                        }
                    }
                }
            }

            // Pill Position Selection (Horizontally laid out below the translucent text)
            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                spacing: 10

                RowLayout {
                    spacing: 12
                    Text {
                        text: "\ue250" // vertical alignment/docking icon
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 22
                        color: Theme.on_surface_variant
                    }
                    Text {
                        text: "Pill Position"
                        font.family: Vars.fontFamily
                        font.pixelSize: 15
                        font.weight: 500
                        color: Theme.on_surface
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: [
                            { name: "Top", pos: "Top", icon: "\ue5ce" },
                            { name: "Right", pos: "Right", icon: "\ue5cc" },
                            { name: "Left", pos: "Left", icon: "\ue5cb" },
                            { name: "Bottom", pos: "Bottom", icon: "\ue5cf" }
                        ]
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 46
                            property bool isSelected: (Vars.pillPosition || "Top") === modelData.pos
                            radius: isSelected ? 23 : 12
                            color: isSelected ? Theme.secondary_container : (posHover.containsMouse ? Theme.surface_container_highest : Theme.surface_container_high)
                            border.width: 0

                            Behavior on radius { NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } }
                            Behavior on color { ColorAnimation { duration: 160 } }

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 8
                                Text {
                                    text: modelData.icon
                                    font.family: parent.parent.isSelected ? filledIconFont.name : "Material Symbols Outlined"
                                    font.pixelSize: 20
                                    color: parent.parent.isSelected ? Theme.on_secondary_container : Theme.on_surface_variant
                                }
                                Text {
                                    text: modelData.name
                                    font.family: Vars.fontFamily
                                    font.pixelSize: 13
                                    font.weight: parent.parent.isSelected ? 700 : 500
                                    color: parent.parent.isSelected ? Theme.on_secondary_container : Theme.on_surface
                                }
                            }

                            MouseArea {
                                id: posHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (Vars.pillPosition !== modelData.pos) {
                                        Vars.pillPosition = modelData.pos;
                                        Quickshell.execDetached({
                                            command: ["bash", "-c", "$HOME/.local/bin/omniformis qs set 'pillPosition' '" + Vars.pillPosition + "'; nohup bash ~/Dotfiles/scripts/reload.sh >/dev/null 2>&1 &"]
                                        });
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Horizontal Divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08)
        }

        // ═════════════════════════════════════════════════════════════
        // SECTION 2: SAVED PRESETS MANAGEMENT
        // ═════════════════════════════════════════════════════════════
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16

            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    // M3 Shape Container for Presets Icon (Without inverted background box!)
                    Item {
                        width: 38
                        height: 38

                        Image {
                            anchors.fill: parent
                            sourceSize: Qt.size(width, height)
                            source: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><path d='" + m3Shapes.getPath("6SidedCookie") + "' fill='" + (Theme.surface_container_highest || "#3b383e") + "'/></svg>"
                            smooth: true
                            antialiasing: true
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "\ue41d" // presets / customization icon
                            font.family: "Material Symbols Outlined"
                            font.pixelSize: 20
                            color: Theme.on_surface_variant
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Configuration Presets"
                        font.family: Vars.fontFamily
                        font.pixelSize: 18
                        font.weight: 600
                        color: Theme.on_surface
                        elide: Text.ElideRight
                    }
                }

                // Animated M3 Rounded Square "+" Add Button
                Rectangle {
                    Layout.alignment: Qt.AlignTop | Qt.AlignRight
                    Layout.preferredHeight: 44
                    Layout.preferredWidth: 44
                    radius: 14
                    color: createHover.pressed ? Qt.darker(Theme.secondary_container, 1.15) : (createHover.containsMouse ? Qt.tint(Theme.secondary_container, Qt.rgba(Theme.on_secondary_container.r, Theme.on_secondary_container.g, Theme.on_secondary_container.b, 0.12)) : Theme.secondary_container)

                    Behavior on color { ColorAnimation { duration: 150 } }

                    SequentialAnimation on radius {
                        id: morphAnim
                        running: false
                        NumberAnimation { to: 22; duration: 160; easing.type: Easing.OutBack } // morph into circle
                        NumberAnimation { to: 14; duration: 220; easing.type: Easing.InOutQuad } // morph back to rounded square
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "add" // material icon ligature for add (+)
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 24
                        color: Theme.on_secondary_container
                        scale: createHover.pressed ? 0.92 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150 } }
                    }

                    MouseArea {
                        id: createHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            morphAnim.restart();
                            createNewPreset();
                        }
                    }
                }
            }

            // Presets Cards Grid
            Flow {
                Layout.fillWidth: true
                spacing: 16

                Text {
                    visible: presetsModel.count === 0
                    text: "No presets here"
                    font.family: Vars.fontFamily
                    font.pixelSize: 14
                    color: Theme.on_surface_variant
                    opacity: 0.7
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.italic: true
                    wrapMode: Text.WordWrap
                }

                Repeater {
                    model: presetsModel

                    delegate: Item {
                        width: 320
                        height: 235

                        // Card background with clean clipping and rounded corners
                        Rectangle {
                            id: cardBase
                            anchors.fill: parent
                            radius: 24
                            color: Vars.translucent ? Qt.rgba(Theme.surface_container_low.r, Theme.surface_container_low.g, Theme.surface_container_low.b, 0.6) : Theme.surface_container_low
                            border.color: Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08)
                            border.width: 1
                            clip: true

                            // Wallpaper Image with smooth hardware-accelerated rounding
                            Image {
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectCrop
                                source: model.wallpaper !== "" ? (model.wallpaper.startsWith("file://") ? model.wallpaper : "file://" + model.wallpaper) : ""
                                smooth: true
                                antialiasing: true
                                mipmap: true

                                layer.enabled: true
                                layer.smooth: true
                                layer.effect: MultiEffect {
                                    maskEnabled: true
                                    maskSource: presetWpMask
                                    maskThresholdMin: 0.5
                                    maskSpreadAtMin: 1.0
                                }
                            }

                            Item {
                                id: presetWpMask
                                anchors.fill: parent
                                visible: false
                                layer.enabled: true
                                layer.smooth: true
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 24
                                }
                            }

                            // Bottom 1/4 Translucent Banner
                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: 56
                                bottomLeftRadius: 24
                                bottomRightRadius: 24
                                color: Vars.translucent ? Qt.rgba(Theme.surface_container_highest.r, Theme.surface_container_highest.g, Theme.surface_container_highest.b, 0.92) : Theme.surface_container_highest
                                
                                Rectangle {
                                    anchors.top: parent.top
                                    width: parent.width
                                    height: 1
                                    color: Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08)
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 14
                                    anchors.rightMargin: 14
                                    spacing: 10

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        Text {
                                            Layout.fillWidth: true
                                            text: model.name
                                            font.family: Vars.fontFamily
                                            font.pixelSize: 14
                                            font.weight: 700
                                            color: Theme.on_surface
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            Layout.fillWidth: true
                                            text: model.colorMode + " mode • " + model.matugenScheme.replace("scheme-", "")
                                            font.family: Vars.fontFamily
                                            font.pixelSize: 11
                                            color: Theme.on_surface_variant
                                            opacity: 0.9
                                            elide: Text.ElideRight
                                        }
                                    }

                                    // Apply Button / Badge
                                    Rectangle {
                                        Layout.preferredWidth: 58
                                        Layout.preferredHeight: 30
                                        radius: 15
                                        color: applyHover.containsMouse ? Theme.primary : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2)
                                        Behavior on color { ColorAnimation { duration: 150 } }

                                        Text {
                                            anchors.centerIn: parent
                                            text: "Apply"
                                            font.family: Vars.fontFamily
                                            font.pixelSize: 12
                                            font.weight: 600
                                            color: applyHover.containsMouse ? Theme.on_primary : Theme.primary
                                            Behavior on color { ColorAnimation { duration: 150 } }
                                        }

                                        MouseArea {
                                            id: applyHover
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                applyPreset(index);
                                            }
                                        }
                                    }

                                    // Delete Preset Button
                                    Rectangle {
                                        Layout.preferredWidth: 30
                                        Layout.preferredHeight: 30
                                        radius: 15
                                        color: delHover.containsMouse ? Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.2) : "transparent"
                                        Behavior on color { ColorAnimation { duration: 150 } }

                                        Text {
                                            anchors.centerIn: parent
                                            text: "\ue872" // delete trash icon
                                            font.family: "Material Symbols Outlined"
                                            font.pixelSize: 18
                                            color: delHover.containsMouse ? Theme.error : Theme.on_surface_variant
                                            Behavior on color { ColorAnimation { duration: 150 } }
                                        }

                                        MouseArea {
                                            id: delHover
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                deletePreset(index);
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Clicking anywhere on top 3/4 applies the preset
                        MouseArea {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: parent.height - 56
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                applyPreset(index);
                            }
                        }
                    }
                }
            }
        }
    }
}
