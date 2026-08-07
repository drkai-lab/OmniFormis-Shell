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
    
    property string currentSection: "quick"


    Layout.fillWidth: true
    spacing: 4

    FontLoader {
        id: filledIconFont
        source: "../../theme/assets/MaterialSymbolsRounded-Filled.ttf"
    }

    property var navItems: []

    Repeater {
        model: navItems
        delegate: ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: (modelData.isFirst && index !== 0) ? 16 : 0
            spacing: 4



            Item {
                id: delegateItem
                Layout.fillWidth: true
                Layout.preferredHeight: 72
                property bool isSelected: rootSidebar.currentSection === modelData.id
                
                // Determine target color (which may contain alpha)
                property color targetColor: isSelected ? ((Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.secondary_container.r, Theme.secondary_container.g, Theme.secondary_container.b, Vars.componentOpacity) : Theme.secondary_container) : (navHover.containsMouse ? Qt.tint(((Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface_container_high.r, Theme.surface_container_high.g, Theme.surface_container_high.b, Vars.componentOpacity) : Theme.surface_container_high), Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08)) : ((Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface_container_high.r, Theme.surface_container_high.g, Theme.surface_container_high.b, Vars.componentOpacity) : Theme.surface_container_high))
                Behavior on targetColor { ColorAnimation { duration: Vars.animationDuration } }

                scale: navHover.pressed ? 1.08 : 1.0
                Behavior on scale { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.OutBack } }

                Item {
                    anchors.fill: parent
                    layer.enabled: true
                    opacity: delegateItem.targetColor.a

                    Rectangle {
                        anchors.fill: parent
                        radius: delegateItem.isSelected ? height / 2 : 16
                        Behavior on radius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
                        color: Qt.rgba(delegateItem.targetColor.r, delegateItem.targetColor.g, delegateItem.targetColor.b, 1.0)
                        
                        // Square-off top corners if not the first item
                        Rectangle {
                            width: parent.radius; height: parent.radius; color: parent.color
                            anchors.top: parent.top; anchors.left: parent.left
                            opacity: (!modelData.isFirst && !delegateItem.isSelected) ? 1.0 : 0.0
                            Behavior on opacity { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
                        }
                        Rectangle {
                            width: parent.radius; height: parent.radius; color: parent.color
                            anchors.top: parent.top; anchors.right: parent.right
                            opacity: (!modelData.isFirst && !delegateItem.isSelected) ? 1.0 : 0.0
                            Behavior on opacity { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
                        }
                        // Square-off bottom corners if not the last item
                        Rectangle {
                            width: parent.radius; height: parent.radius; color: parent.color
                            anchors.bottom: parent.bottom; anchors.left: parent.left
                            opacity: (!modelData.isLast && !delegateItem.isSelected) ? 1.0 : 0.0
                            Behavior on opacity { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
                        }
                        Rectangle {
                            width: parent.radius; height: parent.radius; color: parent.color
                            anchors.bottom: parent.bottom; anchors.right: parent.right
                            opacity: (!modelData.isLast && !delegateItem.isSelected) ? 1.0 : 0.0
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
                        
                        property color containerColor: {
                            var colors = [
                                Theme.primary,
                                Theme.secondary,
                                Theme.tertiary
                            ];
                            return colors[index % colors.length];
                        }
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

                        // Outlined (Empty) Icon
                        Text {
                            anchors.centerIn: parent
                            text: modelData.icon
                            font.family: "Material Symbols Outlined"
                            font.pixelSize: 24
                            color: parent.onContainerColor
                            opacity: delegateItem.isSelected ? 0.0 : 1.0
                            scale: delegateItem.isSelected ? 0.8 : 1.0
                            
                            Behavior on opacity { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.InOutQuad } }
                            Behavior on scale { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.OutBack } }
                        }

                        // Filled Icon
                        Text {
                            anchors.centerIn: parent
                            text: modelData.icon
                            font.family: filledIconFont.name
                            font.pixelSize: 24
                            color: parent.onContainerColor
                            opacity: delegateItem.isSelected ? 1.0 : 0.0
                            scale: delegateItem.isSelected ? 1.0 : 0.5
                            
                            Behavior on opacity { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.InOutQuad } }
                            Behavior on scale { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.OutBack } }
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: modelData.name
                            font.family: Vars.fontFamily
                            font.pixelSize: 16
                            font.weight: delegateItem.isSelected ? 500 : 400
                            color: delegateItem.isSelected ? Theme.on_secondary_container : Theme.on_surface
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                        }
                        Text {
                            text: modelData.subtitle
                            font.family: Vars.fontFamily
                            font.pixelSize: 12
                            color: delegateItem.isSelected ? Theme.on_secondary_container : Theme.on_surface_variant
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignLeft
                            opacity: 0.9
                            elide: Text.ElideRight
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
