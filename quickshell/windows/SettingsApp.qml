import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Networking
import Quickshell.Bluetooth
import "../theme/variables.js" as Vars
import "SettingsApp"
import ".."

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
    property var allVars: []
    property alias panel: panel
    property alias panelMask: panelMask
    
    property bool isFloatingInstance: false
    signal detachToggled(bool isFloating)
    
    property string currentSection: "quick"
    signal openWallpaperSwitcherRequested()
    
    // Wi-Fi
    property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
    property var activeNet: wifiDevice ? wifiDevice.networks.values.find(n => n.connected) : null
    property var wifiSignal: activeNet ? activeNet.signalStrength : 0

    readonly property string wifiIcon: {
        if (!Networking.wifiEnabled) return "\ue1da"; 
        if (!activeNet) return "\uf067"; 
        let tier = Math.min(Math.floor(wifiSignal / 25), 3);
        let icons = ["\ue1ba", "\uebe4", "\uebd6", "\uebe1"];
        return icons[tier];
    }
    
    // Bluetooth
    property var adapter: Bluetooth.defaultAdapter
    property bool adapterState: adapter ? adapter.enabled : false
    property var connectDevice: adapter ? adapter.devices.values.find(d => d.connected) : null

    readonly property string bluetoothIcon: {
        if (!adapterState) return "\ue1a9"; 
        if (!connectDevice) return "\ue1a7"; 
        return "\ue1a8"; 
    }
    
    opacity: forceHidePill ? 0.0 : 1.0
    visible: opacity > 0
    signal closeRequested()
    onExpandedChanged: {
        if (expanded) MorphState.notifyOpened(root.isFloatingInstance ? root.width : 1320, root.isFloatingInstance ? root.height : 740, panel.targetRad, panel);
        else MorphState.notifyClosed();
    }


    
    Item {
        id: panelMask
        anchors.centerIn: panel
        width: panel.width + 40
        height: panel.height + 40
    }
    
    Rectangle {
        id: panel
        property bool isBackgroundActive: root.expanded || (MorphState.openCount === 0 && MorphState.activeItem === panel && panel.width > 105)
        layer.enabled: true
        layer.effect: MultiEffect { shadowEnabled: !root.gameMode && panel.isBackgroundActive; shadowBlur: 1.0; shadowColor: Qt.rgba(0,0,0,0.25); shadowVerticalOffset: 4; shadowHorizontalOffset: 0 }
        anchors.top: (!Vars.pillPosition || Vars.pillPosition === "Top" || root.isFloatingInstance) ? parent.top : undefined
        anchors.bottom: (!root.isFloatingInstance && Vars.pillPosition === "Bottom") ? parent.bottom : undefined
        anchors.left: (!root.isFloatingInstance && Vars.pillPosition === "Left") ? parent.left : undefined
        anchors.right: (!root.isFloatingInstance && Vars.pillPosition === "Right") ? parent.right : undefined
        anchors.horizontalCenter: (!root.isFloatingInstance && (Vars.pillPosition === "Left" || Vars.pillPosition === "Right")) ? undefined : parent.horizontalCenter
        anchors.verticalCenter: (!root.isFloatingInstance && (Vars.pillPosition === "Left" || Vars.pillPosition === "Right")) ? parent.verticalCenter : undefined
        
        width: root.expanded ? (root.isFloatingInstance ? root.width : 1320) : (MorphState.anyExpanded ? MorphState.targetWidth : 100)
        height: root.expanded ? (root.isFloatingInstance ? root.height : 740) : (MorphState.anyExpanded ? MorphState.targetHeight : 40)
        
        color: isBackgroundActive ? (Vars.translucent ? Qt.rgba(Theme.surface_container_low.r, Theme.surface_container_low.g, Theme.surface_container_low.b, Vars.panelOpacity) : Theme.surface_container_low) : "transparent"
        property real targetRad: root.expanded ? Vars.radiusExtraLarge : (MorphState.anyExpanded ? MorphState.targetRadius : height / 2)
        topLeftRadius: root.isFloatingInstance ? Vars.radiusExtraLarge : Vars.getTopLeftRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)
        topRightRadius: root.isFloatingInstance ? Vars.radiusExtraLarge : Vars.getTopRightRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)
        bottomLeftRadius: root.isFloatingInstance ? Vars.radiusExtraLarge : Vars.getBottomLeftRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)
        bottomRightRadius: root.isFloatingInstance ? Vars.radiusExtraLarge : Vars.getBottomRightRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)
        
        opacity: isBackgroundActive || innerUI.opacity > 0 ? 1.0 : 0.0
        // visible: opacity > 0 // Removed to preserve Behavior when hidden

        Behavior on topLeftRadius { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on topRightRadius { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on bottomLeftRadius { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on bottomRightRadius { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on width { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on height { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }

        Item {
            id: innerUI
            anchors.centerIn: parent
            width: Math.max(1, parent.width - Vars.spacingLarge * 2)
            height: Math.max(1, parent.height - Vars.spacingLarge * 2)
            
            opacity: root.expanded ? 1.0 : 0.0
            visible: opacity > 0
            clip: true
            Behavior on opacity { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: root.expanded ? Vars.customEmphasizedDecelerate : Vars.customEmphasizedAccelerate } }

            Loader {
                anchors.fill: parent
                active: root.expanded || parent.opacity > 0
                asynchronous: false
                sourceComponent: RowLayout {
                anchors.fill: parent
                spacing: Vars.spacingLarge

                // Sidebar
                ColumnLayout {
                    Layout.preferredWidth: 280
                    Layout.maximumWidth: 280
                    Layout.fillHeight: true
                    spacing: Vars.spacingMedium

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Vars.spacingMedium

                        Rectangle {
                            width: 48; height: 48; radius: Vars.radiusMedium
                            color: backHover.pressed ? Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.12) : (backHover.containsMouse ? Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08) : "transparent")
                            Text { anchors.centerIn: parent; font.family: "Material Symbols Outlined"; font.pixelSize: 20; color: Theme.on_surface; text: "\ue5cd" }
                            MouseArea { id: backHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.expanded = false }
                            Behavior on color { ColorAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard } }
                        }
                        
                        Rectangle {
                            width: 48; height: 48; radius: Vars.radiusMedium
                            color: detachHover.pressed ? Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.12) : (detachHover.containsMouse ? Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08) : "transparent")
                            Text { anchors.centerIn: parent; font.family: "Material Symbols Outlined"; font.pixelSize: 20; color: Theme.on_surface; text: root.isFloatingInstance ? "\ue5ce" : "\ue89b" }
                            MouseArea { 
                                id: detachHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; 
                                onClicked: {
                                    root.expanded = false; 
                                    root.detachToggled(!root.isFloatingInstance);
                                }
                            }
                            Behavior on color { ColorAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard } }
                        }
                        
                        Text {
                            text: "Settings"
                            font.family: Vars.fontFamily
                            font.pixelSize: 24
                            font.weight: 700
                            color: Theme.on_surface
                        }
                    }

                    Item { Layout.preferredHeight: Vars.spacingSmall }

                    // Navigation Items
                    Flickable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentHeight: sidebar.implicitHeight
                        clip: true
                        interactive: true
                        // boundsBehavior: Flickable.StopAtBounds

                        SettingsSidebar {
                            id: sidebar
                            width: parent.width
                            currentSection: root.currentSection
                            wifiIcon: root.wifiIcon
                            bluetoothIcon: root.bluetoothIcon
                            onCurrentSectionChanged: {
                                if (root.currentSection !== currentSection) {
                                    root.currentSection = currentSection
                                }
                            }
                        }
                    }
                }

                // Vertical Divider
                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 1
                    color: Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.2)
                }

                // Content Area
                StackLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: {
                        if (root.currentSection === "quick") return 0;
                        if (root.currentSection === "bezier") return 2;
                        if (root.currentSection === "wifi") return 3;
                        if (root.currentSection === "bluetooth") return 4;
                        if (root.currentSection === "about") return 5;
                        if (root.currentSection === "taskmanager") return 6;
                        return 1; // "General", "Input", "Keybinds", "Desktop", "Layout", "Theme", "Animations" map to UnifiedSettingsPage
                    }

                    // 0: Quick Page & Presets
                    QuickPage {
                        id: quickPage
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        onOpenWallpaperSwitcher: {
                            root.openWallpaperSwitcherRequested();
                        }
                    }

                    // 1: Unified Settings (Hyprland + Quickshell)
                    UnifiedSettingsPage {
                        id: unifiedPage
                        activeCategory: (root.currentSection === "General" || root.currentSection === "Input" || root.currentSection === "Keybinds" || root.currentSection === "Desktop" || root.currentSection === "Layout" || root.currentSection === "Theme" || root.currentSection === "Animations") ? root.currentSection : "General"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    // 1: Bezier Editor
                    BezierEditorPage {
                        id: bezierPage
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        onSettingsChanged: {
                            unifiedPage.loadSettings();
                        }
                    }

                    // 2: Wi-Fi Settings
                    WifiPage {
                        id: wifiPage
                        wifiDevice: root.wifiDevice
                        panelRef: root.panel
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    // 3: Bluetooth Settings
                    BluetoothPage {
                        id: bluetoothPage
                        adapter: root.adapter
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                    
                    // 4: About Page
                    AboutPage {
                        id: aboutPage
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                    
                    // 5: Task Manager Page
                    TaskManagerPage {
                        id: taskManagerPage
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
                }
            }
        }
    }
}
