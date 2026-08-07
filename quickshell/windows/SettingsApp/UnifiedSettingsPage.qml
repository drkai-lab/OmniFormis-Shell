import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import "../.."
import "../../theme/variables.js" as Vars

ColumnLayout {
    id: rootPage

    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: Vars.spacingMedium

    property var allVars: []
    property string activeCategory: "General"
    
    property string pageTitle: ""
    property string pageIcon: ""
    property string pageShape: "Circle"
    property color pageColor: Theme.primary
    property color pageOnColor: Theme.on_primary
    onActiveCategoryChanged: applyFilter()
    property string copiedSliderValue: ""

    function prettyTitle(key) {
        var custom = {
            "clockShowTicks": "Clock: Show Ticks",
            "clockShowCenterDot": "Clock: Show Center Dot",
            "clockShape": "Clock Widget Shape",
            "wallpaperMaskShape": "Wallpaper Mask Shape",
            "wallpaperMaskScale": "Wallpaper Mask Scale",
            "wallpaperMaskColor": "Wallpaper Mask Color",
            "wallpaperMaskEnabled": "Enable Wallpaper Mask",
            "wallpaperMaskOffsetX": "Wallpaper Mask X Offset",
            "wallpaperMaskOffsetY": "Wallpaper Mask Y Offset",
            "mediaPlayerShape": "Media Player Widget Shape",
            "mediaPlayerArtScale": "Media Player Art Scale",
            "gameMode": "Game Mode Optimization",
            "animationDuration": "Master Animation Duration",
            "flickDeceleration": "Scroll Deceleration Rate",
            "maximumFlickVelocity": "Max Scroll Velocity",
            "blurAmount": "Window Blur Intensity",
            "panelOpacity": "Main Panel Opacity",
            "componentOpacity": "Inner Component Opacity",
            "radiusAmount": "Window Corner Radius Scale",
            "fontFamily": "Interface Font Family",
            "pillPosition": "Panel Screen Position",
            "panelStyle": "Panel Visual Style",
            "gaps_in": "Inner Window Gaps",
            "gaps_out": "Outer Window Gaps",
            "border_size": "Window Border Size",
            "rounding": "Window Corner Rounding",
            "rounding_power": "Rounding Super-ellipse Power",
            "active_opacity": "Active Window Opacity",
            "inactive_opacity": "Inactive Window Opacity",
            "windowOpacity": "Global Window Opacity",
            "follow_mouse": "Follow Mouse Focus",
            "sensitivity": "Cursor Sensitivity",
            "touchpad_natural_scroll": "Touchpad Natural Scrolling",
            "force_default_wallpaper": "Default Hyprland Wallpaper",
            "gesture_direction": "Swipe Gesture Direction",
            "AnimateStyle": "System Animation Style",
            "Layout": "Window Tiling Layout"
        };
        if (custom[key]) return custom[key];
        var str = key.replace(/_/g, " ").replace(/([A-Z])/g, " $1").replace(/\s+/g, " ").trim();
        return str.charAt(0).toUpperCase() + str.slice(1);
    }

    function prettyHelp(key, rawHelp) {
        var descriptions = {
            "clockShowTicks": "Display hour dial tick marks around the perimeter of the analog clock widget.",
            "clockShowCenterDot": "Render the prominent decorative center pin dot on the analog clock hands.",
            "clockShape": "Select the Material 3 expressive silhouette shape for the desktop clock container.",
            "wallpaperMaskShape": "Select the geometric clipping cutout shape applied to the wallpaper background.",
            "wallpaperMaskScale": "Scale zoom factor for the wallpaper cutout mask geometry.",
            "wallpaperMaskColor": "Solid tint background color visible around the perimeter of the masked wallpaper.",
            "wallpaperMaskEnabled": "Toggle the expressive Material 3 clipping mask over the desktop wallpaper.",
            "wallpaperMaskOffsetX": "Horizontal X-axis pixel shift for positioning the wallpaper clipping mask.",
            "wallpaperMaskOffsetY": "Vertical Y-axis pixel shift for positioning the wallpaper clipping mask.",
            "mediaPlayerShape": "Select the Material 3 cutout shape contour for the desktop audio player widget.",
            "mediaPlayerArtScale": "Scale zoom factor for album artwork displayed inside the desktop audio player.",
            "gameMode": "Suspend heavy decorative shell animations and blur effects for optimal gaming performance.",
            "animationDuration": "Master transition duration in milliseconds for interface micro-animations.",
            "flickDeceleration": "Friction rate applied when coasting through scrollable UI flick views.",
            "maximumFlickVelocity": "Maximum speed velocity clamp for touch and mouse scroll swiping.",
            "blurAmount": "Gaussian background blur radius applied behind translucent shell elements and windows.",
            "panelOpacity": "Global opacity level for main background panels and floating windows.",
            "componentOpacity": "Global opacity level for interactive components and lists inside panels.",
            "radiusAmount": "Master multiplication ratio applied to window and container corner roundings.",
            "fontFamily": "Primary typography font family used across Quickshell overlays and panels.",
            "pillPosition": "Select the edge of the display monitor where the shell control bar is docked.",
            "panelStyle": "Choose between Floating, Attached (flush), or Framed shell bar geometry.",
            "gaps_in": "Spacing distance in pixels between adjacent tiled windows on the workspace.",
            "gaps_out": "Spacing distance in pixels between tiled windows and the outer display monitor screen edge.",
            "border_size": "Thickness in pixels of the colored focus outline ring surrounding windows.",
            "rounding": "Radius in pixels for window frame corner curves.",
            "rounding_power": "Super-ellipse curvature exponent controlling squished rounded corner smoothness.",
            "active_opacity": "Translucency alpha level applied to currently focused active application windows.",
            "inactive_opacity": "Translucency alpha level applied to background unfocused application windows.",
            "follow_mouse": "Determine whether input focus automatically changes to the window directly beneath the pointer.",
            "sensitivity": "Hardware input multiplier scaling pointer movement speed and sensitivity.",
            "touchpad_natural_scroll": "Invert vertical scroll direction on touchpads to mimic direct touch dragging.",
            "force_default_wallpaper": "Control display of standard anime backgrounds when starting the Hyprland compositor.",
            "gesture_direction": "Direction axes monitored when swiping with multi-touch workspace transitions.",
            "AnimateStyle": "Active motion choreography flavor defining easing mechanics and window transitions.",
            "Layout": "Tiling layout algorithm arranging windows (Dwindle, Master, Scrolling, or Monocle)."
        };
        if (descriptions[key]) return descriptions[key];
        if (!rawHelp || rawHelp === "Quickshell variable" || rawHelp === "Hyprland variable") {
            return "Configure " + rootPage.prettyTitle(key) + " (" + key + ") settings for your environment.";
        }
        return rawHelp;
    }

    function updateVariable(key, val, source) {
        var isQs = source === "Quickshell" || source === "quickshell";
        var cmdArray = [];
        var isLive = false;
        if (isQs) {
            var liveVars = ["clockShape", "clockShowTicks", "clockShowCenterDot", "wallpaperMaskShape", "wallpaperMaskScale", "wallpaperMaskColor", "wallpaperMaskEnabled", "wallpaperMaskOffsetX", "wallpaperMaskOffsetY", "mediaPlayerShape", "mediaPlayerArtScale", "gameMode"];
            isLive = liveVars.indexOf(key) !== -1 || key.startsWith("desktop");
            cmdArray = ["/home/boing/.local/bin/omniformis", "qs", "set", key, String(val)];
        } else {
            cmdArray = ["/home/boing/.local/bin/omniformis", "hypr", "set", key, String(val)];
        }
        var cmd = JSON.stringify(cmdArray);
        var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ' + cmd + '; onExited: destroy() }', rootPage);
        proc.running = true;

        if (isQs && isLive) {
            try {
                if (val === "true" || val === "false") {
                    Vars[key] = (val === "true");
                } else if (!isNaN(Number(val)) && val !== "") {
                    Vars[key] = Number(val);
                } else {
                    Vars[key] = val;
                }
            } catch (e) {
                console.warn("SettingsApp: Failed to update live variable: " + key + " = " + val + ". Error: " + e);
            }
        } else if (isQs && !isLive) {
            var reloadProc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["bash", "-c", "nohup bash ~/Dotfiles/scripts/reload.sh >/dev/null 2>&1 &"]; onExited: destroy() }', rootPage);
            reloadProc.running = true;
        }
    }

    function loadSettings() {
        rootPage.allVars = [];
        hyprManagerProc.running = true;
        qsManagerProc.running = true;
    }

    Component.onCompleted: {
        loadSettings();
    }

    M3Shapes { id: m3Shapes }

    RowLayout {
        Layout.fillWidth: true
        spacing: 12

        Item {
            width: 38
            height: 38

            Image {
                anchors.fill: parent
                sourceSize: Qt.size(width, height)
                source: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><path d='" + m3Shapes.getPath(rootPage.pageShape) + "' fill='" + String(rootPage.pageColor || "#3b383e").replace("#", "%23") + "'/></svg>"
                smooth: true
                antialiasing: true
            }

            Text {
                anchors.centerIn: parent
                text: rootPage.pageIcon
                font.family: "Material Symbols Outlined"
                font.pixelSize: 20
                color: rootPage.pageOnColor
            }
        }

        Text {
            Layout.fillWidth: true
            text: rootPage.pageTitle
            font.family: Vars.fontFamily
            font.pixelSize: 18
            font.weight: 600
            color: Theme.on_surface
            elide: Text.ElideRight
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Vars.spacingMedium

        SearchBar {
            id: searchBar
            Layout.fillWidth: true
            placeholderText: "Search settings..."
            showIcon: true
            iconText: "search"
            defaultHeight: 72
            defaultColor: (Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface_container.r, Theme.surface_container.g, Theme.surface_container.b, 0.5) : Theme.surface_container
            
            onTextChanged: applyFilter()
            onDownPressed: {
                settingsList.forceActiveFocus();
            }
        }

        Button {
            Layout.alignment: Qt.AlignVCenter
            visible: rootPage.activeCategory === "Input"
            onClicked: {
                var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "hyprctl devices -j | jq -r \\".keyboards[].name\\" | while read -r kb; do hyprctl switchxkblayout \\"$kb\\" next; done"]; onExited: destroy() }', rootPage);
                proc.running = true;
            }
            background: Rectangle {
                color: layoutBtnHover.containsMouse ? Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.1) : "transparent"
                radius: Vars.radiusMedium
                implicitHeight: 72
                implicitWidth: layoutBtnContent.implicitWidth + Vars.spacingLarge * 2
            }
            contentItem: RowLayout {
                id: layoutBtnContent
                spacing: 8
                Text { text: "keyboard"; font.family: "Material Symbols Outlined"; color: Theme.on_surface; font.pixelSize: 20 }
                Text { text: "Switch Layout"; color: Theme.on_surface; font.family: Vars.fontFamily; font.bold: true }
            }
            MouseArea {
                id: layoutBtnHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "hyprctl devices -j | jq -r \\".keyboards[].name\\" | while read -r kb; do hyprctl switchxkblayout \\"$kb\\" next; done"]; onExited: destroy() }', rootPage);
                    proc.running = true;
                }
            }
        }

        Button {
            Layout.alignment: Qt.AlignVCenter
            onClicked: loadSettings()
            background: Rectangle {
                color: refreshBtnHover.containsMouse ? Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.1) : "transparent"
                radius: Vars.radiusMedium
                implicitHeight: 72
                implicitWidth: refreshBtnContent.implicitWidth + Vars.spacingLarge * 2
            }
            contentItem: Text {
                id: refreshBtnContent
                text: "Refresh"
                color: Theme.on_surface
                font.family: Vars.fontFamily
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            MouseArea {
                id: refreshBtnHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: loadSettings()
            }
        }
    }

    ListModel {
        id: settingsModel
        ListElement {
            key: ""
            type: ""
            help: ""
            enums: ""
            val: ""
            category: ""
            source: ""
            min: 0.0
            max: 0.0
            step: 0.0
        }
    }

    ListView {
        id: settingsList
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        spacing: 4
        model: settingsModel
        focus: true
        bottomMargin: 112
        KeyNavigation.up: searchBar.searchInput

        // boundsBehavior: Flickable.StopAtBounds
        flickDeceleration: Vars.flickDeceleration
        maximumFlickVelocity: Vars.maximumFlickVelocity

        Keys.onReturnPressed: {
            if (currentItem) {
                currentItem.triggerAction();
            }
        }
        Keys.onSpacePressed: {
            if (currentItem) {
                currentItem.triggerAction();
            }
        }
        Keys.onRightPressed: {
            if (currentItem)
                currentItem.triggerAction();
        }
        
        property bool vimKeysEnabled: false
        Process {
            id: vimKeysChecker
            command: ["bash", "-c", "grep -qi 'vimkeys[ \t]*=[ \t]*true' /home/boing/Dotfiles/hypr/modules/variables.lua && echo 'true' || echo 'false'"]
            running: true
            stdout: StdioCollector {
                onStreamFinished: {
                    settingsList.vimKeysEnabled = (this.text.trim() === 'true');
                }
            }
        }

        Keys.onPressed: (event) => {
            if (settingsList.vimKeysEnabled) {
                if (event.key === Qt.Key_J) {
                    incrementCurrentIndex();
                    event.accepted = true;
                } else if (event.key === Qt.Key_K) {
                    if (currentIndex > 0) {
                        decrementCurrentIndex();
                    } else {
                        searchBar.forceActiveFocus();
                    }
                    event.accepted = true;
                } else if (event.key === Qt.Key_L || event.key === Qt.Key_H) {
                    if (currentItem) currentItem.triggerAction();
                    event.accepted = true;
                }
            }
        }

        section.property: "source"
        section.criteria: ViewSection.FullString
        section.labelPositioning: ViewSection.InlineLabels
        section.delegate: Item {
            width: ListView.view.width
            height: 50
            z: 2

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: section
                color: Theme.primary
                font.pixelSize: 14
                font.bold: true
                font.family: Vars.fontFamily
            }
        }

        delegate: UnifiedSettingsDelegate {
        }
    }

    Process {
        id: hyprManagerProc
        command: ["/home/boing/.local/bin/omniformis", "hypr", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.split("\n");
                var newVars = [];
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim();
                    if (line.length === 0)
                        continue;

                    var openBracketIdx = line.indexOf("[");
                    var closeBracketIdx = line.indexOf("]", openBracketIdx);
                    if (openBracketIdx === -1 || closeBracketIdx === -1)
                        continue;

                    var leftPart = line.substring(0, openBracketIdx).trim();
                    var valPart = line.substring(openBracketIdx + 1, closeBracketIdx);

                    var dashIdx = line.indexOf("- ", closeBracketIdx);
                    var rawHelp = dashIdx !== -1 ? line.substring(dashIdx + 2).trim() : "";
                    var category = "General";
                    var pipeIdx = rawHelp.indexOf(" | ");
                    var helpPart = rawHelp;
                    if (pipeIdx !== -1) {
                        category = rawHelp.substring(0, pipeIdx).trim();
                        category = category.replace(/^-+\s*/, "");
                        helpPart = rawHelp.substring(pipeIdx + 3).trim();
                    }

                    var colonIdx = leftPart.indexOf(":");
                    if (colonIdx === -1) continue;
                    var key = leftPart.substring(0, colonIdx).trim();
                    var typePart = leftPart.substring(colonIdx + 1).trim();

                    // CRITICAL RULE: ALL wallpaper, wallpaper mask, clock, calendar, and desktop widgets MUST route to the "Desktop" category ("Desktop & Widgets"). NEVER place them in "Theme".
                    // Map hyprland variables to specialized UI categories
                    if (key.toLowerCase().includes("wallpaper") || key.toLowerCase().includes("mask") || key.startsWith("desktop")) {
                        category = "Desktop";
                    } else if (key === "gaps_in" || key === "gaps_out" || key === "singleWindowGapsOut" || key === "enableSingleWindowGaps" || key === "enableSpecialWorkspaceGaps" || key === "border_size" || key === "groupBar" || key === "Layout" || key === "resize_on_border") {
                        category = "Layout";
                    } else if (key === "rounding" || key === "rounding_power" || key === "active_opacity" || key === "inactive_opacity" || key === "windowOpacity" || category === "Shadows" || category === "Blur" || key.startsWith("shadow_") || key.startsWith("blur_")) {
                        category = "Theme";
                    } else if (category === "Animation Style" || key === "AnimateStyle" || key.startsWith("Custom")) {
                        category = "Animations";
                    } else if (category === "Modifiers" || category === "Quickshell Keybinds" || key === "MM" || key === "SM" || key === "TM" || key === "QM" || key.startsWith("Qs") || key === "QuickLauncherKey") {
                        category = "Keybinds";
                    } else if (category === "Input" || category === "Gestures" || key.startsWith("kb_") || key.startsWith("gesture_") || key === "follow_mouse" || key === "sensitivity" || key === "touchpad_natural_scroll" || key === "vimkeys") {
                        category = "Input";
                    } else {
                        category = "General";
                    }

                    var type = "string";
                    var enums = [];
                    if (typePart === "togglable bool") {
                        type = "bool";
                    } else if (typePart.startsWith("enum")) {
                        type = "enum";
                        var match = typePart.match(/\((.*)\)/);
                        if (match) {
                            enums = match[1].split(",").map(function (s) {
                                return s.trim();
                            });
                        }
                    } else if (typePart === "number" || typePart === "int") {
                        type = "number";
                    }

                    var min = 0;
                    var max = 0;
                    var step = 0;

                    if (type === "number") {
                        if (key === "gaps_in") {
                            type = "slider";
                            max = 50;
                            step = 1;
                        } else if (key === "gaps_out") {
                            type = "slider";
                            max = 100;
                            step = 1;
                        } else if (key === "singleWindowGapsOut") {
                            type = "slider";
                            max = 100;
                            step = 1;
                        } else if (key === "border_size") {
                            type = "slider";
                            max = 20;
                            step = 1;
                        } else if (key === "rounding") {
                            type = "slider";
                            max = 50;
                            step = 1;
                        } else if (key === "rounding_power") {
                            type = "slider";
                            min = 1.0;
                            max = 50.0;
                            step = 1.0;
                        } else if (key === "active_opacity" || key === "inactive_opacity" || key === "windowOpacity") {
                            type = "slider";
                            min = 0.0;
                            max = 1.0;
                            step = 0.05;
                        } else if (key === "shadow_range") {
                            type = "slider";
                            max = 100;
                            step = 1;
                        } else if (key === "shadow_render_power") {
                            type = "slider";
                            min = 1;
                            max = 4;
                            step = 1;
                        } else if (key === "blur_size") {
                            type = "slider";
                            max = 20;
                            step = 1;
                        } else if (key === "blur_passes") {
                            type = "slider";
                            max = 10;
                            step = 1;
                        } else if (key === "blur_vibrancy") {
                            type = "slider";
                            min = 0.0;
                            max = 1.0;
                            step = 0.05;
                        } else if (key === "gesture_fingers") {
                            type = "slider";
                            min = 3;
                            max = 5;
                            step = 1;
                        } else if (key === "env_xcursor_size" || key === "env_hyprcursor_size") {
                            type = "slider";
                            min = 16;
                            max = 64;
                            step = 2;
                        } else if (key === "vrr") {
                            type = "enum";
                            enums = ["0", "1", "2"];
                        } else if (key === "sensitivity") {
                            type = "slider";
                            min = -1.0;
                            max = 1.0;
                            step = 0.05;
                        }
                    }

                    // Ensure Hyprland enumerable properties use segmented selection chips in UI
                    if (key === "Layout") {
                        type = "enum";
                        enums = ["Scrolling", "Dwindle", "Master", "Monocle"];
                    } else if (key === "gesture_direction") {
                        type = "enum";
                        enums = ["vertical", "horizontal", "both", "all", "none"];
                    } else if (key === "force_default_wallpaper") {
                        type = "enum";
                        enums = ["-1", "0", "1", "2", "3"];
                    } else if (key === "AnimateStyle" && (enums.length === 0 || type !== "enum")) {
                        type = "enum";
                        enums = ["expressive", "spring", "jelly", "flyingcards", "snappy", "cinematic", "minimal", "fluid", "aggressive", "elegant", "playful", "elastic", "swift", "relaxed", "slipstream", "standard", "fluent", "custom", "none"];
                    }

                    newVars.push({
                        key: key,
                        type: type,
                        help: helpPart,
                        enums: enums.join("|||"),
                        val: valPart,
                        category: category,
                        source: "Hyprland",
                        min: min,
                        max: max,
                        step: step
                    });
                }

                rootPage.allVars = rootPage.allVars.concat(newVars);
                applyFilter();
            }
        }
    }

    Process {
        id: qsManagerProc
        command: ["/home/boing/.local/bin/omniformis", "qs", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.split("\n");
                var newVars = [];
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim();
                    if (line.length === 0)
                        continue;

                    var colonIdx = line.indexOf(":");
                    if (colonIdx === -1)
                        continue;

                    var key = line.substring(0, colonIdx).trim();
                    if (key === "notificationHistory" || key === "historyUpdated" || key === "pillPosition" || key === "panelStyle" || key === "translucent" || key === "liquidGlass")
                        continue;

                    var valPart = line.substring(colonIdx + 1).trim();
                    if (valPart.startsWith('"') && valPart.endsWith('"')) {
                        valPart = valPart.substring(1, valPart.length - 1);
                    }

                    var type = "string";
                    if (valPart === "true" || valPart === "false") {
                        type = "bool";
                    } else if (!isNaN(Number(valPart)) && valPart !== "") {
                        type = "number";
                    }

                    // CRITICAL RULE: ALL wallpaper, wallpaper mask, clock, calendar, and desktop widgets MUST route to the "Desktop" category ("Desktop & Widgets"). NEVER place them in "Theme".
                    // Map quickshell variables to specialized UI categories
                    var category = "General";
                    if (key.startsWith("desktop") || key.startsWith("clock") || key.startsWith("mediaPlayer") || key.startsWith("overview") || key.toLowerCase().includes("wallpaper") || key.toLowerCase().includes("mask")) {
                        category = "Desktop";
                    } else if (key.startsWith("spacing") || key.startsWith("padding")) {
                        category = "Layout";
                    } else if (key.startsWith("radius") || key === "blurAmount" || key === "panelOpacity" || key === "componentOpacity" || key === "fontFamily" || key === "liquidGlassPreset") {
                        category = "Theme";
                    } else if (key === "animationDuration" || key === "flickDeceleration" || key === "maximumFlickVelocity" || key.startsWith("custom") || key.startsWith("m3")) {
                        category = "Animations";
                    } else if (key === "gameMode") {
                        category = "General";
                    } else {
                        category = "General";
                    }

                    var min = 0;
                    var max = 0;
                    var step = 0;
                    if (key.includes("Duration")) {
                        type = "slider";
                        min = 0;
                        max = 1000;
                        step = 10;
                    } else if (key === "radiusAmount") {
                        type = "slider";
                        min = 0.0;
                        max = 1.0;
                        step = 0.05;
                    } else if (key.toLowerCase().includes("opacity")) {
                        type = "slider";
                        min = 0.0;
                        max = 1.0;
                        step = 0.1;
                    } else if (key === "blurAmount") {
                        type = "slider";
                        min = 0;
                        max = 100;
                        step = 1;
                    } else if (key === "panelOpacity" || key === "componentOpacity") {
                        type = "slider";
                        min = 0.0;
                        max = 1.0;
                        step = 0.05;
                    } else if (key.startsWith("radius") || key.startsWith("spacing") || key.startsWith("padding")) {
                        type = "slider";
                        min = 0;
                        max = 50;
                        step = 1;
                    } else if (key.includes("Scale")) {
                        type = "slider";
                        min = 0.1;
                        max = 2.0;
                        step = 0.05;
                    } else if (key === "wallpaperMaskOffsetX" || key === "wallpaperMaskOffsetY") {
                        type = "slider";
                        min = -500;
                        max = 500;
                        step = 1;
                    } else if (key.endsWith("AnchorCurve")) {
                        type = "slider";
                        min = 0;
                        max = 20; // Will be overridden in the delegate dynamically
                        step = 1;
                    }

                    var enumsStr = "";
                    if (key === "wallpaperMaskShape") {
                        type = "shape";
                        enumsStr = "Circle|||Square|||Slanted|||Arch|||Flag|||Arrow|||Semicircle|||Oval|||Pill|||Triangle|||Diamond|||Clamshell|||Pentagon|||Gem|||VerySunny|||Sunny|||4SidedCookie|||6SidedCookie|||7SidedCookie|||9SidedCookie|||12SidedCookie|||GhostIsh|||4LeafClover|||8LeafClover|||Burst|||SoftBurst|||Boom|||SoftBoom|||Flower|||Puffy|||PuffyDiamond|||PixelCircle|||PixelTriangle|||Bun|||Heart";
                    } else if (key === "wallpaperMaskColor") {
                        type = "color";
                        enumsStr = "transparent|||background|||primary|||secondary|||tertiary|||surface_variant|||error";
                    } else if (key === "wallpaperMaskEnabled") {
                        type = "bool";
                    } else if (key === "clockShape") {
                        type = "shape";
                        enumsStr = "Circle|||Square|||VerySunny|||Sunny|||4SidedCookie|||6SidedCookie|||7SidedCookie|||9SidedCookie|||12SidedCookie|||SoftBurst|||SoftBoom|||Flower|||Puffy|||Bun";
                    } else if (key === "mediaPlayerShape") {
                        type = "shape";
                        enumsStr = "Circle|||Square|||Slanted|||Arch|||Flag|||Arrow|||Semicircle|||Oval|||Pill|||Triangle|||Diamond|||Clamshell|||Pentagon|||Gem|||VerySunny|||Sunny|||4SidedCookie|||6SidedCookie|||7SidedCookie|||9SidedCookie|||12SidedCookie|||GhostIsh|||4LeafClover|||8LeafClover|||Burst|||SoftBurst|||Boom|||SoftBoom|||Flower|||Puffy|||PuffyDiamond|||PixelCircle|||PixelTriangle|||Bun|||Heart";
                    } else if (key === "panelStyle") {
                        type = "enum";
                        enumsStr = "Floating|||Attached|||Framed";
                    } else if (key === "liquidGlassPreset") {
                        type = "enum";
                        enumsStr = "glass|||apple|||clear|||contrasted";
                    } else if (key.endsWith("AnchorPoint")) {
                        type = "enum";
                        enumsStr = "TopLeft|||TopCenter|||TopRight|||MiddleLeft|||Center|||MiddleRight|||BottomLeft|||BottomCenter|||BottomRight";
                    }

                    newVars.push({
                        key: key,
                        type: type,
                        help: "Quickshell variable",
                        enums: enumsStr,
                        val: valPart,
                        category: category,
                        source: "Quickshell",
                        min: min,
                        max: max,
                        step: step
                    });
                }

                rootPage.allVars = rootPage.allVars.concat(newVars);
                applyFilter();
            }
        }
    }

    function applyFilter() {
        var term = searchBar.text.trim();
        settingsModel.clear();
        var filteredVars = [];
        for (var k = 0; k < rootPage.allVars.length; k++) {
            var v = rootPage.allVars[k];
            if (v.category !== rootPage.activeCategory)
                continue;
            if (term === "" || Vars.fuzzyMatch(term, v.key) || Vars.fuzzyMatch(term, v.help)) {
                filteredVars.push(v);
            }
        }
        filteredVars.sort(function (a, b) {
            if (a.source !== b.source) {
                return a.source.localeCompare(b.source);
            }
            return a.key.localeCompare(b.key);
        });
        for (var i = 0; i < filteredVars.length; i++) {
            settingsModel.append(filteredVars[i]);
        }
    }

    Item {
        id: fabContainer
        Layout.preferredWidth: 0
        Layout.preferredHeight: 0

        Item {
            id: reloadFab
            width: 64
            height: 64
            x: rootPage.width - width - 32 - fabContainer.x
            y: rootPage.height - height - 32 - fabContainer.y
            property real radius: width / 2
            z: 100

            Rectangle {
                id: fabMask
                anchors.fill: parent
                radius: reloadFab.radius
                color: "black"
                visible: false
                layer.enabled: true
                layer.samples: 4
            }

            Item {
                id: shadowContainer
                anchors.fill: parent
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowBlur: 1.0
                    shadowColor: Qt.rgba(0,0,0,0.25)
                    shadowVerticalOffset: 4
                    shadowHorizontalOffset: 0
                }

                Item {
                    id: finalMaskedContainer
                    anchors.fill: parent
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        maskEnabled: true
                        maskSource: fabMask
                    }

                    ShaderEffectSource {
                        anchors.fill: parent
                        sourceItem: settingsList
                        sourceRect: Qt.rect(rootPage.width - reloadFab.width - 32 - settingsList.x, rootPage.height - reloadFab.height - 32 - settingsList.y, reloadFab.width, reloadFab.height)
                        
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            blurEnabled: true
                            blurMax: Vars.blurAmount
                            blur: 1.0
                            autoPaddingEnabled: false
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: reloadFab.radius
                        color: (Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.4) : Theme.primary
                        border.color: Theme.outline_variant
                        border.width: 1
                    }
                }
            }

            Text {
                id: fabIcon
                anchors.centerIn: parent
                text: "refresh"
                font.family: "Material Symbols Outlined"
                font.pixelSize: 28
                color: Theme.on_primary
            }

            SequentialAnimation {
                id: fabShapeAnim
                NumberAnimation {
                    target: reloadFab
                    property: "radius"
                    to: 16
                    duration: 250
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: reloadFab
                    property: "radius"
                    to: 32
                    duration: 250
                    easing.type: Easing.InQuad
                }
                ScriptAction {
                    script: {
                        var reloadCmd = JSON.stringify(["sh", "-c", "setsid bash $HOME/Dotfiles/scripts/reload.sh > /dev/null 2>&1 &"]);
                        var p = Qt.createQmlObject('import Quickshell.Io; Process { command: ' + reloadCmd + '; onExited: destroy() }', rootPage);
                        p.running = true;
                    }
                }
            }

            SequentialAnimation {
                id: fabIconAnim
                RotationAnimation {
                    target: fabIcon
                    property: "rotation"
                    from: 0
                    to: 360
                    duration: 500
                    easing.type: Easing.InOutCubic
                }
                ScriptAction {
                    script: fabIcon.rotation = 0
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (!fabShapeAnim.running) {
                        fabShapeAnim.start();
                        fabIconAnim.start();
                    }
                }
            }
        }
    }
}
