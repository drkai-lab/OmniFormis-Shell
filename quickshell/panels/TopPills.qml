import QtQuick
import QtQuick.Effects
import ".."
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import "../theme/variables.js" as Vars

PanelWindow {
    id: topWindow
    
    signal toggleFloatingSettings()
    
    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    WlrLayershell.namespace: "quickshell"
    WlrLayershell.layer: WlrLayer.Top
    property bool hasAnyPopupOpen: launcherItem.expanded || controlCenterItem.expanded || wallpaperSwitcherItem.expanded || colorSchemeSwitcherItem.expanded || powerMenuItem.expanded || polkitItem.expanded || emojiPickerItem.expanded || settingsAppItem.expanded
    WlrLayershell.keyboardFocus: hasAnyPopupOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    implicitHeight: 750
    color: "transparent"

    property bool _forceDropGrab: false

    HyprlandFocusGrab {
        id: globalFocusGrab
        windows: [topWindow]
        onActiveChanged: console.log("[DEBUG] HyprlandFocusGrab active changed to:", active)
        active: !_forceDropGrab && topWindow.hasAnyPopupOpen
        onCleared: {
            console.log("[DEBUG] HyprlandFocusGrab onCleared fired! active:", active);
            if (active) {
                // Delay close so screenshot tools (grimblast/slurp) that briefly
                // steal focus don't cause panels to vanish before the capture frame.
                focusLostCloseTimer.restart();
            }
        }
    }

    Timer {
        id: focusLostCloseTimer
        interval: 400
        repeat: false
        onTriggered: {
            // Only close if focus grab is still gone (not a brief screenshot tool steal)
            if (!globalFocusGrab.active && !_forceDropGrab) {
                closeAll();
            }
        }
    }

    property string pillPos: Vars.pillPosition || "Top"
    property int defaultEdgeMargin: (Vars.panelStyle === "Flat" || Vars.panelStyle === "Attached") ? 0 : currentSpacingSmall


    signal popupOpened
    onPopupOpened: {
        topWindow.suppressHover = true;
        pillGraceTimer.stop();
        topWindow.pillHoverGrace = false;
    }
    signal openOverviewRequested
    signal openGameLibraryRequested

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

    property int currentSpacingSmall: Vars.spacingSmall !== undefined ? Vars.spacingSmall : 11
    property int currentRadiusExtraLarge: Vars.radiusExtraLarge !== undefined ? Vars.radiusExtraLarge : 38
    property int currentAnimationDuration: Vars.animationDuration !== undefined ? Vars.animationDuration : 240

    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            var spaceS = Vars.spacingSmall !== undefined ? Vars.spacingSmall : 11;
            if (topWindow.currentSpacingSmall !== spaceS) topWindow.currentSpacingSmall = spaceS;

            var radXL = Vars.radiusExtraLarge !== undefined ? Vars.radiusExtraLarge : 38;
            if (topWindow.currentRadiusExtraLarge !== radXL) topWindow.currentRadiusExtraLarge = radXL;

            var animD = Vars.animationDuration !== undefined ? Vars.animationDuration : 240;
            if (topWindow.currentAnimationDuration !== animD) topWindow.currentAnimationDuration = animD;
        }
    }

    Process {
        id: gameModeChecker
        command: ["bash", "-c", "grep -qi 'GameMode[ \t]*=[ \t]*true' ~/.config/hypr/modules/variables.lua && echo 'true' || echo 'false'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                topWindow.gameMode = (this.text.trim() === 'true');
            }
        }
    }

    function closeAllExcept(item) {
        if (item !== launcherItem) launcherItem.expanded = false;
        if (item !== controlCenterItem) controlCenterItem.expanded = false;
        if (item !== wallpaperSwitcherItem) wallpaperSwitcherItem.expanded = false;
        if (item !== colorSchemeSwitcherItem) colorSchemeSwitcherItem.expanded = false;
        if (item !== powerMenuItem) powerMenuItem.expanded = false;
        if (item !== emojiPickerItem) emojiPickerItem.expanded = false;
        if (item !== notificationPopupItem) notificationPopupItem.expanded = false;
        if (item !== settingsAppItem) settingsAppItem.expanded = false;
        if (item !== workspacesItem) workspacesItem.cancelOverlay();
        if (item !== volumeOsdItem) volumeOsdItem.isVisible = false;
        if (item !== brightnessOsdItem) brightnessOsdItem.isVisible = false;
    }

    function closeAll() {
        closeAllExcept(null);
    }

    mask: Region {
        Region {
            item: topWindow.hasAnyPopupOpen ? popupScrim : null
        }
        Region {
            item: clockHoverZone
        }
        Region {
            item: clockPill
        }
        Region {
            item: workspacesItem.panelMask
        }
        Region {
            item: controlCenterItem.panelMask
        }
        Region {
            item: launcherItem.panelMask
        }
        Region {
            item: powerMenuItem.panelMask
        }
        Region {
            item: polkitItem.expanded ? polkitScrim : polkitItem.panelMask
        }
        Region {
            item: wallpaperSwitcherItem.panelMask
        }
        Region {
            item: colorSchemeSwitcherItem.panelMask
        }
        Region {
            item: notificationPopupItem.panelMask
        }
        Region {
            item: emojiPickerItem.panelMask
        }
        Region {
            item: settingsAppItem.panelMask
        }
        Region {
            item: volumeOsdItem.panelMask
        }
        Region {
            item: brightnessOsdItem.panelMask
        }
    }

    // Restored popupScrim because Hyprland drops OnDemand focus on every commit
    // if the pointer is over another window. Exclusive focus + Scrim is required for animations.
    MouseArea {
        id: popupScrim
        anchors.fill: parent
        enabled: topWindow.hasAnyPopupOpen
        hoverEnabled: true
        acceptedButtons: Qt.AllButtons
        onWheel: (wheel) => wheel.accepted = true
        onClicked: closeAll()
        z: -1
    }

    property bool suppressHover: false
    property bool pillHoverGrace: false
    property bool pillHoverActive: clockHoverArea.containsMouse || clockPill.isHovered
    onPillHoverActiveChanged: {
        if (pillHoverActive) {
            pillGraceTimer.stop();
            topWindow.pillHoverGrace = true;
        } else {
            topWindow.suppressHover = false;
            pillGraceTimer.restart();
        }
    }

    Timer {
        id: pillGraceTimer
        interval: 400
        repeat: false
        onTriggered: topWindow.pillHoverGrace = false
    }

    Item {
        id: clockHoverZone
        anchors.top: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? undefined : parent.top
        anchors.bottom: topWindow.pillPos === "Bottom" ? parent.bottom : undefined
        anchors.left: topWindow.pillPos === "Left" ? parent.left : undefined
        anchors.right: topWindow.pillPos === "Right" ? parent.right : undefined
        anchors.horizontalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? undefined : parent.horizontalCenter
        anchors.verticalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? parent.verticalCenter : undefined
        width: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? (clockPill.isShown ? 80 : 18) : Math.max(300, clockPill.width + 60)
        height: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? Math.max(300, clockPill.height + 60) : (clockPill.isShown ? 80 : 18)
        
        MouseArea {
            id: clockHoverArea
            anchors.top: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? undefined : parent.top
            anchors.bottom: topWindow.pillPos === "Bottom" ? parent.bottom : undefined
            anchors.left: topWindow.pillPos === "Left" ? parent.left : undefined
            anchors.right: topWindow.pillPos === "Right" ? parent.right : undefined
            anchors.horizontalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? undefined : parent.horizontalCenter
            anchors.verticalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? parent.verticalCenter : undefined
            width: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? (clockPill.isShown ? 54 : 18) : Math.max(260, clockPill.width + 20)
            height: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? Math.max(260, clockPill.height + 20) : (clockPill.isShown ? 54 : 18)
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: {
                if (!(launcherItem.expanded || controlCenterItem.expanded || wallpaperSwitcherItem.expanded || colorSchemeSwitcherItem.expanded || powerMenuItem.expanded || polkitItem.expanded || notificationPopupItem.expanded || emojiPickerItem.expanded || settingsAppItem.expanded || volumeOsdItem.isVisible || workspacesItem.overlayVisible)) {
                    topWindow.suppressHover = false;
                }
            }
            onExited: {
                topWindow.suppressHover = false;
            }
            onPositionChanged: {
                if (topWindow.suppressHover && !(launcherItem.expanded || controlCenterItem.expanded || wallpaperSwitcherItem.expanded || colorSchemeSwitcherItem.expanded || powerMenuItem.expanded || polkitItem.expanded || notificationPopupItem.expanded || emojiPickerItem.expanded || settingsAppItem.expanded || volumeOsdItem.isVisible || workspacesItem.overlayVisible)) {
                    topWindow.suppressHover = false;
                }
            }
        }
    }

    // --- Main UI Content ---
    Item {
        anchors.fill: parent

        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: closeAll()
        }

    }

    ClockPill {
        id: clockPill
        gameMode: topWindow.gameMode
        anchors.top: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? undefined : parent.top
        anchors.bottom: topWindow.pillPos === "Bottom" ? parent.bottom : undefined
        anchors.left: topWindow.pillPos === "Left" ? parent.left : undefined
        anchors.right: topWindow.pillPos === "Right" ? parent.right : undefined
        anchors.horizontalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? undefined : parent.horizontalCenter
        anchors.verticalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? parent.verticalCenter : undefined
        
        property bool isShown: (!topWindow.suppressHover && (topWindow.pillHoverGrace || clockHoverArea.containsMouse || clockPill.isHovered) && !(launcherItem.expanded || controlCenterItem.expanded || wallpaperSwitcherItem.expanded || colorSchemeSwitcherItem.expanded || powerMenuItem.expanded || polkitItem.expanded || notificationPopupItem.expanded || emojiPickerItem.expanded || settingsAppItem.expanded || volumeOsdItem.isVisible || workspacesItem.overlayVisible))
        
        anchors.topMargin: (topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left") ? 0 : topWindow.defaultEdgeMargin
        anchors.bottomMargin: topWindow.pillPos === "Bottom" ? topWindow.defaultEdgeMargin : 0
        anchors.leftMargin: topWindow.pillPos === "Left" ? topWindow.defaultEdgeMargin : 0
        anchors.rightMargin: topWindow.pillPos === "Right" ? topWindow.defaultEdgeMargin : 0
        
        opacity: isShown ? 1.0 : 0.0
        
        Behavior on opacity {
            enabled: !topWindow.gameMode
            NumberAnimation {
                duration: currentAnimationDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: clockPill.isShown ? Vars.customEmphasizedDecelerate : Vars.customEmphasizedAccelerate
            }
        }

        onClicked: {
            topWindow.suppressHover = true;
            pillGraceTimer.stop();
            topWindow.pillHoverGrace = false;
            toggleControlCenter();
        }
        onRightClicked: {
            topWindow.suppressHover = true;
            pillGraceTimer.stop();
            topWindow.pillHoverGrace = false;
            toggleLauncher();
        }
        onScrolled: delta => {
            if (workspacesItem) {
                workspacesItem.handleScroll(delta);
            }
        }
    }

    HyprWorkspaces {
        id: workspacesItem
        gameMode: topWindow.gameMode
        anchors.top: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? undefined : parent.top
        anchors.bottom: topWindow.pillPos === "Bottom" ? parent.bottom : undefined
        anchors.left: topWindow.pillPos === "Left" ? parent.left : undefined
        anchors.right: topWindow.pillPos === "Right" ? parent.right : undefined
        anchors.horizontalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? undefined : parent.horizontalCenter
        anchors.verticalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? parent.verticalCenter : undefined
        anchors.topMargin: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? 0 : topWindow.defaultEdgeMargin
        anchors.bottomMargin: topWindow.pillPos === "Bottom" ? topWindow.defaultEdgeMargin : 0
        anchors.leftMargin: topWindow.pillPos === "Left" ? topWindow.defaultEdgeMargin : 0
        anchors.rightMargin: topWindow.pillPos === "Right" ? topWindow.defaultEdgeMargin : 0
        forceHidePill: launcherItem.expanded || controlCenterItem.expanded || wallpaperSwitcherItem.expanded || colorSchemeSwitcherItem.expanded || powerMenuItem.expanded || polkitItem.expanded || notificationPopupItem.expanded || emojiPickerItem.expanded || settingsAppItem.expanded || volumeOsdItem.isVisible

        onRequestCloseAll: {
            // A workspace switch happened and the pill is visible — dismiss any open popups
            closeAllExcept(workspacesItem);
        }
    }

    Launcher {
        id: launcherItem
        gameMode: topWindow.gameMode
        anchors.top: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? undefined : parent.top
        anchors.bottom: topWindow.pillPos === "Bottom" ? parent.bottom : undefined
        anchors.left: topWindow.pillPos === "Left" ? parent.left : undefined
        anchors.right: topWindow.pillPos === "Right" ? parent.right : undefined
        anchors.horizontalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? undefined : parent.horizontalCenter
        anchors.verticalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? parent.verticalCenter : undefined
        anchors.topMargin: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? 0 : topWindow.defaultEdgeMargin
        anchors.bottomMargin: topWindow.pillPos === "Bottom" ? topWindow.defaultEdgeMargin : 0
        anchors.leftMargin: topWindow.pillPos === "Left" ? topWindow.defaultEdgeMargin : 0
        anchors.rightMargin: topWindow.pillPos === "Right" ? topWindow.defaultEdgeMargin : 0
        width: 100
        height: 40
        focusWindow: topWindow

        onExpandedChanged: {
            if (expanded) {
                topWindow.popupOpened();
                closeAllExcept(launcherItem);
            }
        }
        
        onOpenSettingsRequested: {
            toggleSettings();
        }
    }

    function toggleLauncher() {
        if (!polkitItem.expanded) {
            if (launcherItem.expanded && !launcherItem.searchText.startsWith("/")) {
                launcherItem.expanded = false;
            } else {
                topWindow.popupOpened();
                _forceDropGrab = true;
                closeAllExcept(launcherItem);
                launcherItem.expanded = true;
                launcherItem.searchText = "";
                _forceDropGrab = false;
            }
        }
    }

    function toggleControlCenter() {
        if (!polkitItem.expanded) {
            let wasExpanded = controlCenterItem.expanded;
            if (wasExpanded) {
                controlCenterItem.expanded = false;
            } else {
                topWindow.popupOpened();
                _forceDropGrab = true;
                closeAllExcept(controlCenterItem);
                controlCenterItem.expanded = true;
                _forceDropGrab = false;
            }
        }
    }

    function toggleWallpaper() {
        if (!polkitItem.expanded) {
            let wasExpanded = wallpaperSwitcherItem.expanded;
            if (wasExpanded) {
                wallpaperSwitcherItem.expanded = false;
            } else {
                topWindow.popupOpened();
                _forceDropGrab = true;
                closeAllExcept(wallpaperSwitcherItem);
                wallpaperSwitcherItem.expanded = true;
                _forceDropGrab = false;
            }
        }
    }

    function toggleColorScheme() {
        if (!polkitItem.expanded) {
            let wasExpanded = colorSchemeSwitcherItem.expanded;
            if (wasExpanded) {
                colorSchemeSwitcherItem.expanded = false;
            } else {
                topWindow.popupOpened();
                _forceDropGrab = true;
                closeAllExcept(colorSchemeSwitcherItem);
                colorSchemeSwitcherItem.expanded = true;
                _forceDropGrab = false;
            }
        }
    }

    function togglePowerMenu() {
        if (!polkitItem.expanded) {
            let wasExpanded = powerMenuItem.expanded;
            if (wasExpanded) {
                powerMenuItem.expanded = false;
            } else {
                topWindow.popupOpened();
                _forceDropGrab = true;
                closeAllExcept(powerMenuItem);
                powerMenuItem.expanded = true;
                _forceDropGrab = false;
            }
        }
    }

    function toggleEmojiPicker() {
        if (!polkitItem.expanded) {
            if (launcherItem.expanded && launcherItem.searchText === "/emoji ") {
                launcherItem.expanded = false;
            } else {
                topWindow.popupOpened();
                _forceDropGrab = true;
                closeAllExcept(launcherItem);
                launcherItem.expanded = true;
                launcherItem.searchText = "/emoji ";
                _forceDropGrab = false;
            }
        }
    }

    function toggleClipboard() {
        if (!polkitItem.expanded) {
            if (launcherItem.expanded && launcherItem.searchText === "/clipboard ") {
                launcherItem.expanded = false;
            } else {
                topWindow.popupOpened();
                _forceDropGrab = true;
                closeAllExcept(launcherItem);
                launcherItem.expanded = true;
                launcherItem.searchText = "/clipboard ";
                _forceDropGrab = false;
            }
        }
    }

    function toggleSettings() {
        if (!polkitItem.expanded) {
            let wasExpanded = settingsAppItem.expanded;
            if (wasExpanded) {
                settingsAppItem.expanded = false;
            } else {
                topWindow.popupOpened();
                _forceDropGrab = true;
                closeAllExcept(settingsAppItem);
                settingsAppItem.expanded = true;
                _forceDropGrab = false;
            }
        }
    }

    PowerMenu {
        id: powerMenuItem
        gameMode: topWindow.gameMode
        anchors.top: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? undefined : parent.top
        anchors.bottom: topWindow.pillPos === "Bottom" ? parent.bottom : undefined
        anchors.left: topWindow.pillPos === "Left" ? parent.left : undefined
        anchors.right: topWindow.pillPos === "Right" ? parent.right : undefined
        anchors.horizontalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? undefined : parent.horizontalCenter
        anchors.verticalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? parent.verticalCenter : undefined
        anchors.topMargin: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? 0 : topWindow.defaultEdgeMargin
        anchors.bottomMargin: topWindow.pillPos === "Bottom" ? topWindow.defaultEdgeMargin : 0
        anchors.leftMargin: topWindow.pillPos === "Left" ? topWindow.defaultEdgeMargin : 0
        anchors.rightMargin: topWindow.pillPos === "Right" ? topWindow.defaultEdgeMargin : 0
        width: 100
        height: 40
        focusWindow: topWindow

        onExpandedChanged: {
            if (expanded) {
                topWindow.popupOpened();
                closeAllExcept(powerMenuItem);
            }
        }
    }

    Rectangle {
        id: polkitScrim
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.5)
        opacity: polkitItem.expanded ? 1.0 : 0.0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard } }
        
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onClicked: {
                if (polkitItem.flow) {
                    polkitItem.flow.cancelAuthenticationRequest();
                }
            }
        }
    }

    PolkitDialog {
        id: polkitItem
        gameMode: topWindow.gameMode
        anchors.top: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? undefined : parent.top
        anchors.bottom: topWindow.pillPos === "Bottom" ? parent.bottom : undefined
        anchors.left: topWindow.pillPos === "Left" ? parent.left : undefined
        anchors.right: topWindow.pillPos === "Right" ? parent.right : undefined
        anchors.horizontalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? undefined : parent.horizontalCenter
        anchors.verticalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? parent.verticalCenter : undefined
        anchors.topMargin: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? 0 : topWindow.defaultEdgeMargin
        anchors.bottomMargin: topWindow.pillPos === "Bottom" ? topWindow.defaultEdgeMargin : 0
        anchors.leftMargin: topWindow.pillPos === "Left" ? topWindow.defaultEdgeMargin : 0
        anchors.rightMargin: topWindow.pillPos === "Right" ? topWindow.defaultEdgeMargin : 0
        width: polkitItem.panel.width
        height: polkitItem.panel.height
        focusWindow: topWindow

        onExpandedChanged: {
            if (expanded) {
                topWindow.popupOpened();
                closeAllExcept(polkitItem);
            }
        }
    }

    NotificationPopup {
        id: notificationPopupItem
        gameMode: topWindow.gameMode
        anchors.top: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? undefined : parent.top
        anchors.bottom: topWindow.pillPos === "Bottom" ? parent.bottom : undefined
        anchors.left: topWindow.pillPos === "Left" ? parent.left : undefined
        anchors.right: topWindow.pillPos === "Right" ? parent.right : undefined
        anchors.horizontalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? undefined : parent.horizontalCenter
        anchors.verticalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? parent.verticalCenter : undefined
        anchors.topMargin: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? 0 : topWindow.defaultEdgeMargin
        anchors.bottomMargin: topWindow.pillPos === "Bottom" ? topWindow.defaultEdgeMargin : 0
        anchors.leftMargin: topWindow.pillPos === "Left" ? topWindow.defaultEdgeMargin : 0
        anchors.rightMargin: topWindow.pillPos === "Right" ? topWindow.defaultEdgeMargin : 0
        width: 100
        height: 40
        focusWindow: topWindow

        onExpandedChanged: {
            if (expanded) {
                topWindow.popupOpened();
                closeAllExcept(notificationPopupItem);
            }
        }
    }

    ControlCenter {
        id: controlCenterItem
        gameMode: topWindow.gameMode
        anchors.top: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? undefined : parent.top
        anchors.bottom: topWindow.pillPos === "Bottom" ? parent.bottom : undefined
        anchors.left: topWindow.pillPos === "Left" ? parent.left : undefined
        anchors.right: topWindow.pillPos === "Right" ? parent.right : undefined
        anchors.horizontalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? undefined : parent.horizontalCenter
        anchors.verticalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? parent.verticalCenter : undefined
        anchors.topMargin: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? 0 : topWindow.defaultEdgeMargin
        anchors.bottomMargin: topWindow.pillPos === "Bottom" ? topWindow.defaultEdgeMargin : 0
        anchors.leftMargin: topWindow.pillPos === "Left" ? topWindow.defaultEdgeMargin : 0
        anchors.rightMargin: topWindow.pillPos === "Right" ? topWindow.defaultEdgeMargin : 0
        width: 100
        height: 40
        focusWindow: topWindow
        forceHidePill: launcherItem.expanded || volumeOsdItem.isVisible || wallpaperSwitcherItem.expanded || colorSchemeSwitcherItem.expanded || powerMenuItem.expanded || polkitItem.expanded || notificationPopupItem.expanded || emojiPickerItem.expanded || settingsAppItem.expanded

        onExpandedChanged: {
            if (expanded) {
                topWindow.popupOpened();
                closeAllExcept(controlCenterItem);
            }
        }

        onOpenColorSchemeRequested: {
            toggleColorScheme();
        }

        onOpenSettingsRequested: {
            toggleSettings();
        }

        onOpenWallpaperRequested: {
            toggleWallpaper();
        }

        onOpenPowerMenuRequested: {
            togglePowerMenu();
        }

        onOpenOverviewRequested: {
            closeAll();
            Qt.callLater(() => { topWindow.openOverviewRequested(); });
        }

        onOpenGameLibraryRequested: {
            closeAll();
            Qt.callLater(() => { topWindow.openGameLibraryRequested(); });
        }
    }

    VolumeOsd {
        id: volumeOsdItem
        gameMode: topWindow.gameMode
        anchors.top: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? undefined : parent.top
        anchors.bottom: topWindow.pillPos === "Bottom" ? parent.bottom : undefined
        anchors.left: topWindow.pillPos === "Left" ? parent.left : undefined
        anchors.right: topWindow.pillPos === "Right" ? parent.right : undefined
        anchors.horizontalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? undefined : parent.horizontalCenter
        anchors.verticalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? parent.verticalCenter : undefined
        anchors.topMargin: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? 0 : topWindow.defaultEdgeMargin
        anchors.bottomMargin: topWindow.pillPos === "Bottom" ? topWindow.defaultEdgeMargin : 0
        anchors.leftMargin: topWindow.pillPos === "Left" ? topWindow.defaultEdgeMargin : 0
        anchors.rightMargin: topWindow.pillPos === "Right" ? topWindow.defaultEdgeMargin : 0
        preventShow: launcherItem.expanded || controlCenterItem.expanded || wallpaperSwitcherItem.expanded || colorSchemeSwitcherItem.expanded || powerMenuItem.expanded || polkitItem.expanded || notificationPopupItem.expanded || emojiPickerItem.expanded || settingsAppItem.expanded || launcherItem.panel.width > 105 || controlCenterItem.panel.width > 105 || powerMenuItem.panel.width > 105 || polkitItem.panel.width > 105 || notificationPopupItem.panel.width > 105 || emojiPickerItem.panel.width > 105 || wallpaperSwitcherItem.panel.width > 105 || colorSchemeSwitcherItem.panel.width > 105 || settingsAppItem.panel.width > 105 || brightnessOsdItem.isVisible
    }

    BrightnessOsd {
        id: brightnessOsdItem
        gameMode: topWindow.gameMode
        anchors.top: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? undefined : parent.top
        anchors.bottom: topWindow.pillPos === "Bottom" ? parent.bottom : undefined
        anchors.left: topWindow.pillPos === "Left" ? parent.left : undefined
        anchors.right: topWindow.pillPos === "Right" ? parent.right : undefined
        anchors.horizontalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? undefined : parent.horizontalCenter
        anchors.verticalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? parent.verticalCenter : undefined
        anchors.topMargin: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? 0 : topWindow.defaultEdgeMargin
        anchors.bottomMargin: topWindow.pillPos === "Bottom" ? topWindow.defaultEdgeMargin : 0
        anchors.leftMargin: topWindow.pillPos === "Left" ? topWindow.defaultEdgeMargin : 0
        anchors.rightMargin: topWindow.pillPos === "Right" ? topWindow.defaultEdgeMargin : 0
        preventShow: launcherItem.expanded || controlCenterItem.expanded || wallpaperSwitcherItem.expanded || colorSchemeSwitcherItem.expanded || powerMenuItem.expanded || polkitItem.expanded || notificationPopupItem.expanded || emojiPickerItem.expanded || settingsAppItem.expanded || launcherItem.panel.width > 105 || controlCenterItem.panel.width > 105 || powerMenuItem.panel.width > 105 || polkitItem.panel.width > 105 || notificationPopupItem.panel.width > 105 || emojiPickerItem.panel.width > 105 || wallpaperSwitcherItem.panel.width > 105 || colorSchemeSwitcherItem.panel.width > 105 || settingsAppItem.panel.width > 105 || volumeOsdItem.isVisible
    }

    WallpaperSwitcher {
        id: wallpaperSwitcherItem
        gameMode: topWindow.gameMode
        anchors.top: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? undefined : parent.top
        anchors.bottom: topWindow.pillPos === "Bottom" ? parent.bottom : undefined
        anchors.left: topWindow.pillPos === "Left" ? parent.left : undefined
        anchors.right: topWindow.pillPos === "Right" ? parent.right : undefined
        anchors.horizontalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? undefined : parent.horizontalCenter
        anchors.verticalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? parent.verticalCenter : undefined
        anchors.topMargin: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? 0 : topWindow.defaultEdgeMargin
        anchors.bottomMargin: topWindow.pillPos === "Bottom" ? topWindow.defaultEdgeMargin : 0
        anchors.leftMargin: topWindow.pillPos === "Left" ? topWindow.defaultEdgeMargin : 0
        anchors.rightMargin: topWindow.pillPos === "Right" ? topWindow.defaultEdgeMargin : 0
        focusWindow: topWindow
        forceHidePill: launcherItem.expanded || controlCenterItem.expanded || colorSchemeSwitcherItem.expanded || powerMenuItem.expanded || polkitItem.expanded || notificationPopupItem.expanded || emojiPickerItem.expanded || settingsAppItem.expanded || volumeOsdItem.isVisible

        onExpandedChanged: {
            if (expanded) {
                topWindow.popupOpened();
                closeAllExcept(wallpaperSwitcherItem);
            }
        }

        onCloseRequested: expanded = false
    }

    EmojiPicker {
        id: emojiPickerItem
        gameMode: topWindow.gameMode
        anchors.top: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? undefined : parent.top
        anchors.bottom: topWindow.pillPos === "Bottom" ? parent.bottom : undefined
        anchors.left: topWindow.pillPos === "Left" ? parent.left : undefined
        anchors.right: topWindow.pillPos === "Right" ? parent.right : undefined
        anchors.horizontalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? undefined : parent.horizontalCenter
        anchors.verticalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? parent.verticalCenter : undefined
        anchors.topMargin: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? 0 : topWindow.defaultEdgeMargin
        anchors.bottomMargin: topWindow.pillPos === "Bottom" ? topWindow.defaultEdgeMargin : 0
        anchors.leftMargin: topWindow.pillPos === "Left" ? topWindow.defaultEdgeMargin : 0
        anchors.rightMargin: topWindow.pillPos === "Right" ? topWindow.defaultEdgeMargin : 0
        width: 100
        height: 40
        focusWindow: topWindow

        onExpandedChanged: {
            if (expanded) {
                topWindow.popupOpened();
                closeAllExcept(emojiPickerItem);
            }
        }
    }

    ColorSchemeSwitcher {
        id: colorSchemeSwitcherItem
        gameMode: topWindow.gameMode
        anchors.top: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? undefined : parent.top
        anchors.bottom: topWindow.pillPos === "Bottom" ? parent.bottom : undefined
        anchors.left: topWindow.pillPos === "Left" ? parent.left : undefined
        anchors.right: topWindow.pillPos === "Right" ? parent.right : undefined
        anchors.horizontalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? undefined : parent.horizontalCenter
        anchors.verticalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? parent.verticalCenter : undefined
        anchors.topMargin: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? 0 : topWindow.defaultEdgeMargin
        anchors.bottomMargin: topWindow.pillPos === "Bottom" ? topWindow.defaultEdgeMargin : 0
        anchors.leftMargin: topWindow.pillPos === "Left" ? topWindow.defaultEdgeMargin : 0
        anchors.rightMargin: topWindow.pillPos === "Right" ? topWindow.defaultEdgeMargin : 0
        focusWindow: topWindow
        forceHidePill: launcherItem.expanded || controlCenterItem.expanded || wallpaperSwitcherItem.expanded || powerMenuItem.expanded || polkitItem.expanded || notificationPopupItem.expanded || emojiPickerItem.expanded || settingsAppItem.expanded || volumeOsdItem.isVisible

        onExpandedChanged: {
            if (expanded) {
                topWindow.popupOpened();
                launcherItem.expanded = false;
                controlCenterItem.expanded = false;
                wallpaperSwitcherItem.expanded = false;
                powerMenuItem.expanded = false;
                emojiPickerItem.expanded = false;
                settingsAppItem.expanded = false;
            }
        }

        onCloseRequested: expanded = false
    }

    SettingsApp {
        id: settingsAppItem
        gameMode: topWindow.gameMode
        anchors.top: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? undefined : parent.top
        anchors.bottom: topWindow.pillPos === "Bottom" ? parent.bottom : undefined
        anchors.left: topWindow.pillPos === "Left" ? parent.left : undefined
        anchors.right: topWindow.pillPos === "Right" ? parent.right : undefined
        anchors.horizontalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? undefined : parent.horizontalCenter
        anchors.verticalCenter: (topWindow.pillPos === "Left" || topWindow.pillPos === "Right") ? parent.verticalCenter : undefined
        anchors.topMargin: topWindow.pillPos === "Bottom" || topWindow.pillPos === "Right" || topWindow.pillPos === "Left" ? 0 : topWindow.defaultEdgeMargin
        anchors.bottomMargin: topWindow.pillPos === "Bottom" ? topWindow.defaultEdgeMargin : 0
        anchors.leftMargin: topWindow.pillPos === "Left" ? topWindow.defaultEdgeMargin : 0
        anchors.rightMargin: topWindow.pillPos === "Right" ? topWindow.defaultEdgeMargin : 0
        focusWindow: topWindow
        forceHidePill: launcherItem.expanded || controlCenterItem.expanded || wallpaperSwitcherItem.expanded || powerMenuItem.expanded || polkitItem.expanded || notificationPopupItem.expanded || emojiPickerItem.expanded || colorSchemeSwitcherItem.expanded || volumeOsdItem.isVisible
        onDetachToggled: function(isFloating) {
            if (isFloating) topWindow.toggleFloatingSettings();
        }

        onExpandedChanged: {
            if (expanded) {
                topWindow.popupOpened();
                closeAllExcept(settingsAppItem);
            }
        }

        onOpenWallpaperSwitcherRequested: {
            toggleWallpaper();
        }

        onCloseRequested: expanded = false
    }

    Repeater {
        model: [launcherItem, clockPill, workspacesItem, powerMenuItem, emojiPickerItem, colorSchemeSwitcherItem, wallpaperSwitcherItem, settingsAppItem, controlCenterItem, notificationPopupItem, polkitItem, volumeOsdItem, brightnessOsdItem]
        delegate: Item {
            property var targetPanel: modelData
            property bool hasPanel: !!(targetPanel?.panel)
            property real px: (targetPanel?.x ?? 0) + (targetPanel?.panel?.x ?? 0)
            property real py: (targetPanel?.y ?? 0) + (targetPanel?.panel?.y ?? 0)
            property real pw: targetPanel?.panel?.width ?? targetPanel?.width ?? 0
            property real ph: targetPanel?.panel?.height ?? targetPanel?.height ?? 0
            property string pos: Vars.pillPosition || "Top"
            
            InvertedCorner {
                x: parent.pos === "Right" ? (parent.px + parent.pw - width) : (parent.pos === "Left" ? parent.px : parent.px - width)
                y: (parent.pos === "Right" || parent.pos === "Left") ? parent.py - height : (parent.pos === "Bottom" ? parent.py + parent.ph - height : parent.py)
                side: parent.pos === "Right" ? "bottom-right" : (parent.pos === "Left" ? "bottom-left" : (parent.pos === "Bottom" ? "bottom-right" : "top-right"))
                visible: Vars.panelStyle === "Attached" && opacity > 0 && parent.pw > 0 && parent.ph > 0
                color: (parent.targetPanel && parent.targetPanel.panel) ? parent.targetPanel.panel.color : "transparent"
                opacity: (parent.targetPanel && parent.targetPanel.panel ? parent.targetPanel.panel.opacity : 1.0) * (parent.targetPanel ? parent.targetPanel.opacity : 1.0)
                radius: Math.max(0, Math.min(currentRadiusExtraLarge, Math.min(parent.pw, parent.ph) / 2))
            }
            InvertedCorner {
                x: (parent.pos === "Right" || parent.pos === "Left") ? (parent.pos === "Right" ? parent.px + parent.pw - width : parent.px) : parent.px + parent.pw
                y: (parent.pos === "Right" || parent.pos === "Left") ? parent.py + parent.ph : (parent.pos === "Bottom" ? parent.py + parent.ph - height : parent.py)
                side: parent.pos === "Right" ? "top-right" : (parent.pos === "Left" ? "top-left" : (parent.pos === "Bottom" ? "bottom-left" : "top-left"))
                visible: Vars.panelStyle === "Attached" && opacity > 0 && parent.pw > 0 && parent.ph > 0
                color: (parent.targetPanel && parent.targetPanel.panel) ? parent.targetPanel.panel.color : "transparent"
                opacity: (parent.targetPanel && parent.targetPanel.panel ? parent.targetPanel.panel.opacity : 1.0) * (parent.targetPanel ? parent.targetPanel.opacity : 1.0)
                radius: Math.max(0, Math.min(currentRadiusExtraLarge, Math.min(parent.pw, parent.ph) / 2))
            }
        }
    }
}
