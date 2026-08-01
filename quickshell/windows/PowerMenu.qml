import QtQuick
import QtQuick.Effects
import ".."
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../theme/variables.js" as Vars

Item {
    id: root
    readonly property bool isVertical: Vars.pillPosition === "Left" || Vars.pillPosition === "Right"
    
    FontLoader {
        id: filledIconFont
        source: "../theme/assets/MaterialSymbolsRounded-Filled.ttf"
    }

    // Fixed layout footprint - never animates, no parent relayout
    Layout.preferredWidth: isVertical ? 40 : 100
    Layout.preferredHeight: isVertical ? 100 : 40

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

    property alias panel: panel
    property alias panelMask: panelMask
    
    focus: true


    
    // Close on escape
    Keys.onEscapePressed: {
        root.expanded = false;
    }
    
    onExpandedChanged: {
        if (expanded) {
            MorphState.notifyOpened(isVertical ? 96 : 432, isVertical ? 432 : 96, panel.targetRad, panel);
            vimKeysChecker.running = true;
            currentIndex = 0;
            root.forceActiveFocus();
        } else {
            MorphState.notifyClosed();
        }
    }

    property bool vimKeysEnabled: false
    Process {
        id: vimKeysChecker
        command: ["bash", "-c", "grep -qi 'vimkeys[ \t]*=[ \t]*true' /home/boing/Dotfiles/hypr/modules/variables.lua && echo 'true' || echo 'false'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.vimKeysEnabled = (this.text.trim() === 'true');
            }
        }
    }

    property int currentIndex: 0

    Keys.onLeftPressed: (event) => {
        if (!isVertical) {
            if (Vars.pillPosition === "Right") {
                currentIndex = (currentIndex + 1) % 5;
            } else {
                currentIndex = (currentIndex - 1 + 5) % 5;
            }
            event.accepted = true;
        }
    }
    
    Keys.onRightPressed: (event) => {
        if (!isVertical) {
            if (Vars.pillPosition === "Right") {
                currentIndex = (currentIndex - 1 + 5) % 5;
            } else {
                currentIndex = (currentIndex + 1) % 5;
            }
            event.accepted = true;
        }
    }

    Keys.onUpPressed: (event) => {
        if (isVertical) {
            currentIndex = (currentIndex - 1 + 5) % 5;
            event.accepted = true;
        }
    }

    Keys.onDownPressed: (event) => {
        if (isVertical) {
            currentIndex = (currentIndex + 1) % 5;
            event.accepted = true;
        }
    }
    
    Keys.onPressed: (event) => {
        if (root.vimKeysEnabled) {
            if (event.key === Qt.Key_H) {
                if (!isVertical) {
                    if (Vars.pillPosition === "Right") {
                        currentIndex = (currentIndex + 1) % 5;
                    } else {
                        currentIndex = (currentIndex - 1 + 5) % 5;
                    }
                    event.accepted = true;
                }
            } else if (event.key === Qt.Key_L) {
                if (!isVertical) {
                    if (Vars.pillPosition === "Right") {
                        currentIndex = (currentIndex - 1 + 5) % 5;
                    } else {
                        currentIndex = (currentIndex + 1) % 5;
                    }
                    event.accepted = true;
                }
            } else if (event.key === Qt.Key_K) {
                if (isVertical) {
                    currentIndex = (currentIndex - 1 + 5) % 5;
                    event.accepted = true;
                }
            } else if (event.key === Qt.Key_J) {
                if (isVertical) {
                    currentIndex = (currentIndex + 1) % 5;
                    event.accepted = true;
                }
            }
        }
    }
    
    Keys.onReturnPressed: (event) => {
        triggerAction();
        event.accepted = true;
    }
    
    Keys.onSpacePressed: (event) => {
        triggerAction();
        event.accepted = true;
    }

    function triggerAction() {
        if (currentIndex === 0) { LockScreen.lockScreen(); root.expanded = false; }
        else if (currentIndex === 1) { suspendProcess.running = true; root.expanded = false; }
        else if (currentIndex === 2) { logoutProcess.running = true; root.expanded = false; }
        else if (currentIndex === 3) { rebootProcess.running = true; root.expanded = false; }
        else if (currentIndex === 4) { shutdownProcess.running = true; root.expanded = false; }
    }

    Item {
        id: panelMask
        anchors.centerIn: panel
        width: panel.width + 40
        height: panel.height + 40
    }

    Rectangle {
        id: panel
        property bool isBackgroundActive: root.expanded || (MorphState.openCount === 0 && MorphState.activeItem === panel && (isVertical ? panel.height > 105 : panel.width > 105))
        layer.enabled: true
        layer.effect: MultiEffect { shadowEnabled: !root.gameMode && panel.isBackgroundActive; shadowBlur: 1.0; shadowColor: Qt.rgba(0,0,0,0.25); shadowVerticalOffset: 4; shadowHorizontalOffset: 0 }
        anchors.top: (!Vars.pillPosition || Vars.pillPosition === "Top") ? parent.top : undefined
        anchors.bottom: Vars.pillPosition === "Bottom" ? parent.bottom : undefined
        anchors.left: Vars.pillPosition === "Left" ? parent.left : undefined
        anchors.right: Vars.pillPosition === "Right" ? parent.right : undefined
        anchors.horizontalCenter: (Vars.pillPosition === "Left" || Vars.pillPosition === "Right") ? undefined : parent.horizontalCenter
        anchors.verticalCenter: (Vars.pillPosition === "Left" || Vars.pillPosition === "Right") ? parent.verticalCenter : undefined

        width: root.expanded ? (isVertical ? 96 : 432) : (MorphState.anyExpanded ? MorphState.targetWidth : (isVertical ? 40 : 100))
        height: root.expanded ? (isVertical ? 432 : 96) : (MorphState.anyExpanded ? MorphState.targetHeight : (isVertical ? 100 : 40))
        
        color: isBackgroundActive ? (Vars.translucent ? Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, Vars.panelOpacity) : Theme.surface) : "transparent"
        property real targetRad: root.expanded ? Vars.radiusExtraLarge : (MorphState.anyExpanded ? MorphState.targetRadius : height / 2)
        topLeftRadius: Vars.getTopLeftRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)
        topRightRadius: Vars.getTopRightRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)
        bottomLeftRadius: Vars.getBottomLeftRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)
        bottomRightRadius: Vars.getBottomRightRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)
        // clip removed for shadow

        opacity: isBackgroundActive || rowLayout.opacity > 0 ? 1.0 : 0.0
        // visible: opacity > 0 // Removed to preserve Behavior when hidden

        Behavior on topLeftRadius { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on topRightRadius { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on bottomLeftRadius { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on bottomRightRadius { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on width { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on height { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on color { enabled: !root.gameMode; ColorAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }

        GridLayout {
            id: rowLayout
            layoutDirection: (!isVertical && Vars.pillPosition === "Right") ? Qt.RightToLeft : Qt.LeftToRight
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            anchors.topMargin: 12
            anchors.bottomMargin: 12
            rowSpacing: 12
            columnSpacing: 12
            columns: isVertical ? 1 : 5
            rows: isVertical ? 5 : 1
            flow: isVertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
            
            opacity: root.expanded ? 1.0 : 0.0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: root.expanded ? Vars.customEmphasizedDecelerate : Vars.customEmphasizedAccelerate } }

            PowerMenuButton {
                id: btn0
                iconText: "\ue897" // lock
                labelText: "Lock"
                index: 0
                onClicked: { LockScreen.lockScreen(); root.expanded = false; }
            }
            
            PowerMenuButton {
                id: btn1
                iconText: "\ue51c" // dark_mode / suspend
                labelText: "Suspend"
                index: 1
                onClicked: { suspendProcess.running = true; root.expanded = false; }
            }
            
            PowerMenuButton {
                id: btn2
                iconText: "\ue9ba" // logout
                labelText: "Log Out"
                index: 2
                onClicked: { logoutProcess.running = true; root.expanded = false; }
            }
            
            PowerMenuButton {
                id: btn3
                iconText: "\ue5d5" // restart_alt
                labelText: "Reboot"
                index: 3
                onClicked: { rebootProcess.running = true; root.expanded = false; }
            }
            
            PowerMenuButton {
                id: btn4
                iconText: "\ue8ac" // power_settings_new
                labelText: "Power Off"
                index: 4
                onClicked: { shutdownProcess.running = true; root.expanded = false; }
            }
        }
    }

    component PowerMenuButton: Rectangle {
        id: btn
        property string iconText: ""
        property string labelText: ""
        property int index: 0
        property bool isActive: root.currentIndex === index
        signal clicked
        
        Layout.preferredWidth: 72
        Layout.preferredHeight: 72
        radius: isActive ? height / 2 : Vars.radiusLarge 
        
        Behavior on radius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard } }
        
        color: isActive ? (Vars.translucent ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.85) : Theme.primary) : Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.06)
        border.width: isActive ? 2 : 0
        border.color: isActive ? Theme.primary : "transparent"
        
        Behavior on color { ColorAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard } }
        Behavior on border.color { ColorAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard } }
        
        scale: ma.pressed ? 0.92 : 1.0
        Behavior on scale { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard } }

        Item {
            anchors.fill: parent

            // Outlined Icon
            Text {
                anchors.centerIn: parent
                text: btn.iconText
                font.family: "Material Symbols Outlined"
                font.pixelSize: 36
                color: btn.isActive ? Theme.on_primary : Theme.on_surface
                opacity: btn.isActive ? 0.0 : 1.0
                scale: btn.isActive ? 0.8 : 1.0
                
                Behavior on color { ColorAnimation { duration: Vars.animationDuration } }
                Behavior on opacity { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.InOutQuad } }
                Behavior on scale { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.OutBack } }
            }

            // Filled Icon
            Text {
                anchors.centerIn: parent
                text: btn.iconText
                font.family: filledIconFont.name
                font.pixelSize: 36
                color: btn.isActive ? Theme.on_primary : Theme.on_surface
                opacity: btn.isActive ? 1.0 : 0.0
                scale: btn.isActive ? 1.0 : 0.5
                
                Behavior on color { ColorAnimation { duration: Vars.animationDuration } }
                Behavior on opacity { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.InOutQuad } }
                Behavior on scale { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.OutBack } }
            }
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: { root.currentIndex = btn.index; }
            onClicked: btn.clicked()
        }
    }

    Process { id: shutdownProcess; command: ["systemctl", "poweroff"] }
    Process { id: rebootProcess; command: ["systemctl", "reboot"] }
    Process { id: suspendProcess; command: ["systemctl", "suspend"] }
    Process { id: logoutProcess; command: ["hyprctl", "dispatch", "exit"] }
}
