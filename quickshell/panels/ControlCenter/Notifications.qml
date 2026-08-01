import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import "../../theme/variables.js" as Vars
import "../.."

Item {
    id: notificationsRoot
    Layout.fillWidth: true
    implicitHeight: mainLayout.implicitHeight

    property var historyList: []

    property int draggedIndex: -1
    property real draggedX: 0

    Timer {
        interval: 200
        running: true
        repeat: true
        property int lastSync: -1
        onTriggered: {
            if (lastSync !== Vars.historyUpdated) {
                lastSync = Vars.historyUpdated;
                notificationsRoot.historyList = Vars.notificationHistory.slice();
            }
        }
    }

    ColumnLayout {
        id: mainLayout
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 2

        // Empty State
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            Layout.topMargin: Vars.spacingSmall
            radius: Vars.radiusLarge
            color: Theme.surface_container_high
            visible: notificationsRoot.historyList.length === 0
            
            Text {
                text: "No new notifications"
                font.family: Vars.fontFamily; font.pixelSize: 14; color: Theme.on_surface_variant
                anchors.centerIn: parent
            }
        }

        Repeater {
            model: notificationsRoot.historyList

            delegate: Item {
                Layout.fillWidth: true
                height: card.height
                clip: true

                Behavior on height {
                    NumberAnimation {
                        duration: Vars.animationDuration
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Vars.customStandard
                    }
                }
                
                NotificationCard {
                    id: card
                    modelData: notificationsRoot.historyList[index]
                    isPopup: false
                    fontName: Vars.fontFamily
                    width: parent.width
                    
                    listIndex: index
                    listCount: notificationsRoot.historyList.length
                    
                    activeDragIndex: notificationsRoot.draggedIndex
                    activeDragX: notificationsRoot.draggedX
                    
                    onDragStarted: (idx) => { notificationsRoot.draggedIndex = idx; }
                    onDragMoved: (idx, dx) => { if (notificationsRoot.draggedIndex === idx) notificationsRoot.draggedX = dx; }
                    onDragEnded: (idx) => { 
                        if (notificationsRoot.draggedIndex === idx) {
                            notificationsRoot.draggedIndex = -1;
                            notificationsRoot.draggedX = 0;
                        }
                    }
                }
            }
        }

        Item {
            Layout.preferredHeight: 80
            Layout.fillWidth: true
            visible: notificationsRoot.historyList.length > 0
        }
    }

    // Floating action bar
    Rectangle {
        id: fabContainer
        
        property color opaqueSecondary: Qt.rgba(Theme.secondary_container.r, Theme.secondary_container.g, Theme.secondary_container.b, 1.0)
        property color opaqueSurface: Qt.rgba(Theme.surface_container_highest.r, Theme.surface_container_highest.g, Theme.surface_container_highest.b, 1.0)

        
        function getFlickable(item) {
            let p = item.parent;
            while (p) {
                if (p.toString().includes("Flickable")) return p;
                p = p.parent;
            }
            return item;
        }
        
        // Reparent to Flickable so it floats above the scrolling content
        parent: getFlickable(notificationsRoot)
        
        width: notificationsRoot.width
        height: 64
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        x: notificationsRoot.mapToItem(parent, 0, 0).x
        
        color: "transparent"
        visible: notificationsRoot.historyList.length > 0
        z: 100
        
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 8
            
            // Snooze button
            Rectangle {
                property real targetWidth: snoozeHover.pressed ? 82 : (clearAllHover.pressed ? 46 : 64)
                Layout.preferredWidth: targetWidth
                Behavior on targetWidth { NumberAnimation { duration: 150; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard } }

                Layout.preferredHeight: 48
                radius: 24
                layer.enabled: true
                layer.effect: MultiEffect { shadowEnabled: true; shadowBlur: 1.0; shadowColor: Qt.rgba(0,0,0,0.25); shadowVerticalOffset: 4; shadowHorizontalOffset: 0 }
                
                color: snoozeHover.pressed ? Qt.tint(fabContainer.opaqueSecondary, Qt.rgba(Theme.on_secondary_container.r, Theme.on_secondary_container.g, Theme.on_secondary_container.b, 0.12)) : (snoozeHover.containsMouse ? Qt.tint(fabContainer.opaqueSecondary, Qt.rgba(Theme.on_secondary_container.r, Theme.on_secondary_container.g, Theme.on_secondary_container.b, 0.08)) : fabContainer.opaqueSecondary)
                Behavior on color { ColorAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard } }
                
                Text {
                    anchors.centerIn: parent
                    text: "\ue8b5" // schedule/snooze icon
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: 20
                    color: Theme.on_secondary_container
                }
                MouseArea {
                    id: snoozeHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    // No-op for now, as requested
                }
            }

            // Clear all button
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                radius: 24
                layer.enabled: true
                layer.effect: MultiEffect { shadowEnabled: true; shadowBlur: 1.0; shadowColor: Qt.rgba(0,0,0,0.25); shadowVerticalOffset: 4; shadowHorizontalOffset: 0 }
                
                color: clearAllHover.pressed ? Qt.tint(fabContainer.opaqueSurface, Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.12)) : (clearAllHover.containsMouse ? Qt.tint(fabContainer.opaqueSurface, Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08)) : fabContainer.opaqueSurface)
                Behavior on color { ColorAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard } }
                
                Text {
                    anchors.centerIn: parent
                    text: "Clear all"
                    font.family: Vars.fontFamily
                    font.pixelSize: 14
                    font.weight: 600
                    color: Theme.on_surface
                }
                MouseArea {
                    id: clearAllHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Vars.clearNotifications()
                }
            }

            // Settings button
            Rectangle {
                property real targetWidth: settingsHover.pressed ? 82 : (clearAllHover.pressed ? 46 : 64)
                Layout.preferredWidth: targetWidth
                Behavior on targetWidth { NumberAnimation { duration: 150; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard } }

                Layout.preferredHeight: 48
                radius: 24
                layer.enabled: true
                layer.effect: MultiEffect { shadowEnabled: true; shadowBlur: 1.0; shadowColor: Qt.rgba(0,0,0,0.25); shadowVerticalOffset: 4; shadowHorizontalOffset: 0 }
                
                color: settingsHover.pressed ? Qt.tint(fabContainer.opaqueSecondary, Qt.rgba(Theme.on_secondary_container.r, Theme.on_secondary_container.g, Theme.on_secondary_container.b, 0.12)) : (settingsHover.containsMouse ? Qt.tint(fabContainer.opaqueSecondary, Qt.rgba(Theme.on_secondary_container.r, Theme.on_secondary_container.g, Theme.on_secondary_container.b, 0.08)) : fabContainer.opaqueSecondary)
                Behavior on color { ColorAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard } }
                
                Text {
                    anchors.centerIn: parent
                    text: "\ue8b8" // settings icon
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: 20
                    color: Theme.on_secondary_container
                }
                MouseArea {
                    id: settingsHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    // Mock button for now
                }
            }
        }
    }
}
