import QtQuick
import QtQuick.Effects
import ".."
import "./ColorSchemeSwitcher" as CS
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtCore

import "../theme/variables.js" as Vars
import "../core/primitives" as Primitives
Item {
    id: root
    
    Layout.preferredWidth: 100
    Layout.preferredHeight: 40
    
    property bool expanded: false
    property bool forceHidePill: false
    property var focusWindow: null
    property bool gameMode: Vars.gameMode !== undefined ? Vars.gameMode : false
    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            if (Vars.gameMode !== undefined && parent.gameMode !== Vars.gameMode) {
                parent.gameMode = Vars.gameMode;
            }
        }
    }
    property alias panel: panel
    property alias panelMask: panelMask

    opacity: forceHidePill ? 0.0 : 1.0
    visible: opacity > 0

    property string currentTheme: ""
    property string currentMode: "dark"

    signal closeRequested()


    
    onExpandedChanged: {
        if (!expanded) {
            MorphState.notifyClosed();
            controlBar.searchText = "";
        } else {
            MorphState.notifyOpened(900, 550, panel.targetRad, panel);
            innerUI.visible = true;
            controlBar.forceSearchFocus();
            innerUI.visible = Qt.binding(() => root.expanded || innerUI.opacity > 0);
            loadThemesProc.running = true;
        }
    }

    Item {
        id: panelMask
                anchors.top: (!Vars.pillPosition || Vars.pillPosition === "Top") ? parent.top : undefined
        anchors.bottom: Vars.pillPosition === "Bottom" ? parent.bottom : undefined
        anchors.left: Vars.pillPosition === "Left" ? parent.left : undefined
        anchors.right: Vars.pillPosition === "Right" ? parent.right : undefined
        anchors.horizontalCenter: (Vars.pillPosition === "Left" || Vars.pillPosition === "Right") ? undefined : parent.horizontalCenter
        anchors.verticalCenter: (Vars.pillPosition === "Left" || Vars.pillPosition === "Right") ? parent.verticalCenter : undefined
        
        anchors.topMargin: -20
        anchors.bottomMargin: -20
        anchors.leftMargin: -20
        anchors.rightMargin: -20
        width: root.expanded ? 440 : 140
        height: root.expanded ? 360 : 80
    }

    Primitives.SquircleMask {
        id: panel
        property bool isBackgroundActive: root.expanded || (MorphState.openCount === 0 && MorphState.activeItem === panel && panel.width > 105)
        layer.enabled: false
        anchors.top: (!Vars.pillPosition || Vars.pillPosition === "Top") ? parent.top : undefined
        anchors.bottom: Vars.pillPosition === "Bottom" ? parent.bottom : undefined
        anchors.left: Vars.pillPosition === "Left" ? parent.left : undefined
        anchors.right: Vars.pillPosition === "Right" ? parent.right : undefined
        anchors.horizontalCenter: (Vars.pillPosition === "Left" || Vars.pillPosition === "Right") ? undefined : parent.horizontalCenter
        anchors.verticalCenter: (Vars.pillPosition === "Left" || Vars.pillPosition === "Right") ? parent.verticalCenter : undefined
        
        width: root.expanded ? 900 : (MorphState.anyExpanded ? MorphState.targetWidth : 100)
        height: root.expanded ? 550 : (MorphState.anyExpanded ? MorphState.targetHeight : 40)
        
        color: Vars.tColorActive(isBackgroundActive, Theme.surface, Vars.panelOpacity)
        property real targetRad: root.expanded ? Vars.radiusExtraLarge : (MorphState.anyExpanded ? MorphState.targetRadius : height / 2)
        topLeftRadius: Vars.getTopLeftRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)
        topRightRadius: Vars.getTopRightRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)
        bottomLeftRadius: Vars.getBottomLeftRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)
        bottomRightRadius: Vars.getBottomRightRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)
        
        opacity: isBackgroundActive || innerUI.opacity > 0 ? 1.0 : 0.0
        visible: opacity > 0

        Behavior on topLeftRadius { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on topRightRadius { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on bottomLeftRadius { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on bottomRightRadius { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on width { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on height { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }

        Item {
            id: innerUI
            anchors.fill: parent
            anchors.margins: Vars.spacingLarge
            
            opacity: root.expanded ? 1.0 : 0.0
            visible: root.expanded || opacity > 0
            Behavior on opacity { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: root.expanded ? Vars.customEmphasizedDecelerate : Vars.customEmphasizedAccelerate } }

            ColumnLayout {
                anchors.fill: parent
                spacing: Vars.spacingMedium

                CS.ControlBar {
                    id: controlBar
                    Layout.fillWidth: true
                    currentTheme: root.currentTheme
                    currentMode: root.currentMode

                    onEscapePressed: root.expanded = false
                    onSearchDownPressed: themeGrid.forceActiveFocus()
                    onModeToggled: {
                        root.currentMode = root.currentMode === "dark" ? "light" : "dark";
                        if (root.currentTheme !== "") {
                            root.executeThemeChange(root.currentTheme);
                        }
                    }
                    onRefreshClicked: loadThemesProc.running = true
                }

                CS.ThemeGrid {
                    id: themeGrid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: sortFilterProxyModel.proxyModel
                    currentTheme: root.currentTheme
                    searchInput: controlBar

                    onThemeSelected: (themeName) => {
                        root.executeThemeChange(themeName);
                        root.expanded = false;
                    }
                    onEscapePressed: root.expanded = false
                }
            }
        }
    }

    function executeThemeChange(themeName) {
        console.log("[USER ACTION] Theme selected: " + themeName + " (" + root.currentMode + ")");
        root.currentTheme = themeName;
        themeChangeProc.command = ["bash", "-c", "bash ~/.config/color-schemes/set-theme.sh '" + themeName + "' '" + root.currentMode + "'"];
        themeChangeProc.running = true;
    }

    Process {
        id: themeChangeProc
        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text.trim().length > 0)
                    console.log("[THEME CHANGE STDOUT]\n" + this.text);
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.trim().length > 0)
                    console.error("[THEME CHANGE STDERR]\n" + this.text);
            }
        }
    }

    ListModel { id: themeModel }

    QtObject {
        id: sortFilterProxyModel
        property string filterText: controlBar.searchText
        onFilterTextChanged: updateVisualGrid()
        function updateVisualGrid() {
            proxyModel.clear();
            for (var i = 0; i < themeModel.count; i++) {
                var item = themeModel.get(i);
                if (Vars.fuzzyMatch(filterText, item.themeName)) {
                    proxyModel.append({ "themeName": item.themeName, "themePrimary": item.themePrimary });
                }
            }
        }
        property ListModel proxyModel: ListModel {}
    }

    Process {
        id: loadThemesProc
        // Get directory names and their primary color from dark/quickTheme.qml
        command: ["bash", "-c", "for d in ~/.config/color-schemes/*/; do name=$(basename \"$d\"); if [ \"$name\" != \"current\" ] && [ \"$name\" != \"currect\" ]; then primary=$(grep 'readonly property color primary:' \"$d/dark/quickTheme.qml\" 2>/dev/null | cut -d'\"' -f2); echo \"$name|$primary\"; fi; done"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                themeModel.clear();
                var lines = this.text.split("\n");
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim();
                    if (line.length > 0) {
                        var parts = line.split("|");
                        var name = parts[0];
                        var primary = parts.length > 1 && parts[1] ? parts[1] : "#cccccc";
                        themeModel.append({ "themeName": name, "themePrimary": primary });
                    }
                }
                sortFilterProxyModel.updateVisualGrid();
            }
        }
    }
}
