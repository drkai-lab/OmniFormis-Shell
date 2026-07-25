import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import "../.."
import "../../theme/variables.js" as Vars
import Quickshell.Networking
import Quickshell.Bluetooth

ColumnLayout {
    id: rootSidebar
    
    M3Shapes { id: m3Shapes }
    
    property string currentSection: "wifi"

    property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
    property var activeNet: wifiDevice ? wifiDevice.networks.values.find(n => n.connected) : null
    property var signal: activeNet ? activeNet.signalStrength : 0

    property string wifiIcon: {
        if (!Networking.wifiEnabled) return "\ue63e";
        if (!activeNet) return "\ue1ba";
        let tier = Math.min(Math.floor(signal / 25), 3);
        let icons = ["\ue1ba", "\uebe4", "\uebd6", "\uebe1"];
        return icons[tier] || "\ue1ba";
    }

    property var adapter: Bluetooth.defaultAdapter
    property bool adapterState: adapter ? adapter.enabled : false
    property var connectDevice: adapter ? adapter.devices.values.find(d => d.connected) : null

    property string bluetoothIcon: {
        if (!adapterState) return "\ue1a9";
        if (!connectDevice) return "\ue1a7";
        return "\ue1a8";
    }

    Layout.fillWidth: true
    spacing: 4

    FontLoader {
        id: filledIconFont
        source: "../../theme/assets/MaterialSymbolsRounded-Filled.ttf"
    }

    Repeater {
        model: [
            // Connections
            { id: "wifi", name: "Wi-Fi", subtitle: "Wi-Fi, ethernet", icon: rootSidebar.wifiIcon, section: "Connections", isFirst: true, isLast: false, hue: 0.60, shape: "Circle" },
            { id: "bluetooth", name: "Bluetooth", subtitle: "Bluetooth, pairing", icon: rootSidebar.bluetoothIcon, section: "Connections", isFirst: false, isLast: true, hue: 0.65, shape: "Square" },
            
            // General and Appearance
            { id: "General", name: "General", subtitle: "System config, spacing, layout", icon: "\ue8b8", section: "General and Appearance", isFirst: true, isLast: false, hue: 0.70, shape: "4SidedCookie" },
            { id: "Appearance", name: "Appearance", subtitle: "Theme, rounding, colors", icon: "\ue3b7", section: "General and Appearance", isFirst: false, isLast: false, hue: 0.85, shape: "Bun" },
            { id: "Input", name: "Input", subtitle: "Keyboard, mouse, gestures", icon: "\ue312", section: "General and Appearance", isFirst: false, isLast: false, hue: 0.95, shape: "Pill" },
            { id: "bezier", name: "Motion", subtitle: "Custom curve editor", icon: "\ue922", section: "General and Appearance", isFirst: false, isLast: true, hue: 0.05, shape: "Oval" },
            
            // System
            { id: "taskmanager", name: "Task Manager", subtitle: "System resources, processes", icon: "\ue85c", section: "System", isFirst: true, isLast: false, hue: 0.12, shape: "6SidedCookie" },
            { id: "about", name: "About", subtitle: "Omniformis Shell info", icon: "\ue88e", section: "System", isFirst: false, isLast: true, hue: 0.18, shape: "12SidedCookie" }
        ]
        delegate: ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: (modelData.isFirst && index !== 0) ? 16 : 0
            spacing: 4



            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 72
                property bool isSelected: rootSidebar.currentSection === modelData.id
                
                // Determine target color (which may contain alpha)
                property color targetColor: isSelected ? (Vars.translucent ? Qt.rgba(Theme.secondary_container.r, Theme.secondary_container.g, Theme.secondary_container.b, 0.5) : Theme.secondary_container) : (navHover.containsMouse ? Qt.tint((Vars.translucent ? Qt.rgba(Theme.surface_container.r, Theme.surface_container.g, Theme.surface_container.b, 0.5) : Theme.surface_container), Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08)) : (Vars.translucent ? Qt.rgba(Theme.surface_container.r, Theme.surface_container.g, Theme.surface_container.b, 0.5) : Theme.surface_container))
                Behavior on targetColor { ColorAnimation { duration: Vars.animationDuration } }

                Item {
                    anchors.fill: parent
                    layer.enabled: true
                    opacity: parent.targetColor.a

                    Rectangle {
                        anchors.fill: parent
                        radius: parent.parent.isSelected ? height / 2 : 16
                        Behavior on radius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
                        color: Qt.rgba(parent.parent.targetColor.r, parent.parent.targetColor.g, parent.parent.targetColor.b, 1.0)
                        
                        // Square-off top corners if not the first item
                        Rectangle {
                            width: parent.radius; height: parent.radius; color: parent.color
                            anchors.top: parent.top; anchors.left: parent.left
                            opacity: (!modelData.isFirst && !parent.parent.parent.isSelected) ? 1.0 : 0.0
                            Behavior on opacity { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
                        }
                        Rectangle {
                            width: parent.radius; height: parent.radius; color: parent.color
                            anchors.top: parent.top; anchors.right: parent.right
                            opacity: (!modelData.isFirst && !parent.parent.parent.isSelected) ? 1.0 : 0.0
                            Behavior on opacity { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
                        }
                        // Square-off bottom corners if not the last item
                        Rectangle {
                            width: parent.radius; height: parent.radius; color: parent.color
                            anchors.bottom: parent.bottom; anchors.left: parent.left
                            opacity: (!modelData.isLast && !parent.parent.parent.isSelected) ? 1.0 : 0.0
                            Behavior on opacity { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
                        }
                        Rectangle {
                            width: parent.radius; height: parent.radius; color: parent.color
                            anchors.bottom: parent.bottom; anchors.right: parent.right
                            opacity: (!modelData.isLast && !parent.parent.parent.isSelected) ? 1.0 : 0.0
                            Behavior on opacity { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
                        }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 16
                    
                    Item {
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        
                        property color containerColor: Qt.hsla(modelData.hue, 0.35, 0.82, 1.0)
                        property color onContainerColor: Qt.hsla(modelData.hue, 0.40, 0.25, 1.0)
                        
                        Image {
                            anchors.fill: parent
                            sourceSize.width: width * 2
                            sourceSize.height: height * 2
                            smooth: true
                            antialiasing: true
                            mipmap: true
                            
                            source: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><path d='" + m3Shapes.getPath(modelData.shape) + "' fill='" + parent.containerColor.toString() + "'/></svg>"
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData.icon
                            font.family: parent.parent.parent.isSelected ? filledIconFont.name : "Material Symbols Outlined"
                            font.pixelSize: 22
                            color: parent.onContainerColor
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: modelData.name
                            font.family: Vars.fontFamily
                            font.pixelSize: 16
                            font.weight: parent.parent.isSelected ? 500 : 400
                            color: parent.parent.isSelected ? Theme.on_secondary_container : Theme.on_surface
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignLeft
                        }
                        Text {
                            text: modelData.subtitle
                            font.family: Vars.fontFamily
                            font.pixelSize: 12
                            color: parent.parent.isSelected ? Theme.on_secondary_container : Theme.on_surface_variant
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignLeft
                            opacity: 0.9
                        }
                    }
                }
                
                MouseArea {
                    id: navHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: rootSidebar.currentSection = modelData.id
                }
            }
        }
    }
}
