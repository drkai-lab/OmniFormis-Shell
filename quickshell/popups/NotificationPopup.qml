import QtQuick
import QtQuick.Effects
import ".."
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications as QNotif
import "../theme/variables.js" as Vars

Item {
    id: root

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

    property var notifications: NotificationService.notifications
    property bool hasNotifications: notifications && notifications.length > 0

    onNotificationsChanged: {
        var count = notifications ? notifications.length : 0;
        console.log("NotificationPopup: notifications changed, count:", count);
        if (count > 0 && !expanded) {
            expanded = true;
        } else if (count === 0) {
            expanded = false;
        }
    }

    onExpandedChanged: {
        if (expanded) MorphState.notifyOpened(380, panel.targetHeight, panel.targetRad, panel);
        else MorphState.notifyClosed();
    }

    // Safety timer: collapse if notifications were dismissed externally
    Timer {
        interval: 500
        running: root.expanded
        repeat: true
        onTriggered: {
            if (!root.notifications || root.notifications.length === 0) {
                root.expanded = false;
            }
        }
    }

    Item {
        id: panelMask
        anchors.centerIn: panel
        width: panel.width + 40
        height: panel.height + 40
    }

    // The visual panel that morphs from clock pill
    Rectangle {
        id: panel
        property bool isBackgroundActive: root.expanded || (MorphState.openCount === 0 && MorphState.activeItem === panel && panel.width > 105)
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: !root.gameMode && panel.isBackgroundActive
            shadowBlur: 1.0
            shadowColor: Qt.rgba(0, 0, 0, 0.25)
            shadowVerticalOffset: 4
            shadowHorizontalOffset: 0
        }
        anchors.top: (!Vars.pillPosition || Vars.pillPosition === "Top") ? parent.top : undefined
        anchors.bottom: Vars.pillPosition === "Bottom" ? parent.bottom : undefined
        anchors.left: Vars.pillPosition === "Left" ? parent.left : undefined
        anchors.right: Vars.pillPosition === "Right" ? parent.right : undefined
        anchors.horizontalCenter: (Vars.pillPosition === "Left" || Vars.pillPosition === "Right") ? undefined : parent.horizontalCenter
        anchors.verticalCenter: (Vars.pillPosition === "Left" || Vars.pillPosition === "Right") ? parent.verticalCenter : undefined

        property real targetHeight: root.expanded ? contentColumn.implicitHeight + 24 : (MorphState.anyExpanded ? MorphState.targetHeight : 40)
        width: root.expanded ? 380 : (MorphState.anyExpanded ? MorphState.targetWidth : 100)
        height: targetHeight

        onTargetHeightChanged: {
            if (root.expanded) MorphState.updateDimensions(380, targetHeight, targetRad);
        }

        color: isBackgroundActive ? (Vars.translucent ? Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.85) : Theme.surface) : "transparent"
        property real targetRad: root.expanded ? Vars.radiusExtraLarge : (MorphState.anyExpanded ? MorphState.targetRadius : height / 2)
        topLeftRadius: Vars.getTopLeftRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)
        topRightRadius: Vars.getTopRightRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)
        bottomLeftRadius: Vars.getBottomLeftRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)
        bottomRightRadius: Vars.getBottomRightRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)

        opacity: isBackgroundActive || innerUI.opacity > 0 ? 1.0 : 0.0
        // visible: opacity > 0 // Removed to preserve Behavior when hidden

        Behavior on topLeftRadius {
            enabled: !root.gameMode
            NumberAnimation {
                duration: Vars.animationDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Vars.customExpressiveSpatialSlow
            }
        }
        Behavior on topRightRadius {
            enabled: !root.gameMode
            NumberAnimation {
                duration: Vars.animationDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Vars.customExpressiveSpatialSlow
            }
        }
        Behavior on bottomLeftRadius {
            enabled: !root.gameMode
            NumberAnimation {
                duration: Vars.animationDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Vars.customExpressiveSpatialSlow
            }
        }
        Behavior on bottomRightRadius {
            enabled: !root.gameMode
            NumberAnimation {
                duration: Vars.animationDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Vars.customExpressiveSpatialSlow
            }
        }
        Behavior on width {
            enabled: !root.gameMode
            NumberAnimation {
                duration: Vars.animationDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Vars.customExpressiveSpatialSlow
            }
        }
        Behavior on height {
            enabled: !root.gameMode
            NumberAnimation {
                duration: Vars.animationDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Vars.customExpressiveSpatialSlow
            }
        }

        // EXPANDED UI
        Item {
            id: innerUI
            anchors.fill: parent
            anchors.margins: 12

            opacity: root.expanded ? 1.0 : 0.0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation {
                    duration: Vars.animationDuration
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: root.expanded ? Vars.customEmphasizedDecelerate : Vars.customEmphasizedAccelerate
                }
            }

            ColumnLayout {
                id: contentColumn
                anchors.fill: parent
                spacing: 8



                // Show only the latest notification
                Repeater {
                    model: root.hasNotifications ? 1 : 0

                    NotificationCard {
                        Layout.fillWidth: true
                        isPopup: true
                        fontName: Vars.fontFamily
                        modelData: root.hasNotifications ? root.notifications[0] : null
                        onPopupRightClicked: {
                            root.expanded = false;
                        }
                    }
                }
            }
        }
    }
}
