import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import "../../.."
import "../../../theme/variables.js" as Vars
import "../../../core/primitives" as Primitives

Item {
    id: btPairDelegate
    property var rootPage

    Layout.fillWidth: true; Layout.preferredHeight: visible ? 72 : 0
    property bool isSelected: modelData.connected
    property bool showForget: false
    visible: !(modelData.paired || modelData.connected)
    
    property color targetColor: isSelected ? (Vars.translucent ? Qt.rgba(Theme.secondary_container.r, Theme.secondary_container.g, Theme.secondary_container.b, Vars.componentOpacity) : Theme.secondary_container) : (btPairItemMouse.containsMouse ? Qt.tint((Vars.translucent ? Qt.rgba(Theme.surface_container.r, Theme.surface_container.g, Theme.surface_container.b, Vars.componentOpacity) : Theme.surface_container), Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08)) : (Vars.translucent ? Qt.rgba(Theme.surface_container.r, Theme.surface_container.g, Theme.surface_container.b, Vars.componentOpacity) : Theme.surface_container))
    Behavior on targetColor { ColorAnimation { duration: Vars.animationDuration } }
    
    property bool hasDeviceBelow: {
        if (!rootPage.adapter || !rootPage.adapter.devices.values) return false;
        for (let i = index + 1; i < rootPage.adapter.devices.values.length; ++i) {
            let d = rootPage.adapter.devices.values[i];
            if (d && !(d.paired || d.connected)) return true;
        }
        return false;
    }
    
    Item {
        anchors.fill: parent
        layer.enabled: true
        opacity: parent.targetColor.a
        Rectangle {
            anchors.fill: parent
            radius: parent.parent.isSelected ? 36 : 16
            Behavior on radius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
            color: Qt.rgba(parent.parent.targetColor.r, parent.parent.targetColor.g, parent.parent.targetColor.b, 1.0)
            
            Rectangle {
                width: parent.radius; height: parent.radius; color: parent.color
                anchors.top: parent.top; anchors.left: parent.left
                opacity: parent.parent.parent.isSelected ? 0.0 : 1.0
                Behavior on opacity { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
            }
            Rectangle {
                width: parent.radius; height: parent.radius; color: parent.color
                anchors.top: parent.top; anchors.right: parent.right
                opacity: parent.parent.parent.isSelected ? 0.0 : 1.0
                Behavior on opacity { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
            }
            Rectangle {
                width: parent.radius; height: parent.radius; color: parent.color
                anchors.bottom: parent.bottom; anchors.left: parent.left
                visible: parent.parent.parent.hasDeviceBelow
                opacity: parent.parent.parent.isSelected ? 0.0 : 1.0
                Behavior on opacity { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
            }
            Rectangle {
                width: parent.radius; height: parent.radius; color: parent.color
                anchors.bottom: parent.bottom; anchors.right: parent.right
                visible: parent.parent.parent.hasDeviceBelow
                opacity: parent.parent.parent.isSelected ? 0.0 : 1.0
                Behavior on opacity { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
            }
        }
    }
    
    RowLayout {
        anchors.fill: parent; anchors.leftMargin: 20; anchors.rightMargin: 20; spacing: 16
        Text { text: "\ue1a7"; font.family: "Material Symbols Outlined"; font.pixelSize: 24; color: Theme.on_surface_variant }
        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter; spacing: 0; Layout.fillWidth: true
            Text { text: modelData.name ? modelData.name : "Unknown Device"; font.family: Vars.fontFamily; font.pixelSize: 16; color: Theme.on_surface; Layout.fillWidth: true; horizontalAlignment: Text.AlignLeft }
            Text { text: "Available to pair"; font.family: Vars.fontFamily; font.pixelSize: 11; font.weight: 500; color: Theme.on_surface_variant; visible: text !== ""; Layout.fillWidth: true; horizontalAlignment: Text.AlignLeft }
        }
        Item {
            width: 40; height: 40
            Layout.alignment: Qt.AlignVCenter
            property bool isChangingState: false
            
            Timer {
                id: stateTimeoutTimer
                interval: 15000
                repeat: false
                onTriggered: parent.isChangingState = false
            }

            Primitives.LoadingIndicator {
                id: btPairLoadingIndicator
                anchors.fill: parent
                running: parent.isChangingState || (modelData.connecting !== undefined ? modelData.connecting : false) || (modelData.stateChanging !== undefined ? modelData.stateChanging : false)
            }
        }
    }
    MouseArea {
        id: btPairItemMouse
        anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
            parent.forceActiveFocus();
            if (mouse.button === Qt.RightButton) {
                btPairDelegate.showForget = true;
            } else {
                if (btPairLoadingIndicator.running) return;
                btPairLoadingIndicator.parent.isChangingState = true;
                stateTimeoutTimer.restart();
                if (!modelData.paired) {
                    if (rootPage.adapter && !rootPage.adapter.pairable) {
                        rootPage.adapter.pairable = true;
                    }
                    modelData.pair();
                } else {
                    modelData.trusted = true;
                    modelData.connect();
                }
            }
        }
    }
    
    Connections {
        target: modelData
        function onPairedChanged() {
            if (modelData.paired) {
                modelData.trusted = true;
                modelData.connect();
            } else {
                btPairLoadingIndicator.parent.isChangingState = false;
                stateTimeoutTimer.stop();
            }
        }
        function onConnectedChanged() {
            btPairLoadingIndicator.parent.isChangingState = false;
            stateTimeoutTimer.stop();
        }
    }
    
    // Forget Overlay
    Rectangle {
        anchors.fill: parent
        radius: parent.isSelected ? 36 : 16
        color: Vars.translucent ? Qt.rgba(Theme.surface_container_highest.r, Theme.surface_container_highest.g, Theme.surface_container_highest.b, 0.85) : Theme.surface_container_highest
        visible: btPairDelegate.showForget
        opacity: btPairDelegate.showForget ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        
        RowLayout {
            anchors.fill: parent; anchors.margins: 16; spacing: 16
            Text {
                text: "Forget " + (modelData.name || "Device") + "?"
                font.family: Vars.fontFamily; font.pixelSize: 16; color: Theme.on_surface; Layout.fillWidth: true; elide: Text.ElideRight
            }
            Rectangle {
                width: 80; height: 32; radius: 16; color: "transparent"
                border.color: Theme.outline; border.width: 1
                Text { anchors.centerIn: parent; text: "Cancel"; color: Theme.on_surface; font.family: Vars.fontFamily; font.pixelSize: 14 }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: btPairDelegate.showForget = false }
            }
            Rectangle {
                width: 80; height: 32; radius: 16; color: Theme.error ? Theme.error : "#ffb4ab"
                Text { anchors.centerIn: parent; text: "Forget"; color: Theme.on_error ? Theme.on_error : "#690005"; font.family: Vars.fontFamily; font.pixelSize: 14; font.weight: 500 }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { if (modelData.forget) modelData.forget(); btPairDelegate.showForget = false; } }
            }
        }
    }
}
