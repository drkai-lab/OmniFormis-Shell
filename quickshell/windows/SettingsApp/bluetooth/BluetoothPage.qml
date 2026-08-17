import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import "../../.."
import "../../../theme"
import "../../../core/primitives" as Primitives
import ".."

ColumnLayout {
    id: rootBluetoothPage
    
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: Vars.spacingMedium

    property var adapter
    property bool adapterState: adapter ? adapter.enabled : false

    property string pageTitle: "Bluetooth Settings"
    property string pageIcon: "\ue15f"
    property string pageShape: "Puffy"
    property color pageColor: Theme.primary
    property color pageOnColor: Theme.on_primary
    property string searchText: ""

    M3Shapes { id: m3Shapes }

    RowLayout {
        Layout.fillWidth: true
        spacing: 12

        Item {
            width: 38
            height: 38

            Image {
                anchors.fill: parent
                sourceSize: Qt.size(width, height)
                source: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><path d='" + m3Shapes.getPath(rootBluetoothPage.pageShape) + "' fill='" + String(rootBluetoothPage.pageColor || "#3b383e").replace("#", "%23") + "'/></svg>"
                smooth: true
                antialiasing: true
            }

            QsText {
                anchors.centerIn: parent
                text: rootBluetoothPage.pageIcon
                font.family: "Material Symbols Outlined"
                font.pixelSize: 20
                color: rootBluetoothPage.pageOnColor
            }
        }

        QsText {
            Layout.fillWidth: true
            text: rootBluetoothPage.pageTitle
            font.family: Vars.fontFamily
            font.pixelSize: 18
            setWeight: 600
            color: Theme.on_surface
            elide: Text.ElideRight
        }
    }

    Flickable {
        Layout.fillWidth: true; Layout.fillHeight: true
        contentHeight: btContent.implicitHeight; clip: true
        // boundsBehavior: Flickable.StopAtBounds
        flickDeceleration: Vars.flickDeceleration
        maximumFlickVelocity: Vars.maximumFlickVelocity


        ColumnLayout {
            id: btContent
            width: parent.width; spacing: Vars.spacingSmall
            property bool isPairingMode: false

            // --- MAIN BLUETOOTH VIEW ---
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Vars.spacingSmall
                visible: !btContent.isPairingMode

                // Main Bluetooth Group
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    // Bluetooth Header Card
                    Item {
                        id: btHeader
                        Layout.fillWidth: true; Layout.preferredHeight: 72
                        
                        property color targetColor: btHeaderMouse.containsMouse ? Qt.tint((Vars.tColor(Theme.surface_container, Vars.componentOpacity)), Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08)) : (Vars.tColor(Theme.surface_container, Vars.componentOpacity))
                        Behavior on targetColor { ColorAnimation { duration: Vars.animationDuration } }
                        
                        property bool hasDeviceBelow: {
                            if (!rootBluetoothPage.adapter || !rootBluetoothPage.adapter.devices.values) return false;
                            for (let i = 0; i < rootBluetoothPage.adapter.devices.values.length; ++i) {
                                let d = rootBluetoothPage.adapter.devices.values[i];
                                if (d && (d.paired || d.connected)) return true;
                            }
                            return false;
                        }
                        
                        property bool firstDeviceConnected: rootBluetoothPage.adapter && rootBluetoothPage.adapter.devices.values && rootBluetoothPage.adapter.devices.values.length > 0 && rootBluetoothPage.adapter.devices.values[0].connected
                        
                        Item {
                            anchors.fill: parent
                            layer.enabled: true
                            layer.samples: 32
                            opacity: parent.targetColor.a
                            Rectangle {
                                anchors.fill: parent
                                color: Qt.rgba(parent.parent.targetColor.r, parent.parent.targetColor.g, parent.parent.targetColor.b, 1.0)
                                topLeftRadius: 16
                                topRightRadius: 16
                                bottomLeftRadius: rootBluetoothPage.adapterState && parent.parent.parent.hasDeviceBelow ? (parent.parent.parent.firstDeviceConnected ? 16 : 4) : 16
                                bottomRightRadius: rootBluetoothPage.adapterState && parent.parent.parent.hasDeviceBelow ? (parent.parent.parent.firstDeviceConnected ? 16 : 4) : 16
                                
                                Behavior on bottomLeftRadius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
                                Behavior on bottomRightRadius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
                            }
                        }
                        
                        activeFocusOnTab: true
                        Keys.onSpacePressed: if(rootBluetoothPage.adapter) rootBluetoothPage.adapter.enabled = !rootBluetoothPage.adapter.enabled
                        Keys.onReturnPressed: if(rootBluetoothPage.adapter) rootBluetoothPage.adapter.enabled = !rootBluetoothPage.adapter.enabled
                        
                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 20; anchors.rightMargin: 20
                            QsText { text: rootBluetoothPage.pageTitle; font.family: Vars.fontFamily; font.pixelSize: 16; setWeight: 500; color: Theme.on_surface; Layout.fillWidth: true }
                            
                            Rectangle {
                                width: 52; height: 32; radius: 16
                                color: rootBluetoothPage.adapterState ? Theme.primary : Theme.surface_variant
                                border.color: btHeader.activeFocus ? Theme.on_surface : "transparent"
                                border.width: btHeader.activeFocus ? 2 : 0
                                Rectangle {
                                    width: 24; height: 24; radius: 12
                                    color: rootBluetoothPage.adapterState ? Theme.on_primary : Theme.on_surface_variant
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left; anchors.leftMargin: rootBluetoothPage.adapterState ? 24 : 4
                                    Behavior on anchors.leftMargin { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard } }
                                    QsText { anchors.centerIn: parent; font.family: "Material Symbols Outlined"; font.pixelSize: 16; color: rootBluetoothPage.adapterState ? Theme.primary : Theme.surface_variant; text: rootBluetoothPage.adapterState ? "\ue5ca" : "\ue5cd" }
                                }
                            }
                        }
                        MouseArea { id: btHeaderMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true; onClicked: { btHeader.forceActiveFocus(); if(rootBluetoothPage.adapter) rootBluetoothPage.adapter.enabled = !rootBluetoothPage.adapter.enabled; } }
                    }

                    // Empty state (only if enabled and no devices)
                    Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: 120
                        visible: rootBluetoothPage.adapterState && (!rootBluetoothPage.adapter || rootBluetoothPage.adapter.devices.values.length === 0)
                        radius: 16; color: Vars.tColor(Theme.surface_container, Vars.componentOpacity)
                        antialiasing: true
                        
                        ColumnLayout {
                            anchors.centerIn: parent; spacing: 8
                            QsText { text: "\ue322"; font.family: "Material Symbols Outlined"; font.pixelSize: 32; color: Theme.on_surface_variant; Layout.alignment: Qt.AlignHCenter } // Devices icon
                            QsText { text: "No saved devices"; font.family: Vars.fontFamily; font.pixelSize: 16; color: Theme.on_surface_variant; Layout.alignment: Qt.AlignHCenter }
                        }
                    }

                    // Device List
                    Repeater {
                        model: rootBluetoothPage.adapter && rootBluetoothPage.adapterState ? rootBluetoothPage.adapter.devices.values : []
                        delegate: BluetoothDeviceDelegate {
                            rootPage: rootBluetoothPage
                        }
                    }

                    // Pair new device
                    Item {
                        Layout.fillWidth: true; Layout.preferredHeight: 72
                        visible: rootBluetoothPage.adapterState
                        
                        property color targetColor: btPairMouse.containsMouse ? Qt.tint((Vars.tColor(Theme.surface_container, Vars.componentOpacity)), Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08)) : (Vars.tColor(Theme.surface_container, Vars.componentOpacity))
                        Behavior on targetColor { ColorAnimation { duration: Vars.animationDuration } }
                        
                        property bool lastDeviceConnected: rootBluetoothPage.adapter && rootBluetoothPage.adapter.devices.values && rootBluetoothPage.adapter.devices.values.length > 0 && rootBluetoothPage.adapter.devices.values[rootBluetoothPage.adapter.devices.values.length - 1].connected
                        
                        Item {
                            anchors.fill: parent
                            layer.enabled: true
                            layer.samples: 32
                            opacity: parent.targetColor.a
                            Rectangle {
                                anchors.fill: parent
                                color: Qt.rgba(parent.parent.targetColor.r, parent.parent.targetColor.g, parent.parent.targetColor.b, 1.0)
                                
                                topLeftRadius: parent.parent.parent.lastDeviceConnected ? 16 : 4
                                topRightRadius: parent.parent.parent.lastDeviceConnected ? 16 : 4
                                bottomLeftRadius: 16
                                bottomRightRadius: 16
                                
                                Behavior on topLeftRadius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
                                Behavior on topRightRadius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
                            }
                        }
                        
                        activeFocusOnTab: true
                        Keys.onSpacePressed: parent.forceActiveFocus()
                        Keys.onReturnPressed: parent.forceActiveFocus()
                        
                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 20; anchors.rightMargin: 20; spacing: 16
                            QsText { text: "\ue145"; font.family: "Material Symbols Outlined"; font.pixelSize: 24; color: Theme.on_surface }
                            QsText { text: "Pair new device"; font.family: Vars.fontFamily; font.pixelSize: 16; setWeight: 500; color: Theme.on_surface; Layout.fillWidth: true }
                        }
                        MouseArea { id: btPairMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { parent.forceActiveFocus(); btContent.isPairingMode = true; } }
                    }
                }

                Item { Layout.preferredHeight: Vars.spacingSmall }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    // Discoverable Card
                    Item {
                        id: discCard
                        Layout.fillWidth: true; Layout.preferredHeight: 72
                        visible: rootBluetoothPage.adapterState
                        
                        property color targetColor: discMouse.containsMouse ? Qt.tint((Vars.tColor(Theme.surface_container, Vars.componentOpacity)), Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08)) : (Vars.tColor(Theme.surface_container, Vars.componentOpacity))
                        Behavior on targetColor { ColorAnimation { duration: Vars.animationDuration } }
                        
                        Item {
                            anchors.fill: parent
                            layer.enabled: true
                            layer.samples: 32
                            opacity: parent.targetColor.a
                            Rectangle {
                                anchors.fill: parent
                                color: Qt.rgba(parent.parent.targetColor.r, parent.parent.targetColor.g, parent.parent.targetColor.b, 1.0)
                                
                                topLeftRadius: 16
                                topRightRadius: 16
                                bottomLeftRadius: 4
                                bottomRightRadius: 4
                            }
                        }
                        
                        activeFocusOnTab: true
                        Keys.onSpacePressed: if(rootBluetoothPage.adapter) rootBluetoothPage.adapter.discoverable = !rootBluetoothPage.adapter.discoverable
                        Keys.onReturnPressed: if(rootBluetoothPage.adapter) rootBluetoothPage.adapter.discoverable = !rootBluetoothPage.adapter.discoverable
                        
                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 20; anchors.rightMargin: 20; spacing: 16
                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 2
                                QsText { text: "Discoverable"; font.family: Vars.fontFamily; font.pixelSize: 16; color: Theme.on_surface; Layout.fillWidth: true; horizontalAlignment: Text.AlignLeft }
                                QsText { text: "Allow nearby devices to find this one"; font.family: Vars.fontFamily; font.pixelSize: 13; color: Theme.on_surface_variant; Layout.fillWidth: true; horizontalAlignment: Text.AlignLeft }
                            }
                            Rectangle {
                                width: 52; height: 32; radius: 16; color: rootBluetoothPage.adapter && rootBluetoothPage.adapter.discoverable ? Theme.primary : Theme.surface_variant
                                border.color: discCard.activeFocus ? Theme.on_surface : "transparent"; border.width: discCard.activeFocus ? 2 : 0
                                Rectangle {
                                    width: 24; height: 24; radius: 12; color: rootBluetoothPage.adapter && rootBluetoothPage.adapter.discoverable ? Theme.on_primary : Theme.on_surface_variant
                                    anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: rootBluetoothPage.adapter && rootBluetoothPage.adapter.discoverable ? 24 : 4
                                    Behavior on anchors.leftMargin { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard } }
                                    QsText { anchors.centerIn: parent; font.family: "Material Symbols Outlined"; font.pixelSize: 16; color: rootBluetoothPage.adapter && rootBluetoothPage.adapter.discoverable ? Theme.primary : Theme.surface_variant; text: rootBluetoothPage.adapter && rootBluetoothPage.adapter.discoverable ? "\ue5ca" : "\ue5cd" }
                                }
                            }
                        }
                        MouseArea { id: discMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { discCard.forceActiveFocus(); if(rootBluetoothPage.adapter) rootBluetoothPage.adapter.discoverable = !rootBluetoothPage.adapter.discoverable } }
                    }

                    // Pairable Card
                    Item {
                        id: pairCard
                        Layout.fillWidth: true; Layout.preferredHeight: 72
                        visible: rootBluetoothPage.adapterState
                        
                        property color targetColor: pairMouse.containsMouse ? Qt.tint((Vars.tColor(Theme.surface_container, Vars.componentOpacity)), Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08)) : (Vars.tColor(Theme.surface_container, Vars.componentOpacity))
                        Behavior on targetColor { ColorAnimation { duration: Vars.animationDuration } }
                        
                        Item {
                            anchors.fill: parent
                            layer.enabled: true
                            layer.samples: 32
                            opacity: parent.targetColor.a
                            Rectangle {
                                anchors.fill: parent
                                color: Qt.rgba(parent.parent.targetColor.r, parent.parent.targetColor.g, parent.parent.targetColor.b, 1.0)
                                
                                topLeftRadius: 4
                                topRightRadius: 4
                                bottomLeftRadius: 16
                                bottomRightRadius: 16
                            }
                        }
                        
                        activeFocusOnTab: true
                        Keys.onSpacePressed: if(rootBluetoothPage.adapter) rootBluetoothPage.adapter.pairable = !rootBluetoothPage.adapter.pairable
                        Keys.onReturnPressed: if(rootBluetoothPage.adapter) rootBluetoothPage.adapter.pairable = !rootBluetoothPage.adapter.pairable
                        
                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 20; anchors.rightMargin: 20; spacing: 16
                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 2
                                QsText { text: "Pairable"; font.family: Vars.fontFamily; font.pixelSize: 16; color: Theme.on_surface; Layout.fillWidth: true; horizontalAlignment: Text.AlignLeft }
                                QsText { text: "Allow devices like phones to pair to this PC (not needed for speakers)"; font.family: Vars.fontFamily; font.pixelSize: 13; color: Theme.on_surface_variant; Layout.fillWidth: true; horizontalAlignment: Text.AlignLeft }
                            }
                            Rectangle {
                                width: 52; height: 32; radius: 16; color: rootBluetoothPage.adapter && rootBluetoothPage.adapter.pairable ? Theme.primary : Theme.surface_variant
                                border.color: pairCard.activeFocus ? Theme.on_surface : "transparent"; border.width: pairCard.activeFocus ? 2 : 0
                                Rectangle {
                                    width: 24; height: 24; radius: 12; color: rootBluetoothPage.adapter && rootBluetoothPage.adapter.pairable ? Theme.on_primary : Theme.on_surface_variant
                                    anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: rootBluetoothPage.adapter && rootBluetoothPage.adapter.pairable ? 24 : 4
                                    Behavior on anchors.leftMargin { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard } }
                                    QsText { anchors.centerIn: parent; font.family: "Material Symbols Outlined"; font.pixelSize: 16; color: rootBluetoothPage.adapter && rootBluetoothPage.adapter.pairable ? Theme.primary : Theme.surface_variant; text: rootBluetoothPage.adapter && rootBluetoothPage.adapter.pairable ? "\ue5ca" : "\ue5cd" }
                                }
                            }
                        }
                        MouseArea { id: pairMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { pairCard.forceActiveFocus(); if(rootBluetoothPage.adapter) rootBluetoothPage.adapter.pairable = !rootBluetoothPage.adapter.pairable } }
                    }
                }
            }

            // --- PAIRING VIEW ---
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                visible: btContent.isPairingMode

                // Pairing Header Card
                Item {
                    id: pairingHeader
                    Layout.fillWidth: true; Layout.preferredHeight: 72
                    
                    property color targetColor: Vars.tColor(Theme.surface_container, Vars.componentOpacity)
                    
                    property bool hasDeviceBelow: {
                        if (!rootBluetoothPage.adapter || !rootBluetoothPage.adapter.devices.values) return false;
                        for (let i = 0; i < rootBluetoothPage.adapter.devices.values.length; ++i) {
                            let d = rootBluetoothPage.adapter.devices.values[i];
                            if (d && !(d.paired || d.connected)) return true;
                        }
                        return false;
                    }
                    
                    Item {
                        anchors.fill: parent
                        layer.enabled: true
                        layer.samples: 32
                        opacity: pairingHeader.targetColor.a
                        Rectangle {
                            anchors.fill: parent
                            color: Qt.rgba(pairingHeader.targetColor.r, pairingHeader.targetColor.g, pairingHeader.targetColor.b, 1.0)
                            
                            topLeftRadius: 16
                            topRightRadius: 16
                            bottomLeftRadius: pairingHeader.hasDeviceBelow ? 4 : 16
                            bottomRightRadius: pairingHeader.hasDeviceBelow ? 4 : 16
                        }
                    }
                    
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 20; anchors.rightMargin: 20; spacing: 16
                        
                        // Back button
                        Rectangle {
                            width: 40; height: 40; radius: 20; color: backMouse.containsMouse ? Qt.tint(Theme.surface_container, Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.12)) : "transparent"
                            QsText { anchors.centerIn: parent; font.family: "Material Symbols Outlined"; font.pixelSize: 24; color: Theme.on_surface; text: "\ue5c4" }
                            MouseArea { id: backMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: btContent.isPairingMode = false }
                        }

                        QsText { text: "Pair new device"; font.family: Vars.fontFamily; font.pixelSize: 16; setWeight: 500; color: Theme.on_surface; Layout.fillWidth: true }
                        
                        // Discovering Toggle
                        Rectangle {
                            width: 52; height: 32; radius: 16
                            property bool isDiscovering: rootBluetoothPage.adapter && rootBluetoothPage.adapter.discovering !== undefined ? rootBluetoothPage.adapter.discovering : false
                            color: isDiscovering ? Theme.primary : Theme.surface_variant
                            Rectangle {
                                width: 24; height: 24; radius: 12
                                color: parent.isDiscovering ? Theme.on_primary : Theme.on_surface_variant
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left; anchors.leftMargin: parent.isDiscovering ? 24 : 4
                                Behavior on anchors.leftMargin { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard } }
                                Item {
                                    anchors.fill: parent
                                    visible: parent.parent.isDiscovering
                                    Primitives.LoadingIndicator {
                                        anchors.fill: parent
                                        running: parent.visible
                                    }
                                }
                                QsText { 
                                    anchors.centerIn: parent; font.family: "Material Symbols Outlined"; font.pixelSize: 16
                                    color: Theme.surface_variant
                                    text: "\ue5cd"
                                    visible: !parent.parent.isDiscovering
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (rootBluetoothPage.adapter) {
                                        rootBluetoothPage.adapter.discovering = !rootBluetoothPage.adapter.discovering;
                                    }
                                }
                            }
                        }
                    }
                }

                // Empty state
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    visible: !pairingHeader.hasDeviceBelow
                    radius: 16
                    antialiasing: true
                    color: "transparent"
                    
                    Primitives.LoadingIndicator {
                        width: 96
                        height: 96
                        anchors.centerIn: parent
                        running: rootBluetoothPage.adapter && rootBluetoothPage.adapter.discovering && !pairingHeader.hasDeviceBelow
                        visible: running
                    }
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        visible: !(rootBluetoothPage.adapter && rootBluetoothPage.adapter.discovering)
                        QsText {
                            text: "\ue1a7"
                            font.family: "Material Symbols Outlined"
                            font.pixelSize: 32
                            color: Theme.on_surface_variant
                            Layout.alignment: Qt.AlignHCenter
                        }
                        QsText {
                            text: "No devices found"
                            font.family: Vars.fontFamily
                            font.pixelSize: 16
                            color: Theme.on_surface_variant
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                // Device List
                Repeater {
                    model: rootBluetoothPage.adapter && rootBluetoothPage.adapterState && rootBluetoothPage.adapter.discovering ? rootBluetoothPage.adapter.devices.values : []
                    delegate: BluetoothPairDelegate {
                        rootPage: rootBluetoothPage
                    }
                }
            }
        }
    }
}
