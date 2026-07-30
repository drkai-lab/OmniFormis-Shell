import QtQuick
import QtQuick.Effects
import ".."
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import Quickshell.Services.SystemTray
import Quickshell.Hyprland
import QtCore
import "../theme/variables.js" as Vars
import "ControlCenter" as CC

Item {
    id: root
    
    // Fixed layout footprint - never animates, no parent relayout
    Layout.preferredWidth: 100
    Layout.preferredHeight: 40
    
    property bool expanded: false
    property var focusWindow: null
    property bool forceHidePill: false
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

    // Navigation state: "" (Main Dashboard), "wifi" (Wi-Fi Settings), "bluetooth" (Bluetooth Settings)
    property string currentSubMenu: ""
    property bool isEditorMode: false
    property string systemUptime: ""

    // Custom M3 System Tray Menu state & positioning
    property var activeTrayMenu: null
    property real trayMenuX: 0
    property real trayMenuY: 0

    Process {
        id: uptimeProc
        command: ["uptime"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                let output = this.text.trim();
                if (output !== "") {
                    let tokens = output.split(/\s+/).filter(t => t !== "");
                    if (tokens.length >= 3) {
                        // 1st: 04:22:28, 2nd: up, 3rd: 1:02,
                        root.systemUptime = tokens[2].replace(",", "");
                    } else {
                        root.systemUptime = output;
                    }
                }
            }
        }
    }
    Timer {
        interval: 60000 // Refresh every minute
        running: root.expanded
        repeat: true
        onTriggered: uptimeProc.running = true
    }
    
    signal closeRequested()
    signal popupOpened()
    signal openColorSchemeRequested()
    signal openSettingsRequested()
    signal openWallpaperRequested()
    signal openPowerMenuRequested()
    signal openOverviewRequested()
    
    // Expose the visual panel for mask tracking in TopPills
    property alias panel: panel
    property alias panelMask: panelMask

    HyprlandFocusGrab {
        active: root.expanded && root.focusWindow !== null
        windows: root.focusWindow ? [root.focusWindow] : []
        onCleared: root.expanded = false
    }
    
    focus: root.expanded
    onExpandedChanged: {
        if (expanded) {
            MorphState.notifyOpened(600, panel.targetHeight);
            forceActiveFocus();
            uptimeProc.running = true;
        } else {
            MorphState.notifyClosed();
            isEditorMode = false;
            currentSubMenu = "";
            activeTrayMenu = null;
        }
    }
    Keys.onEscapePressed: {
        root.expanded = false;
    }

    Item {
        id: panelMask
        anchors.centerIn: panel
        width: panel.width + 40
        height: panel.height + 40
    }

    // The visual panel that animates independently of the layout
    Rectangle {
        id: panel
        layer.enabled: true
        layer.samples: 4
        layer.effect: MultiEffect { shadowEnabled: !root.gameMode; shadowBlur: 1.0; shadowColor: Qt.rgba(0,0,0,0.25); shadowVerticalOffset: 4; shadowHorizontalOffset: 0 }
        anchors.top: (!Vars.pillPosition || Vars.pillPosition === "Top") ? parent.top : undefined
        anchors.bottom: Vars.pillPosition === "Bottom" ? parent.bottom : undefined
        anchors.left: Vars.pillPosition === "Left" ? parent.left : undefined
        anchors.right: Vars.pillPosition === "Right" ? parent.right : undefined
        anchors.horizontalCenter: (Vars.pillPosition === "Left" || Vars.pillPosition === "Right") ? undefined : parent.horizontalCenter
        anchors.verticalCenter: (Vars.pillPosition === "Left" || Vars.pillPosition === "Right") ? parent.verticalCenter : undefined
        
        property real targetHeight: {
            if (!root.expanded) return MorphState.anyExpanded ? MorphState.targetHeight : 40;
            if (root.currentSubMenu === "wifi") return Math.min(800, wifiMenuObj.implicitHeight + (Vars.spacingLarge * 2));
            if (root.currentSubMenu === "bluetooth") return Math.min(800, bluetoothMenuObj.implicitHeight + (Vars.spacingLarge * 2));
            if (root.currentSubMenu === "display") return Math.min(800, displayMenuObj.implicitHeight + (Vars.spacingLarge * 2));
            return 660; // Main dashboard
        }
        
        width: root.expanded ? 600 : (MorphState.anyExpanded ? MorphState.targetWidth : 100)
        height: targetHeight
        
        color: Vars.translucent ? Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.85) : Theme.surface
        property real targetRad: root.expanded ? Vars.radiusExtraLarge : height / 2
        topLeftRadius: Vars.getTopLeftRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)
        topRightRadius: Vars.getTopRightRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)
        bottomLeftRadius: Vars.getBottomLeftRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)
        bottomRightRadius: Vars.getBottomRightRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)
        
        opacity: root.expanded || panel.width > 105 ? 1.0 : 0.0
        visible: opacity > 0

        Behavior on radius { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on width { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on height { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }

        // EXPANDED PANEL CONTAINER
        Item {
            id: expandedUI
            anchors.fill: parent
            
            opacity: root.expanded ? 1.0 : 0.0
            visible: opacity > 0
            clip: true
            Behavior on opacity { enabled: !root.gameMode; SequentialAnimation { PauseAnimation { duration: root.expanded ? Vars.animationDuration : 0 } NumberAnimation { duration: root.expanded ? Vars.animationDuration : Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: root.expanded ? Vars.customEmphasizedDecelerate : Vars.customEmphasizedAccelerate } } }

            // ------------------------------------------
            // VIEW 1: MAIN DASHBOARD MENU
            // ------------------------------------------
            Flickable {
                id: mainDashboardFlickable
                anchors.fill: parent
                anchors.margins: Vars.spacingLarge * 1.5
                contentHeight: mainDashboardView.implicitHeight
                interactive: true
                
                onContentYChanged: {
                    if (root.activeTrayMenu !== null) {
                        root.activeTrayMenu = null;
                    }
                }
                
                opacity: root.currentSubMenu === "" ? 1.0 : 0.0
                visible: opacity > 0
                transform: Translate {
                    x: root.currentSubMenu === "" ? 0 : -40
                    Behavior on x { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
                }
                Behavior on opacity { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: root.currentSubMenu === "" ? Vars.customEmphasizedDecelerate : Vars.customEmphasizedAccelerate } }
                clip: true
                // boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: mainDashboardView
                    width: mainDashboardFlickable.width
                    spacing: Vars.spacingMedium

                    // Header Row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        
                        Rectangle {
                            Layout.preferredHeight: 40
                            Layout.preferredWidth: logoLayout.implicitWidth + 16
                            radius: 20
                            color: Vars.translucent ? Qt.rgba(Theme.surface_container_high.r, Theme.surface_container_high.g, Theme.surface_container_high.b, 0.85) : Theme.surface_container_high
                            clip: true
                            
                            RowLayout {
                                id: logoLayout
                                anchors.centerIn: parent
                                spacing: 8
                                
                                Image {
                                    source: typeof globalOsIconPath !== "undefined" && globalOsIconPath !== "" ? globalOsIconPath : ""
                                    fillMode: Image.PreserveAspectFit
                                    Layout.preferredHeight: 28
                                    Layout.preferredWidth: source.toString() !== "" ? 28 : 0
                                    visible: source.toString() !== ""
                                    smooth: true
                                    antialiasing: true
                                }
                                Text { 
                                    text: (typeof globalOsIconPath !== "undefined" && globalOsIconPath !== "") ? "" : "Control Center"; 
                                    font.family: Vars.fontFamily; 
                                    font.pixelSize: 18; 
                                    font.weight: Font.Bold; 
                                    color: Theme.on_surface;
                                    visible: text !== ""
                                }
                                Rectangle {
                                    Layout.preferredWidth: 4
                                    Layout.preferredHeight: 4
                                    Layout.alignment: Qt.AlignVCenter
                                    radius: 2
                                    color: Theme.primary
                                    visible: root.systemUptime !== ""
                                }
                                Text {
                                    text: root.systemUptime
                                    font.family: Vars.fontFamily
                                    font.pixelSize: 18
                                    font.weight: Font.Medium
                                    color: Theme.primary
                                    visible: root.systemUptime !== ""
                                }
                                Rectangle {
                                    Layout.preferredWidth: 4
                                    Layout.preferredHeight: 4
                                    Layout.alignment: Qt.AlignVCenter
                                    radius: 2
                                    color: Theme.primary
                                    visible: trayRepeater.count > 0
                                }
                                RowLayout {
                                    id: trayLayout
                                    spacing: 2
                                    visible: trayRepeater.count > 0
                                    Layout.preferredWidth: implicitWidth
                                    Layout.preferredHeight: implicitHeight
                                    Layout.alignment: Qt.AlignVCenter

                                    Repeater {
                                        id: trayRepeater
                                        model: SystemTray.items

                                        delegate: Rectangle {
                                            id: trayPill
                                            Layout.preferredWidth: 28
                                            Layout.preferredHeight: 28
                                            Layout.alignment: Qt.AlignVCenter
                                            
                                            color: itemMouseArea.pressed ? Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.12) : (itemMouseArea.containsMouse ? Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08) : "transparent")
                                            radius: height / 2

                                            Behavior on color {
                                                ColorAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard }
                                            }

                                            property var trayItem: modelData 

                                            MouseArea {
                                                id: itemMouseArea
                                                anchors.fill: parent
                                                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor

                                                onClicked: (mouse) => {
                                                    if (!trayItem) return;
                                                    if (mouse.button === Qt.RightButton && trayItem.menu) {
                                                        if (root.activeTrayMenu === trayItem.menu) {
                                                            root.activeTrayMenu = null;
                                                        } else {
                                                            var pillCoords = trayPill.mapToItem(expandedUI, 0, trayPill.height);
                                                            root.trayMenuX = pillCoords.x - 40;
                                                            root.trayMenuY = pillCoords.y + 6;
                                                            root.activeTrayMenu = trayItem.menu;
                                                        }
                                                    } else if (mouse.button === Qt.LeftButton) {
                                                        root.activeTrayMenu = null;
                                                        trayItem.activate();
                                                        root.expanded = false;
                                                    } else if (mouse.button === Qt.MiddleButton && typeof trayItem.secondaryActivate === "function") {
                                                        root.activeTrayMenu = null;
                                                        trayItem.secondaryActivate();
                                                    }
                                                }
                                            }

                                            Image {
                                                id: itemIcon
                                                width: 20
                                                height: 20
                                                anchors.centerIn: parent
                                                source: trayItem && trayItem.icon ? trayItem.icon : "" 
                                                fillMode: Image.PreserveAspectFit
                                                
                                                opacity: itemMouseArea.containsMouse ? 1.0 : 0.7
                                                Behavior on opacity { NumberAnimation { duration: Vars.animationDuration } }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Rectangle {
                            Layout.preferredHeight: 40
                            Layout.preferredWidth: btnLayout.implicitWidth + 16
                            radius: 20
                            color: Vars.translucent ? Qt.rgba(Theme.surface_container_high.r, Theme.surface_container_high.g, Theme.surface_container_high.b, 0.85) : Theme.surface_container_high
                            clip: true
                            
                            RowLayout {
                                id: btnLayout
                                anchors.centerIn: parent
                                spacing: 4
                                
                                // Edit Button
                                Rectangle {
                                    Layout.preferredWidth: 32; Layout.preferredHeight: 32; radius: 16
                                    color: editHover.pressed ? Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.12) : (editHover.containsMouse || root.isEditorMode ? Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08) : "transparent")
                                    Text { anchors.centerIn: parent; font.family: "Material Symbols Outlined"; font.pixelSize: 18; color: root.isEditorMode ? Theme.primary : Theme.on_surface; text: "edit" }
                                    MouseArea { 
                                        id: editHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; 
                                        onClicked: root.isEditorMode = !root.isEditorMode 
                                    }
                                    Behavior on radius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
                                    Behavior on color { ColorAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard } }
                                }
                                
                                // Refresh Button
                                Rectangle {
                                    Layout.preferredWidth: 32; Layout.preferredHeight: 32; radius: 16
                                    color: refreshHover.pressed ? Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.12) : (refreshHover.containsMouse ? Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08) : "transparent")
                                    Text { 
                                        id: refreshIcon
                                        anchors.centerIn: parent; font.family: "Material Symbols Outlined"; font.pixelSize: 18; color: Theme.on_surface; text: "refresh" 
                                        RotationAnimation {
                                            id: refreshAnim
                                            target: refreshIcon
                                            property: "rotation"
                                            from: 0; to: 360
                                            duration: 700
                                            easing.type: Easing.BezierSpline
                                            easing.bezierCurve: Vars.customExpressiveSpatialSlow
                                        }
                                    }
                                    MouseArea { 
                                        id: refreshHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; 
                                        onClicked: {
                                            refreshAnim.restart();
                                            Quickshell.execDetached({ command: ["bash", "-c", "nohup bash ~/Dotfiles/scripts/reload.sh >/dev/null 2>&1 &"] });
                                        }
                                    }
                                    Behavior on color { ColorAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard } }
                                }
                                
                                // Settings Button
                                Rectangle {
                                    Layout.preferredWidth: 32; Layout.preferredHeight: 32; radius: 16
                                    color: settingsHover.pressed ? Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.12) : (settingsHover.containsMouse ? Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08) : "transparent")
                                    Text { 
                                        id: settingsIcon
                                        anchors.centerIn: parent; font.family: "Material Symbols Outlined"; font.pixelSize: 18; color: Theme.on_surface; text: "settings" 
                                        RotationAnimation {
                                            id: settingsAnim
                                            target: settingsIcon
                                            property: "rotation"
                                            from: 0; to: 360
                                            duration: 700
                                            easing.type: Easing.BezierSpline
                                            easing.bezierCurve: Vars.customExpressiveSpatialSlow
                                        }
                                    }
                                    MouseArea { 
                                        id: settingsHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; 
                                        onClicked: { 
                                            settingsAnim.restart();
                                            root.expanded = false; 
                                            root.openSettingsRequested();
                                        } 
                                    }
                                    Behavior on color { ColorAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard } }
                                }
                                
                                // Power Button
                                Rectangle {
                                    Layout.preferredWidth: 32; Layout.preferredHeight: 32; radius: 16
                                    color: powerHover.pressed ? Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.12) : (powerHover.containsMouse ? Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08) : "transparent")
                                    Text { anchors.centerIn: parent; font.family: "Material Symbols Outlined"; font.pixelSize: 18; color: Theme.on_surface; text: "power_settings_new" }
                                    MouseArea { 
                                        id: powerHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; 
                                        onClicked: { root.expanded = false; root.openPowerMenuRequested() } 
                                    }
                                    Behavior on color { ColorAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard } }
                                }
                            }
                        }
                    }

                    // Modular Components
                    CC.ModuleGrid {
                        isEditorMode: root.isEditorMode
                        gameMode: root.gameMode
                        onSubMenuRequested: (menuName) => { root.currentSubMenu = menuName; }
                        onOpenColorSchemeRequested: { root.expanded = false; root.openColorSchemeRequested() }
                        onOpenSettingsRequested: { root.expanded = false; root.openSettingsRequested() }
                        onOpenWallpaperRequested: { root.expanded = false; root.openWallpaperRequested() }
                        onOpenOverviewRequested: { root.expanded = false; root.openOverviewRequested() }
                    }

                    CC.Sliders { }
                    CC.MediaPlayer { }
                    CC.Notifications { }
                }
            }

            // ------------------------------------------
            // SUB-MENUS
            // ------------------------------------------
            CC.WifiMenu {
                id: wifiMenuObj
                isActive: root.currentSubMenu === "wifi"
                onBackRequested: { root.currentSubMenu = "" }
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
            }
            
            CC.BluetoothMenu {
                id: bluetoothMenuObj
                isActive: root.currentSubMenu === "bluetooth"
                onBackRequested: { root.currentSubMenu = "" }
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
            }
            
            CC.DisplayMenu {
                id: displayMenuObj
                isActive: root.currentSubMenu === "display"
                onBackRequested: { root.currentSubMenu = "" }
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
            }

            // ------------------------------------------
            // CUSTOM M3 SYSTEM TRAY CONTEXT MENU
            // ------------------------------------------
            QsMenuOpener {
                id: trayMenuOpener
                menu: root.activeTrayMenu
            }

            // Backdrop area to cleanly dismiss menu when clicking anywhere outside
            MouseArea {
                anchors.fill: parent
                enabled: root.activeTrayMenu !== null
                visible: enabled
                onClicked: {
                    root.activeTrayMenu = null;
                }
            }

            Rectangle {
                id: trayMenuPopup
                x: Math.max(10, Math.min(expandedUI.width - width - 10, root.trayMenuX))
                y: Math.min(expandedUI.height - height - 10, root.trayMenuY)
                width: Math.max(150, menuColumn.implicitWidth + 8)
                height: menuColumn.implicitHeight + 8
                
                color: Theme.surface_container_highest
                radius: Vars.radiusMedium
                border.width: 1
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                clip: true
                
                layer.enabled: !root.gameMode
                layer.samples: 4
                layer.effect: MultiEffect { shadowEnabled: true; shadowBlur: 1.0; shadowColor: Qt.rgba(0,0,0,0.35); shadowVerticalOffset: 6; shadowHorizontalOffset: 0 }

                transformOrigin: Item.Top
                opacity: root.activeTrayMenu !== null ? 1.0 : 0.0
                visible: opacity > 0
                scale: root.activeTrayMenu !== null ? 1.0 : 0.88

                Behavior on opacity { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: root.activeTrayMenu !== null ? Vars.customEmphasizedDecelerate : Vars.customEmphasizedAccelerate } }
                Behavior on scale { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
                Behavior on x { enabled: root.activeTrayMenu !== null && trayMenuPopup.opacity > 0.5; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
                Behavior on y { enabled: root.activeTrayMenu !== null && trayMenuPopup.opacity > 0.5; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }

                ColumnLayout {
                    id: menuColumn
                    anchors.centerIn: parent
                    spacing: 1
                    width: trayMenuPopup.width - 8

                    Repeater {
                        model: trayMenuOpener.children

                        delegate: Item {
                            id: entryItem
                            Layout.fillWidth: true
                            Layout.preferredHeight: modelData && modelData.isSeparator ? 7 : 28
                            property var entry: modelData

                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width - 8
                                height: 1
                                color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.15)
                                visible: entry && entry.isSeparator
                            }

                            Rectangle {
                                anchors.fill: parent
                                visible: entry && !entry.isSeparator
                                color: entryMouseArea.pressed ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.18) : (entryMouseArea.containsMouse ? Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08) : "transparent")
                                radius: Vars.radiusSmall || 4
                                Behavior on color { ColorAnimation { duration: 120 } }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    spacing: 6

                                    Image {
                                        source: entry && entry.icon ? entry.icon : ""
                                        Layout.preferredWidth: source.toString() !== "" ? 16 : 0
                                        Layout.preferredHeight: 16
                                        fillMode: Image.PreserveAspectFit
                                        visible: source.toString() !== ""
                                        smooth: true
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: entry && entry.text ? entry.text.replace(/&/g, "") : ""
                                        font.family: Vars.fontFamily
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        color: entry && entry.enabled !== false ? Theme.on_surface : Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.4)
                                        elide: Text.ElideRight
                                    }
                                }

                                MouseArea {
                                    id: entryMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: entry && entry.enabled !== false
                                    cursorShape: entry && entry.enabled !== false ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: {
                                        if (!entry || entry.enabled === false) return;
                                        if (typeof entry.triggered === "function") {
                                            entry.triggered();
                                        } else if (typeof entry.trigger === "function") {
                                            entry.trigger();
                                        }
                                        root.activeTrayMenu = null;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}