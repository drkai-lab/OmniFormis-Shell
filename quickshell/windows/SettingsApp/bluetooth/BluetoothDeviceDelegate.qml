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
    id: btDelegate
    property var rootPage

    Layout.fillWidth: true; Layout.preferredHeight: visible ? 72 : 0
    visible: modelData.paired || modelData.connected
    property bool isSelected: modelData.connected
    property bool showForget: false
    
    property color targetColor: isSelected ? (Vars.tColor(Theme.secondary_container, Vars.componentOpacity)) : (btMouse.containsMouse ? Qt.tint((Vars.tColor(Theme.surface_container, Vars.componentOpacity)), Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08)) : (Vars.tColor(Theme.surface_container, Vars.componentOpacity)))
    Behavior on targetColor { ColorAnimation { duration: Vars.animationDuration } }
    
    property bool hasDeviceBelow: {
        if (!rootPage.adapter || !rootPage.adapter.devices.values) return false;
        for (let i = index + 1; i < rootPage.adapter.devices.values.length; ++i) {
            let d = rootPage.adapter.devices.values[i];
            if (d && (d.paired || d.connected)) return true;
        }
        return true; // Pair new device is ALWAYS below!
    }
    
    Item {
        anchors.fill: parent
        layer.enabled: true
        opacity: parent.targetColor.a
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(parent.parent.targetColor.r, parent.parent.targetColor.g, parent.parent.targetColor.b, 1.0)
            
            property real baseRadius: parent.parent.isSelected ? 36 : 16
            property real edgeRadius: parent.parent.isSelected ? 36 : 4
            
            topLeftRadius: edgeRadius
            topRightRadius: edgeRadius
            bottomLeftRadius: parent.parent.hasDeviceBelow ? edgeRadius : baseRadius
            bottomRightRadius: parent.parent.hasDeviceBelow ? edgeRadius : baseRadius

            Behavior on topLeftRadius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
            Behavior on topRightRadius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
            Behavior on bottomLeftRadius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
            Behavior on bottomRightRadius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        }
    }

    property bool isChangingState: false
    
    Timer {
        id: stateTimeoutTimer
        interval: 15000 // 15-second safety timeout if connection attempt stalls
        repeat: false
        onTriggered: btDelegate.isChangingState = false
    }

    Connections {
        target: modelData
        function onConnectedChanged() {
            btDelegate.isChangingState = false;
            stateTimeoutTimer.stop();
        }
    }

    function toggleConnection() {
        if (btDelegate.isChangingState) return;
        btDelegate.isChangingState = true;
        stateTimeoutTimer.restart();
        if (modelData.connected) {
            modelData.disconnect();
        } else {
            modelData.trusted = true;
            modelData.connect();
        }
    }

    activeFocusOnTab: true
    Keys.onSpacePressed: toggleConnection()
    Keys.onReturnPressed: toggleConnection()
    
    FontLoader {
        id: filledIconFont
        source: "../../../theme/assets/MaterialSymbolsRounded-Filled.ttf"
    }

    RowLayout {
        anchors.fill: parent; anchors.leftMargin: 20; anchors.rightMargin: 20; spacing: 16
        Item {
            width: 40; height: 40
            Layout.alignment: Qt.AlignVCenter
            QsText { anchors.centerIn: parent; text: modelData.connected ? "\ue1a8" : "\ue1a7"; font.family: modelData.connected ? filledIconFont.name : "Material Symbols Outlined"; font.pixelSize: 24; color: modelData.connected ? Theme.primary : Theme.on_surface_variant }
        }
        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter; spacing: 0; Layout.fillWidth: true
            QsText { text: modelData.name ? modelData.name : "Unknown Device"; font.family: Vars.fontFamily; font.pixelSize: 16; color: Theme.on_surface; Layout.fillWidth: true; horizontalAlignment: Text.AlignLeft }
            QsText { text: modelData.connected ? "Connected" : "Available"; font.family: Vars.fontFamily; font.pixelSize: 11; setWeight: 500; color: Theme.on_surface_variant; visible: text !== ""; Layout.fillWidth: true; horizontalAlignment: Text.AlignLeft }
        }
        Item {
            width: 40; height: 40
            Layout.alignment: Qt.AlignVCenter
            Primitives.LoadingIndicator {
                anchors.fill: parent
                running: btDelegate.isChangingState || (modelData.connecting !== undefined ? modelData.connecting : false) || (modelData.stateChanging !== undefined ? modelData.stateChanging : false)
            }
        }
    }
    MouseArea {
        id: btMouse
        anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
            parent.forceActiveFocus();
            if (mouse.button === Qt.RightButton) {
                btDelegate.showForget = true;
            } else {
                toggleConnection();
            }
        }
    }
    
    // Forget Overlay
    Rectangle {
        anchors.fill: parent
        
        property real baseRadius: parent.isSelected ? 36 : 16
        property real edgeRadius: parent.isSelected ? 36 : 4
        
        topLeftRadius: edgeRadius
        topRightRadius: edgeRadius
        bottomLeftRadius: parent.hasDeviceBelow ? edgeRadius : baseRadius
        bottomRightRadius: parent.hasDeviceBelow ? edgeRadius : baseRadius

        Behavior on topLeftRadius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on topRightRadius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on bottomLeftRadius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on bottomRightRadius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        color: Vars.tColor(Theme.surface_container_highest, Vars.componentOpacity)
        visible: btDelegate.showForget
        opacity: btDelegate.showForget ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        
        RowLayout {
            anchors.fill: parent; anchors.margins: 16; spacing: 16
            QsText {
                text: "Forget " + (modelData.name || "Device") + "?"
                font.family: Vars.fontFamily; font.pixelSize: 16; color: Theme.on_surface; Layout.fillWidth: true; elide: Text.ElideRight
            }
            Rectangle {
                width: 80; height: 32; radius: 16; color: "transparent"
                border.color: Theme.outline; border.width: 1
                QsText { anchors.centerIn: parent; text: "Cancel"; color: Theme.on_surface; font.family: Vars.fontFamily; font.pixelSize: 14 }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: btDelegate.showForget = false }
            }
            Rectangle {
                width: 80; height: 32; radius: 16; color: Theme.error ? Theme.error : "#ffb4ab"
                QsText { anchors.centerIn: parent; text: "Forget"; color: Theme.on_error ? Theme.on_error : "#690005"; font.family: Vars.fontFamily; font.pixelSize: 14; setWeight: 500 }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { if (modelData.forget) modelData.forget(); btDelegate.showForget = false; } }
            }
        }
    }
}
