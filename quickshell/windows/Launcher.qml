import QtQuick
import QtQuick.Effects
import ".."
import "./Launcher" as LC
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../theme/variables.js" as Vars

Item {
    id: root
    
    // Fixed layout footprint - never animates, no parent relayout
    Layout.preferredWidth: 100
    Layout.preferredHeight: 40
    
    property bool expanded: false
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
    
    // Expose panel for TopPills Wayland mask tracking
    property alias panel: panel
    property alias panelMask: panelMask
    property alias searchText: searchBar.text

    function setSearchText(t) {
        searchBar.text = t;
    }

    function forceSearchFocus() {
        searchBar.forceActiveFocus();
    }

    signal appLaunched()
    signal openSettingsRequested()

    LC.LauncherModel {
        id: launcherModel
        filterText: searchBar.text
    }


    
    // Clear search when closed, focus when opened
    onExpandedChanged: {
        if (!expanded) {
            MorphState.notifyClosed();
            searchBar.text = "";
        } else {
            MorphState.notifyOpened(500, panel.targetHeight, panel.targetRad, panel);
            launcherModel.refreshClipboard();
            innerUI.visible = true;
            searchBar.forceActiveFocus();
            innerUI.visible = Qt.binding(() => root.expanded || innerUI.opacity > 0);
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

        width: root.expanded ? 540 : 140
        height: root.expanded ? 490 : 80
    }

    // The visual panel that animates
    Rectangle {
        id: panel
        property bool isBackgroundActive: root.expanded || (MorphState.openCount === 0 && MorphState.activeItem === panel && panel.width > 105)
        layer.enabled: true
        layer.effect: MultiEffect { shadowEnabled: !root.gameMode && panel.isBackgroundActive; shadowBlur: 1.0; shadowColor: Qt.rgba(0,0,0,0.25); shadowVerticalOffset: 4; shadowHorizontalOffset: 0 }
        anchors.top: (!Vars.pillPosition || Vars.pillPosition === "Top") ? parent.top : undefined
        anchors.bottom: Vars.pillPosition === "Bottom" ? parent.bottom : undefined
        anchors.left: Vars.pillPosition === "Left" ? parent.left : undefined
        anchors.right: Vars.pillPosition === "Right" ? parent.right : undefined
        anchors.horizontalCenter: (Vars.pillPosition === "Left" || Vars.pillPosition === "Right") ? undefined : parent.horizontalCenter
        anchors.verticalCenter: (Vars.pillPosition === "Left" || Vars.pillPosition === "Right") ? parent.verticalCenter : undefined
        
        onHeightChanged: console.log("[DEBUG] Launcher panel.height:", height, "implicit:", mainLayout.implicitHeight)
        property real targetHeight: root.expanded ? Math.max(80, Math.min(450, mainLayout.implicitHeight + (Vars.spacingLarge * 2))) : (MorphState.anyExpanded ? MorphState.targetHeight : 40)
        width: root.expanded ? 500 : (MorphState.anyExpanded ? MorphState.targetWidth : 100)
        height: targetHeight
        
        onTargetHeightChanged: {
            if (root.expanded) MorphState.updateDimensions(500, targetHeight, targetRad);
        }
        
        opacity: isBackgroundActive || innerUI.opacity > 0 ? 1.0 : 0.0
        // visible: opacity > 0 // Removed to preserve Behavior when hidden
        
        color: isBackgroundActive ? ((Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, Vars.panelOpacity) : Theme.surface) : "transparent"
        property real targetRad: root.expanded ? Vars.radiusExtraLarge : (MorphState.anyExpanded ? MorphState.targetRadius : height / 2)
        topLeftRadius: Vars.getTopLeftRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)
        topRightRadius: Vars.getTopRightRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)
        bottomLeftRadius: Vars.getBottomLeftRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)
        bottomRightRadius: Vars.getBottomRightRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)

        Behavior on radius { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on width { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on height { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            hoverEnabled: true
            enabled: panel.opacity > 0
            onWheel: (wheel) => wheel.accepted = true
        }

        // EXPANDED UI
        Item {
            id: innerUI
            anchors.fill: parent
            anchors.margins: Vars.spacingLarge
            
            opacity: root.expanded ? 1.0 : 0.0
            visible: root.expanded || opacity > 0
            Behavior on opacity { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: root.expanded ? Vars.customEmphasizedDecelerate : Vars.customEmphasizedAccelerate } }

            ColumnLayout {
                id: mainLayout
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                spacing: Vars.spacingMedium

                // Header removed per user request

                SearchBar {
                    id: searchBar
                    expanded: root.expanded
                    placeholderText: "Search apps..."
                    onDownPressed: {
                        if (appList.count > 0 && appList.currentIndex === -1) {
                            appList.currentIndex = 0;
                        }
                        appList.forceActiveFocus();
                    }
                    onReturnPressed: {
                        if (appList.count > 0 && appList.currentIndex === -1) {
                            appList.currentIndex = 0;
                        }
                        appList.forceActiveFocus();
                    }
                    onEscapePressed: {
                        if (appList.count > 0 && appList.currentIndex === -1) {
                            appList.currentIndex = 0;
                        }
                        appList.forceActiveFocus();
                    }
                }

                LC.AppList {
                    id: appList
                    launcherModel: launcherModel
                    searchText: searchBar.text
                    model: launcherModel.filteredModel
                    
                    onAppLaunched: root.appLaunched()
                    onEscapePressed: root.expanded = false
                    onFocusSearchBar: searchBar.forceActiveFocus()
                    onOpenSettingsRequested: root.openSettingsRequested()
                    
                    onRequestSearchText: (t) => {
                        searchBar.text = t;
                    }
                }
            }
        }
    }
}