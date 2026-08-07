import QtQuick
import QtQuick.Effects
import ".."
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray

import "../theme/variables.js" as Vars

// Blanket Style: A single unified unibody pill to hold all tray icons
Rectangle {
    id: systemTrayContainer

    signal openTrayMenuRequested(var menu)
    layer.enabled: true
    layer.samples: 4
    layer.effect: MultiEffect { shadowEnabled: true; shadowBlur: 1.0; shadowColor: Qt.rgba(0,0,0,0.25); shadowVerticalOffset: 4; shadowHorizontalOffset: 0 }
    color: (Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface_container_high.r, Theme.surface_container_high.g, Theme.surface_container_high.b, Vars.panelOpacity) : Theme.surface_container_high
    property bool isVertical: Vars.pillPosition === "Left" || Vars.pillPosition === "Right"
    radius: Math.min(width, height) / 2
    
    // THE FIX: Only show this pill if there is actually an app in the tray!
    visible: SystemTray.items.length > 0
    
    // Auto-size based on the number of tray items and orientation
    implicitWidth: isVertical ? 40 : (trayLayout.implicitWidth + Vars.spacingLarge)
    implicitHeight: isVertical ? (trayLayout.implicitHeight + Vars.spacingLarge) : 40

    GridLayout {
        id: trayLayout
        anchors.centerIn: parent
        columns: systemTrayContainer.isVertical ? 1 : Math.max(1, SystemTray.items.length)
        rows: systemTrayContainer.isVertical ? Math.max(1, SystemTray.items.length) : 1
        rowSpacing: Vars.spacingSmall
        columnSpacing: Vars.spacingSmall

        Repeater {
            model: SystemTray.items

            delegate: Rectangle {
                id: controlCenterPill
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                
                // Blanket Style: Transparent normally, soft accent circle on hover
                color: itemMouseArea.pressed ? Qt.rgba(Theme.on_primary.r, Theme.on_primary.g, Theme.on_primary.b, 0.12) : (itemMouseArea.containsMouse ? Qt.rgba(Theme.on_primary.r, Theme.on_primary.g, Theme.on_primary.b, 0.08) : "transparent")
                radius: height / 2

                Behavior on color {
                    ColorAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard }
                }

                property var trayItem: modelData 

                MouseArea {
                    id: itemMouseArea
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: (mouse) => {
                        if (!trayItem) return;
                        if (mouse.button === Qt.RightButton && trayItem.menu) {
                            systemTrayContainer.openTrayMenuRequested(trayItem.menu);
                        } else {
                            trayItem.activate();
                        }
                    }
                }

                Image {
                    id: itemIcon
                    width: 20
                    height: 20
                    anchors.centerIn: parent
                    source: trayItem.icon ? trayItem.icon : "" 
                    fillMode: Image.PreserveAspectFit
                    
                    // Dim inactive tray icons slightly to match the aesthetic
                    opacity: itemMouseArea.containsMouse ? 1.0 : 0.7
                    Behavior on opacity { NumberAnimation { duration: Vars.animationDuration } }
                }
            }
        }
    }
}